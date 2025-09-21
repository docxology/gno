// Package bayesian_inference provides Bayesian network and inference methods
// for probabilistic reasoning on the Gno blockchain.
//
// This package implements exact and approximate inference algorithms suitable
// for on-chain applications, with deterministic behavior and gas-efficient
// computations following the principles of Bayesian probability theory.
package bayesian_inference

import (
	"math"
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
)

// Node represents a node in a Bayesian network
type Node struct {
	Name         string
	States       []string                    // Possible states/values
	Parents      []*Node                     // Parent nodes in the network
	CPT          map[string][]methods.Probability // Conditional Probability Table
}

// NewNode creates a new node with given states
func NewNode(name string, states []string) *Node {
	return &Node{
		Name:   name,
		States: states,
		CPT:    make(map[string][]methods.Probability),
	}
}

// AddParent adds a parent node to this node
func (n *Node) AddParent(parent *Node) {
	n.Parents = append(n.Parents, parent)
}

// SetCPT sets the conditional probability table for this node
// The key is a combination of parent states, value is probabilities for each of this node's states
func (n *Node) SetCPT(parentStates string, probabilities []methods.Probability) error {
	if len(probabilities) != len(n.States) {
		return ufmt.Errorf("probabilities length must match number of states")
	}

	// Validate probabilities sum to 1
	sum := methods.Probability(0)
	for _, p := range probabilities {
		if err := p.Validate(); err != nil {
			return err
		}
		sum += p
	}

	if math.Abs(float64(sum-1.0)) > 1e-6 {
		return ufmt.Errorf("probabilities must sum to 1")
	}

	n.CPT[parentStates] = probabilities
	return nil
}

// GetProbability returns P(node_state | parent_states)
func (n *Node) GetProbability(state string, parentStates string) methods.Probability {
	probabilities, exists := n.CPT[parentStates]
	if !exists {
		return 0
	}

	for i, s := range n.States {
		if s == state {
			return probabilities[i]
		}
	}
	return 0
}

// BayesianNetwork represents a complete Bayesian network
type BayesianNetwork struct {
	Nodes   []*Node
	nodeMap map[string]*Node
}

// NewBayesianNetwork creates a new Bayesian network
func NewBayesianNetwork() *BayesianNetwork {
	return &BayesianNetwork{
		Nodes:   make([]*Node, 0),
		nodeMap: make(map[string]*Node),
	}
}

// AddNode adds a node to the network
func (bn *BayesianNetwork) AddNode(node *Node) {
	bn.Nodes = append(bn.Nodes, node)
	bn.nodeMap[node.Name] = node
}

// GetNode returns a node by name
func (bn *BayesianNetwork) GetNode(name string) *Node {
	return bn.nodeMap[name]
}

// GetTopologicalOrder returns nodes in topological order (parents before children)
func (bn *BayesianNetwork) GetTopologicalOrder() []*Node {
	// Simple topological sort implementation
	visited := make(map[string]bool)
	result := make([]*Node, 0, len(bn.Nodes))

	var visit func(node *Node)
	visit = func(node *Node) {
		if visited[node.Name] {
			return
		}
		visited[node.Name] = true

		// Visit all parents first
		for _, parent := range node.Parents {
			visit(parent)
		}

		result = append(result, node)
	}

	// Visit all nodes
	for _, node := range bn.Nodes {
		visit(node)
	}

	return result
}

// InferenceEngine performs probabilistic inference on Bayesian networks
type InferenceEngine struct {
	Network *BayesianNetwork
}

// NewInferenceEngine creates a new inference engine for the given network
func NewInferenceEngine(network *BayesianNetwork) *InferenceEngine {
	return &InferenceEngine{
		Network: network,
	}
}

// VariableElimination performs exact inference using variable elimination algorithm
type VariableElimination struct {
	*InferenceEngine
}

// NewVariableElimination creates a new variable elimination inference engine
func NewVariableElimination(network *BayesianNetwork) *VariableElimination {
	return &VariableElimination{
		InferenceEngine: NewInferenceEngine(network),
	}
}

