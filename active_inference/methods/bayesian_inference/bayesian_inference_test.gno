// Package bayesian_inference_test provides comprehensive tests for Bayesian inference methods
package bayesian_inference

import (
	"math"
	"testing"
	"gno.land/p/active_inference/methods"
)

// Test the classic "Alarm" Bayesian network example
func TestAlarmNetwork(t *testing.T) {
	// Create nodes
	burglary := NewNode("Burglary", []string{"true", "false"})
	earthquake := NewNode("Earthquake", []string{"true", "false"})
	alarm := NewNode("Alarm", []string{"true", "false"})
	johnCalls := NewNode("JohnCalls", []string{"true", "false"})
	maryCalls := NewNode("MaryCalls", []string{"true", "false"})

	// Set up network structure
	alarm.AddParent(burglary)
	alarm.AddParent(earthquake)
	johnCalls.AddParent(alarm)
	maryCalls.AddParent(alarm)

	// Set conditional probability tables
	// P(Burglary)
	burglary.SetCPT("", []methods.Probability{0.001, 0.999})

	// P(Earthquake)
	earthquake.SetCPT("", []methods.Probability{0.002, 0.998})

	// P(Alarm | Burglary, Earthquake)
	alarm.SetCPT("true,true", []methods.Probability{0.95, 0.05})   // P(A|T,T)
	alarm.SetCPT("true,false", []methods.Probability{0.94, 0.06})  // P(A|T,F)
	alarm.SetCPT("false,true", []methods.Probability{0.29, 0.71})  // P(A|F,T)
	alarm.SetCPT("false,false", []methods.Probability{0.001, 0.999}) // P(A|F,F)

	// P(JohnCalls | Alarm)
	johnCalls.SetCPT("true", []methods.Probability{0.9, 0.1})  // P(J|T)
	johnCalls.SetCPT("false", []methods.Probability{0.05, 0.95}) // P(J|F)

	// P(MaryCalls | Alarm)
	maryCalls.SetCPT("true", []methods.Probability{0.7, 0.3})  // P(M|T)
	maryCalls.SetCPT("false", []methods.Probability{0.01, 0.99}) // P(M|F)

	// Create network
	network := NewBayesianNetwork()
	network.AddNode(burglary)
	network.AddNode(earthquake)
	network.AddNode(alarm)
	network.AddNode(johnCalls)
	network.AddNode(maryCalls)

	// Test variable elimination
	ve := NewVariableElimination(network)

	// Query: P(Burglary | JohnCalls=true, MaryCalls=true)
	query := map[string]string{"Burglary": ""}
	evidence := map[string]string{
		"JohnCalls": "true",
		"MaryCalls": "true",
	}

	result := ve.Query(query, evidence)

	// The result should show higher probability for burglary=true given both calls
	burglaryTrueProb := result["true"]
	burglaryFalseProb := result["false"]

	if burglaryTrueProb <= burglaryFalseProb {
		t.Error("Expected higher probability for burglary=true given both calls")
	}

	if math.Abs(float64(burglaryTrueProb+burglaryFalseProb)-1.0) > 1e-6 {
		t.Error("Probabilities should sum to 1")
	}
}

func TestBayesianNetwork(t *testing.T) {
	network := NewBayesianNetwork()

	// Test empty network
	if len(network.Nodes) != 0 {
		t.Error("Expected empty network")
	}

	// Add nodes
	node1 := NewNode("A", []string{"true", "false"})
	node2 := NewNode("B", []string{"high", "low"})

	network.AddNode(node1)
	network.AddNode(node2)

	if len(network.Nodes) != 2 {
		t.Error("Expected 2 nodes in network")
	}

	// Test node retrieval
	retrieved := network.GetNode("A")
	if retrieved != node1 {
		t.Error("Expected to retrieve node1")
	}

	retrieved = network.GetNode("NonExistent")
	if retrieved != nil {
		t.Error("Expected nil for non-existent node")
	}
}

func TestNodeOperations(t *testing.T) {
	node := NewNode("Test", []string{"state1", "state2", "state3"})

	// Test initial state
	if node.Name != "Test" {
		t.Error("Node name not set correctly")
	}

	if len(node.States) != 3 {
		t.Error("Node states not set correctly")
	}

	// Test CPT operations
	probabilities := []methods.Probability{0.5, 0.3, 0.2}
	err := node.SetCPT("parent1,parent2", probabilities)
	if err != nil {
		t.Errorf("Expected no error setting CPT, got %v", err)
	}

	// Test probability retrieval
	prob := node.GetProbability("state1", "parent1,parent2")
	if prob != 0.5 {
		t.Errorf("Expected probability 0.5, got %f", prob)
	}

	// Test invalid key
	prob = node.GetProbability("state1", "invalid")
	if prob != 0 {
		t.Errorf("Expected probability 0 for invalid key, got %f", prob)
	}

	// Test invalid state
	prob = node.GetProbability("invalid", "parent1,parent2")
	if prob != 0 {
		t.Errorf("Expected probability 0 for invalid state, got %f", prob)
	}
}

func TestCPTValidation(t *testing.T) {
	node := NewNode("Test", []string{"state1", "state2"})

	// Test invalid probabilities length
	probabilities := []methods.Probability{0.5, 0.3, 0.2} // 3 probabilities for 2 states
	err := node.SetCPT("key", probabilities)
	if err == nil {
		t.Error("Expected error for mismatched probabilities length")
	}

	// Test invalid probabilities (negative)
	probabilities = []methods.Probability{-0.1, 1.1}
	err = node.SetCPT("key", probabilities)
	if err == nil {
		t.Error("Expected error for invalid probabilities")
	}

	// Test probabilities not summing to 1
	probabilities = []methods.Probability{0.3, 0.3}
	err = node.SetCPT("key", probabilities)
	if err == nil {
		t.Error("Expected error for probabilities not summing to 1")
	}
}