// Query performs a probabilistic query P(query | evidence)
// This is a simplified implementation for demonstration
func (ve *VariableElimination) Query(query map[string]string, evidence map[string]string) map[string]methods.Probability {
	result := make(map[string]methods.Probability)

	// Get query node
	queryNodeName := ""
	for nodeName := range query {
		queryNodeName = nodeName
		break
	}

	if queryNodeName == "" {
		return result
	}

	queryNode := ve.Network.GetNode(queryNodeName)
	if queryNode == nil {
		return result
	}

	// Simple enumeration for small networks
	// In practice, this would use more sophisticated variable elimination
	for _, state := range queryNode.States {
		probability := ve.enumerateAll(query, evidence, queryNode, state)
		result[state] = probability
	}

	// Normalize
	sum := methods.Probability(0)
	for _, p := range result {
		sum += p
	}

	if sum > 0 {
		for state, p := range result {
			result[state] = p / sum
		}
	}

	return result
}

// enumerateAll recursively enumerates all possible assignments
// This is a simplified version for demonstration purposes
func (ve *VariableElimination) enumerateAll(query, evidence map[string]string, node *Node, state string) methods.Probability {
	// Check if this assignment is consistent with evidence
	if evidenceState, hasEvidence := evidence[node.Name]; hasEvidence {
		if evidenceState != state {
			return 0
		}
	}

	// Get parent states for this assignment
	parentStates := ""
	if len(node.Parents) > 0 {
		parentStates = ve.getParentStates(node.Parents, query, evidence)
	}

	// Get conditional probability
	prob := node.GetProbability(state, parentStates)

	// Base case: leaf node
	if len(node.Parents) == 0 {
		return prob
	}

	// Recursive case: multiply by parent probabilities
	parentProb := methods.Probability(1)
	for _, parent := range node.Parents {
		if parentEvidence, hasEvidence := evidence[parent.Name]; hasEvidence {
			parentProb *= parent.GetProbability(parentEvidence, ve.getParentStates(parent.Parents, query, evidence))
		} else {
			// Sum over all possible parent states (simplified)
			parentProb *= ve.getMarginalProbability(parent, query, evidence)
		}
	}

	return prob * parentProb
}

// getParentStates creates a string representation of parent states
func (ve *VariableElimination) getParentStates(parents []*Node, query, evidence map[string]string) string {
	states := ""
	for _, parent := range parents {
		if evidenceState, hasEvidence := evidence[parent.Name]; hasEvidence {
			states += evidenceState + ","
		} else if queryState, hasQuery := query[parent.Name]; hasQuery {
			states += queryState + ","
		} else {
			states += parent.States[0] + "," // Default to first state
		}
	}
	if len(states) > 0 {
		states = states[:len(states)-1] // Remove trailing comma
	}
	return states
}

// getMarginalProbability computes marginal probability for a node
func (ve *VariableElimination) getMarginalProbability(node *Node, query, evidence map[string]string) methods.Probability {
	// Simplified marginal computation
	if evidenceState, hasEvidence := evidence[node.Name]; hasEvidence {
		return node.GetProbability(evidenceState, ve.getParentStates(node.Parents, query, evidence))
	}

	// Sum over all possible states
	totalProb := methods.Probability(0)
	for _, state := range node.States {
		totalProb += node.GetProbability(state, ve.getParentStates(node.Parents, query, evidence))
	}

	return totalProb
}

// MarkovChainMonteCarlo implements MCMC sampling for approximate inference
type MarkovChainMonteCarlo struct {
	*InferenceEngine
	samples int
}

// NewMarkovChainMonteCarlo creates a new MCMC inference engine
func NewMarkovChainMonteCarlo(network *BayesianNetwork, samples int) *MarkovChainMonteCarlo {
	return &MarkovChainMonteCarlo{
		InferenceEngine: NewInferenceEngine(network),
		samples:         samples,
	}
}

// Query performs approximate inference using MCMC sampling
func (mcmc *MarkovChainMonteCarlo) Query(query map[string]string, evidence map[string]string) map[string]methods.Probability {
	result := make(map[string]methods.Probability)

	// Get query node
	queryNodeName := ""
	for nodeName := range query {
		queryNodeName = nodeName
		break
	}

	if queryNodeName == "" {
		return result
	}

	queryNode := mcmc.Network.GetNode(queryNodeName)
	if queryNode == nil {
		return result
	}

	// Initialize counts for each state
	stateCounts := make(map[string]int)

	// Generate samples using MCMC
	currentState := mcmc.sampleInitialState(evidence)

	for i := 0; i < mcmc.samples; i++ {
		// Sample next state using Metropolis-Hastings
		currentState = mcmc.metropolisHastingsStep(currentState, evidence)

		// Count occurrences of query variable states
		if queryState, exists := currentState[queryNodeName]; exists {
			stateCounts[queryState]++
		}
	}

	// Convert counts to probabilities
	totalSamples := float64(mcmc.samples)
	for _, state := range queryNode.States {
		count := stateCounts[state]
		result[state] = methods.Probability(float64(count) / totalSamples)
	}

	return result
}

// sampleInitialState creates an initial state assignment consistent with evidence
func (mcmc *MarkovChainMonteCarlo) sampleInitialState(evidence map[string]string) map[string]string {
	state := make(map[string]string)

	// Set evidence variables
	for nodeName, value := range evidence {
		state[nodeName] = value
	}

	// Sample non-evidence variables
	for _, node := range mcmc.Network.Nodes {
		if _, hasEvidence := evidence[node.Name]; !hasEvidence {
			// Simple uniform sampling for initialization
			state[node.Name] = node.States[0] // Default to first state
		}
	}

	return state
}

// metropolisHastingsStep performs one step of Metropolis-Hastings sampling
func (mcmc *MarkovChainMonteCarlo) metropolisHastingsStep(currentState map[string]string, evidence map[string]string) map[string]string {
	// Simplified MCMC step - in practice this would be more sophisticated
	newState := make(map[string]string)

	// Copy current state
	for k, v := range currentState {
		newState[k] = v
	}

	// Randomly propose a change to one non-evidence variable
	// This is a simplified implementation
	for _, node := range mcmc.Network.Nodes {
		if _, hasEvidence := evidence[node.Name]; !hasEvidence {
			// For demonstration, we'll keep the current state
			// A full implementation would randomly change one variable
			break
		}
	}

	return newState
}

// BeliefPropagation implements belief propagation for exact inference in trees
type BeliefPropagation struct {
	*InferenceEngine
}

// NewBeliefPropagation creates a new belief propagation inference engine
func NewBeliefPropagation(network *BayesianNetwork) *BeliefPropagation {
	return &BeliefPropagation{
		InferenceEngine: NewInferenceEngine(network),
	}
}

// Query performs inference using belief propagation (simplified for trees)
func (bp *BeliefPropagation) Query(query map[string]string, evidence map[string]string) map[string]methods.Probability {
	// Simplified belief propagation implementation
	// In practice, this would handle tree-structured networks properly
	result := make(map[string]methods.Probability)

	// Get query node
	queryNodeName := ""
	for nodeName := range query {
		queryNodeName = nodeName
		break
	}

	if queryNodeName == "" {
		return result
	}

	queryNode := bp.Network.GetNode(queryNodeName)
	if queryNode == nil {
		return result
	}

	// For each possible state of query node, compute probability given evidence
	for _, state := range queryNode.States {
		prob := bp.computeBelief(queryNode, state, evidence)
		result[state] = prob
	}

	return result
}

// computeBelief computes the belief (posterior probability) for a node state
func (bp *BeliefPropagation) computeBelief(node *Node, state string, evidence map[string]string) methods.Probability {
	// Simplified belief computation
	parentStates := ""
	if len(node.Parents) > 0 {
		parentStates = bp.getParentStatesString(node.Parents, evidence)
	}

	prob := node.GetProbability(state, parentStates)

	// Multiply by beliefs from parents
	for _, parent := range node.Parents {
		if parentState, hasEvidence := evidence[parent.Name]; hasEvidence {
			parentProb := parent.GetProbability(parentState, bp.getParentStatesString(parent.Parents, evidence))
			prob *= parentProb
		}
	}

	return prob
}

// getParentStatesString creates a string representation of parent states from evidence
func (bp *BeliefPropagation) getParentStatesString(parents []*Node, evidence map[string]string) string {
	states := ""
	for _, parent := range parents {
		if evidenceState, hasEvidence := evidence[parent.Name]; hasEvidence {
			states += evidenceState + ","
		} else {
			states += parent.States[0] + "," // Default to first state
		}
	}
	if len(states) > 0 {
		states = states[:len(states)-1] // Remove trailing comma
	}
	return states
}