func TestTopologicalOrder(t *testing.T) {
	network := NewBayesianNetwork()

	// Create nodes with dependencies
	a := NewNode("A", []string{"true", "false"})
	b := NewNode("B", []string{"high", "low"})
	c := NewNode("C", []string{"yes", "no"})

	// A -> B -> C
	b.AddParent(a)
	c.AddParent(b)

	network.AddNode(c) // Add in reverse order
	network.AddNode(b)
	network.AddNode(a)

	order := network.GetTopologicalOrder()

	// Verify topological order: A before B, B before C
	aIndex, bIndex, cIndex := -1, -1, -1
	for i, node := range order {
		switch node.Name {
		case "A":
			aIndex = i
		case "B":
			bIndex = i
		case "C":
			cIndex = i
		}
	}

	if aIndex < 0 || bIndex < 0 || cIndex < 0 {
		t.Error("All nodes should be in topological order")
	}

	if aIndex >= bIndex || bIndex >= cIndex {
		t.Error("Topological order violated: A should come before B, B before C")
	}
}

func TestMarkovChainMonteCarlo(t *testing.T) {
	// Create simple network
	network := NewBayesianNetwork()

	rain := NewNode("Rain", []string{"true", "false"})
	sprinkler := NewNode("Sprinkler", []string{"true", "false"})

	rain.SetCPT("", []methods.Probability{0.2, 0.8})
	sprinkler.SetCPT("", []methods.Probability{0.1, 0.9})

	network.AddNode(rain)
	network.AddNode(sprinkler)

	mcmc := NewMarkovChainMonteCarlo(network, 1000)

	// Query P(Rain | Sprinkler=true)
	query := map[string]string{"Rain": ""}
	evidence := map[string]string{"Sprinkler": "true"}

	result := mcmc.Query(query, evidence)

	// Check that probabilities are valid
	rainTrue := result["true"]
	rainFalse := result["false"]

	if rainTrue < 0 || rainTrue > 1 || rainFalse < 0 || rainFalse > 1 {
		t.Error("Probabilities should be between 0 and 1")
	}

	if math.Abs(float64(rainTrue+rainFalse)-1.0) > 0.1 { // Allow some tolerance for MCMC
		t.Error("Probabilities should approximately sum to 1")
	}
}

func TestBeliefPropagation(t *testing.T) {
	// Create simple tree-structured network
	network := NewBayesianNetwork()

	a := NewNode("A", []string{"true", "false"})
	b := NewNode("B", []string{"true", "false"})
	c := NewNode("C", []string{"true", "false"})

	// Tree structure: A -> B, A -> C
	b.AddParent(a)
	c.AddParent(a)

	// Set CPTs
	a.SetCPT("", []methods.Probability{0.6, 0.4})
	b.SetCPT("true", []methods.Probability{0.7, 0.3})
	b.SetCPT("false", []methods.Probability{0.2, 0.8})
	c.SetCPT("true", []methods.Probability{0.8, 0.2})
	c.SetCPT("false", []methods.Probability{0.1, 0.9})

	network.AddNode(a)
	network.AddNode(b)
	network.AddNode(c)

	bp := NewBeliefPropagation(network)

	// Query P(B | C=true)
	query := map[string]string{"B": ""}
	evidence := map[string]string{"C": "true"}

	result := bp.Query(query, evidence)

	// Check that result is valid
	bTrue := result["true"]
	bFalse := result["false"]

	if bTrue < 0 || bTrue > 1 || bFalse < 0 || bFalse > 1 {
		t.Error("Probabilities should be between 0 and 1")
	}

	if math.Abs(float64(bTrue+bFalse)-1.0) > 1e-6 {
		t.Error("Probabilities should sum to 1")
	}
}

func TestInferenceWithEvidence(t *testing.T) {
	// Create simple network: A -> B
	network := NewBayesianNetwork()

	a := NewNode("A", []string{"true", "false"})
	b := NewNode("B", []string{"true", "false"})

	b.AddParent(a)

	a.SetCPT("", []methods.Probability{0.6, 0.4})
	b.SetCPT("true", []methods.Probability{0.8, 0.2})
	b.SetCPT("false", []methods.Probability{0.3, 0.7})

	network.AddNode(a)
	network.AddNode(b)

	ve := NewVariableElimination(network)

	// Test with evidence
	query := map[string]string{"A": ""}
	evidence := map[string]string{"B": "true"}

	result := ve.Query(query, evidence)

	// P(A=true|B=true) should be higher than prior P(A=true)
	// because A->B with high probability when A=true
	aTruePosterior := result["true"]
	aFalsePosterior := result["false"]

	if aTruePosterior <= aFalsePosterior {
		t.Error("Posterior should favor A=true given B=true")
	}

	// Verify normalization
	if math.Abs(float64(aTruePosterior+aFalsePosterior)-1.0) > 1e-6 {
		t.Error("Posterior probabilities should sum to 1")
	}
}

func TestEmptyQuery(t *testing.T) {
	network := NewBayesianNetwork()
	ve := NewVariableElimination(network)

	// Test empty query
	result := ve.Query(map[string]string{}, map[string]string{})
	if len(result) != 0 {
		t.Error("Expected empty result for empty query")
	}
}

func TestQueryNonExistentNode(t *testing.T) {
	network := NewBayesianNetwork()
	a := NewNode("A", []string{"true", "false"})
	network.AddNode(a)

	ve := NewVariableElimination(network)

	// Query non-existent node
	query := map[string]string{"NonExistent": ""}
	result := ve.Query(query, map[string]string{})

	if len(result) != 0 {
		t.Error("Expected empty result for non-existent node")
	}
}
