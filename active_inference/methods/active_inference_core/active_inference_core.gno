// Package active_inference_core provides core active inference methods
// that integrate Bayesian inference, Free Energy Principle, and cognitive modeling
// for autonomous decision-making and adaptation on the Gno blockchain.
//
// Active Inference is a framework that explains perception, learning, and
// decision-making as processes that minimize variational free energy.
// This implementation provides the core algorithms for active inference agents.
package active_inference_core

import (
	"math"
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
	"gno.land/p/active_inference/methods/free_energy_principle"
	"gno.land/p/active_inference/methods/cognitive_modeling"
)

// ActiveInferenceAgent represents an autonomous agent that uses active inference
type ActiveInferenceAgent struct {
	// Core cognitive architecture
	CognitiveModel *cognitive_modeling.CognitiveModel

	// Active inference parameters
	PlanningHorizon int
	TemporalDiscount methods.Probability
	ExplorationRate  methods.Probability

	// Current state
	CurrentObservation []methods.Probability
	CurrentBeliefs     []methods.Probability
	CurrentPolicies    [][]methods.Probability

	// Learning history
	ActionHistory      [][]methods.Probability
	RewardHistory      []methods.Probability
	FreeEnergyHistory  []methods.Probability
}

// NewActiveInferenceAgent creates a new active inference agent
func NewActiveInferenceAgent() *ActiveInferenceAgent {
	return &ActiveInferenceAgent{
		CognitiveModel:    cognitive_modeling.NewCognitiveModel(),
		PlanningHorizon:   3,
		TemporalDiscount:  0.95,
		ExplorationRate:   0.1,
		CurrentObservation: make([]methods.Probability, 4),
		CurrentBeliefs:     make([]methods.Probability, 4),
		CurrentPolicies:    make([][]methods.Probability, 0),
		ActionHistory:      make([][]methods.Probability, 0),
		RewardHistory:      make([]methods.Probability, 0),
		FreeEnergyHistory:  make([]methods.Probability, 0),
	}
}

// Perceive processes sensory input and updates beliefs
func (aia *ActiveInferenceAgent) Perceive(observation []methods.Probability) error {
	if len(observation) != len(aia.CurrentObservation) {
		return ufmt.Errorf("observation length mismatch")
	}

	// Update current observation
	copy(aia.CurrentObservation, observation)

	// Process through cognitive model
	response, err := aia.CognitiveModel.ProcessStimulus(observation)
	if err != nil {
		return err
	}

	// Update beliefs based on perception
	aia.CurrentBeliefs = response.Perception

	// Store free energy for monitoring
	if aia.CognitiveModel.FreeEnergy != nil {
		freeEnergy := aia.CognitiveModel.FreeEnergy.ComputeFreeEnergy()
		aia.FreeEnergyHistory = append(aia.FreeEnergyHistory, freeEnergy)

		// Keep history bounded
		if len(aia.FreeEnergyHistory) > 1000 {
			aia.FreeEnergyHistory = aia.FreeEnergyHistory[1:]
		}
	}

	return nil
}

// Plan generates optimal policies using active inference
func (aia *ActiveInferenceAgent) Plan() ([][]methods.Probability, error) {
	// Use active inference to select optimal policies
	if aia.CognitiveModel.ActiveInference == nil {
		return nil, ufmt.Errorf("active inference not initialized")
	}

	policies := make([][]methods.Probability, 0)

	// Generate candidate policies
	for i := 0; i < 8; i++ { // Generate 8 candidate policies
		policy := aia.generatePolicy()
		policies = append(policies, policy)
	}

	aia.CurrentPolicies = policies
	return policies, nil
}

// Act executes the selected action and learns from the outcome
func (aia *ActiveInferenceAgent) Act(policyIndex int) error {
	if policyIndex < 0 || policyIndex >= len(aia.CurrentPolicies) {
		return ufmt.Errorf("invalid policy index")
	}

	selectedPolicy := aia.CurrentPolicies[policyIndex]

	// Execute the policy (simplified - would interface with external systems)
	action := selectedPolicy

	// Store action in history
	aia.ActionHistory = append(aia.ActionHistory, action)

	// Keep history bounded
	if len(aia.ActionHistory) > 100 {
		aia.ActionHistory = aia.ActionHistory[1:]
	}

	return nil
}

// Learn updates the agent's models based on experience
func (aia *ActiveInferenceAgent) Learn(reward methods.Probability) error {
	// Store reward in history
	aia.RewardHistory = append(aia.RewardHistory, reward)

	// Keep history bounded
	if len(aia.RewardHistory) > 100 {
		aia.RewardHistory = aia.RewardHistory[1:]
	}

	// Update cognitive model with learning
	if len(aia.ActionHistory) > 0 {
		lastAction := aia.ActionHistory[len(aia.ActionHistory)-1]

		// Update learning system
		aia.CognitiveModel.Learning.UpdateBeliefs(
			aia.CurrentObservation,
			aia.CurrentBeliefs,
			aia.CognitiveModel.GoalSystem.Goals,
		)

		// Learn habit if reward is positive
		if reward > 0.5 {
			aia.CognitiveModel.Learning.LearnHabit(aia.CurrentObservation, lastAction)
		}

		// Update attention system
		aia.CognitiveModel.Attention.UpdateBiasTerms(aia.CognitiveModel.GoalSystem.Goals)

		// Update active inference policy priors
		if aia.CognitiveModel.ActiveInference != nil {
			outcome := []methods.Probability{reward, 1 - reward, 0.5, 0.5}
			aia.CognitiveModel.ActiveInference.UpdatePolicyPrior(len(aia.CurrentPolicies)-1, outcome)
		}
	}

	return nil
}

// generatePolicy creates a random policy for exploration
func (aia *ActiveInferenceAgent) generatePolicy() []methods.Probability {
	policyLength := 4 // Simple action sequences
	policy := make([]methods.Probability, policyLength)

	for i := range policy {
		// Generate random actions (simplified)
		// In practice, this would use more sophisticated policy generation
		randomVal := methods.Probability(float64(i+1) / float64(policyLength))
		policy[i] = randomVal
	}

	return policy
}

// GetExpectedFreeEnergy computes the expected free energy for the current state
func (aia *ActiveInferenceAgent) GetExpectedFreeEnergy() methods.Probability {
	if aia.CognitiveModel.FreeEnergy == nil {
		return 0
	}

	return aia.CognitiveModel.FreeEnergy.ComputeFreeEnergy()
}

// GetBeliefAccuracy measures how well beliefs match observations
func (aia *ActiveInferenceAgent) GetBeliefAccuracy() methods.Probability {
	if len(aia.CurrentBeliefs) != len(aia.CurrentObservation) {
		return 0
	}

	accuracy := methods.Probability(0)
	for i := range aia.CurrentBeliefs {
		diff := methods.Probability(math.Abs(float64(aia.CurrentBeliefs[i] - aia.CurrentObservation[i])))
		accuracy += 1 - diff
	}
	accuracy /= methods.Probability(len(aia.CurrentBeliefs))

	return accuracy
}

// Optimize performs one step of model optimization
func (aia *ActiveInferenceAgent) Optimize() error {
	// Optimize generative model parameters
	if aia.CognitiveModel.FreeEnergy != nil {
		// Update variational parameters
		_, err := aia.CognitiveModel.FreeEnergy.Infer(aia.CurrentObservation)
		if err != nil {
			return err
		}
	}

	// Update working memory
	aia.CognitiveModel.WorkingMemory.Decay()

	// Consolidate long-term memories
	aia.CognitiveModel.LongTermMemory.Consolidate()

	return nil
}

// MultiAgentSystem coordinates multiple active inference agents
type MultiAgentSystem struct {
	Agents    []*ActiveInferenceAgent
	SocialGraph map[string][]string // Agent relationships
	GlobalGoals []methods.Probability
}

// NewMultiAgentSystem creates a new multi-agent system
func NewMultiAgentSystem(numAgents int) *MultiAgentSystem {
	agents := make([]*ActiveInferenceAgent, numAgents)
	for i := range agents {
		agents[i] = NewActiveInferenceAgent()
	}

	return &MultiAgentSystem{
		Agents:      agents,
		SocialGraph: make(map[string][]string),
		GlobalGoals: make([]methods.Probability, 4),
	}
}

// CoordinateAgents enables social coordination between agents
func (mas *MultiAgentSystem) CoordinateAgents() error {
	// Simple coordination mechanism
	for i, agent := range mas.Agents {
		agentID := ufmt.Sprintf("agent%d", i)

		// Share observations with connected agents
		if neighbors, exists := mas.SocialGraph[agentID]; exists {
			for _, neighborID := range neighbors {
				// Parse neighbor index
				var neighborIdx int
				_, err := ufmt.Scanf(neighborID, "agent%d", &neighborIdx)
				if err != nil {
					continue
				}

				if neighborIdx >= 0 && neighborIdx < len(mas.Agents) {
					neighbor := mas.Agents[neighborIdx]

					// Model the neighbor's behavior
					neighbor.SocialModel.ModelAgent(agentID, agent.CurrentObservation)

					// Share goals
					neighbor.GoalSystem.SetGoal(0, agent.GoalSystem.Goals[0])
				}
			}
		}
	}

	return nil
}

// EmergentBehaviorSystem implements emergent behavior through collective active inference
type EmergentBehaviorSystem struct {
	*MultiAgentSystem
	EmergentPatterns map[string][]methods.Probability
	CollectiveGoals  []methods.Probability
}

// NewEmergentBehaviorSystem creates a new emergent behavior system
func NewEmergentBehaviorSystem(numAgents int) *EmergentBehaviorSystem {
	return &EmergentBehaviorSystem{
		MultiAgentSystem: NewMultiAgentSystem(numAgents),
		EmergentPatterns: make(map[string][]methods.Probability),
		CollectiveGoals:  make([]methods.Probability, 4),
	}
}

// DetectEmergentPatterns identifies collective behavior patterns
func (ebs *EmergentBehaviorSystem) DetectEmergentPatterns() {
	// Aggregate agent behaviors
	collectiveBehavior := make([]methods.Probability, 4)

	for _, agent := range ebs.Agents {
		for i := range collectiveBehavior {
			if i < len(agent.CurrentBeliefs) {
				collectiveBehavior[i] += agent.CurrentBeliefs[i]
			}
		}
	}

	// Average across agents
	numAgents := methods.Probability(len(ebs.Agents))
	for i := range collectiveBehavior {
		collectiveBehavior[i] /= numAgents
	}

	// Detect patterns
	patternKey := ebs.behaviorToKey(collectiveBehavior)
	ebs.EmergentPatterns[patternKey] = collectiveBehavior

	// Update collective goals based on emergent patterns
	ebs.updateCollectiveGoals(collectiveBehavior)
}

// behaviorToKey converts behavior vector to string key
func (ebs *EmergentBehaviorSystem) behaviorToKey(behavior []methods.Probability) string {
	key := ""
	for _, val := range behavior {
		key += ufmt.Sprintf("%.2f,", val)
	}
	return key
}

// updateCollectiveGoals updates collective goals based on emergent behavior
func (ebs *EmergentBehaviorSystem) updateCollectiveGoals(collectiveBehavior []methods.Probability) {
	learningRate := methods.Probability(0.05)

	for i := range ebs.CollectiveGoals {
		if i < len(collectiveBehavior) {
			// Move collective goals towards emergent behavior
			ebs.CollectiveGoals[i] += learningRate * (collectiveBehavior[i] - ebs.CollectiveGoals[i])
		}
	}

	// Propagate collective goals to individual agents
	for _, agent := range ebs.Agents {
		for i := range ebs.CollectiveGoals {
			if i < len(agent.GoalSystem.Goals) {
				agent.GoalSystem.Goals[i] = agent.GoalSystem.Goals[i]*0.8 + ebs.CollectiveGoals[i]*0.2
			}
		}
	}
}

// AdaptiveController adapts system parameters based on performance
type AdaptiveController struct {
	PerformanceMetrics map[string][]methods.Probability
	AdaptationRate     methods.Probability
}

// NewAdaptiveController creates a new adaptive controller
func NewAdaptiveController() *AdaptiveController {
	return &AdaptiveController{
		PerformanceMetrics: make(map[string][]methods.Probability),
		AdaptationRate:     0.01,
	}
}

// AdaptParameters adjusts system parameters based on performance history
func (ac *AdaptiveController) AdaptParameters(agent *ActiveInferenceAgent, performance methods.Probability) {
	// Store performance metric
	performanceHistory := ac.PerformanceMetrics["overall"]
	performanceHistory = append(performanceHistory, performance)

	// Keep bounded history
	if len(performanceHistory) > 50 {
		performanceHistory = performanceHistory[1:]
	}
	ac.PerformanceMetrics["overall"] = performanceHistory

	// Adapt exploration rate based on performance
	if len(performanceHistory) >= 10 {
		recentAvg := methods.Probability(0)
		for i := len(performanceHistory) - 10; i < len(performanceHistory); i++ {
			recentAvg += performanceHistory[i]
		}
		recentAvg /= 10

		// Increase exploration if performance is poor
		if recentAvg < 0.5 {
			agent.ExplorationRate += ac.AdaptationRate
			if agent.ExplorationRate > 0.5 {
				agent.ExplorationRate = 0.5
			}
		} else {
			// Decrease exploration if performance is good
			agent.ExplorationRate -= ac.AdaptationRate
			if agent.ExplorationRate < 0.01 {
				agent.ExplorationRate = 0.01
			}
		}
	}

	// Adapt planning horizon based on performance stability
	if len(performanceHistory) >= 20 {
		variance := ac.computeVariance(performanceHistory[len(performanceHistory)-20:])

		// Increase planning horizon if performance is stable
		if variance < 0.1 {
			agent.PlanningHorizon++
			if agent.PlanningHorizon > 10 {
				agent.PlanningHorizon = 10
			}
		} else if variance > 0.3 {
			// Decrease planning horizon if performance is unstable
			agent.PlanningHorizon--
			if agent.PlanningHorizon < 1 {
				agent.PlanningHorizon = 1
			}
		}
	}
}

// computeVariance calculates the variance of a slice of probabilities
func (ac *AdaptiveController) computeVariance(values []methods.Probability) methods.Probability {
	if len(values) == 0 {
		return 0
	}

	mean := methods.Probability(0)
	for _, v := range values {
		mean += v
	}
	mean /= methods.Probability(len(values))

	variance := methods.Probability(0)
	for _, v := range values {
		diff := v - mean
		variance += diff * diff
	}
	variance /= methods.Probability(len(values))

	return variance
}

// DecisionSupportSystem provides decision support using ensemble active inference
type DecisionSupportSystem struct {
	Models      []*ActiveInferenceAgent
	EnsembleWeights []methods.Probability
	ConfidenceThreshold methods.Probability
}

// NewDecisionSupportSystem creates a new decision support system
func NewDecisionSupportSystem(numModels int) *DecisionSupportSystem {
	models := make([]*ActiveInferenceAgent, numModels)
	weights := make([]methods.Probability, numModels)

	for i := range models {
		models[i] = NewActiveInferenceAgent()
		weights[i] = methods.Probability(1.0 / float64(numModels))
	}

	return &DecisionSupportSystem{
		Models:             models,
		EnsembleWeights:    weights,
		ConfidenceThreshold: 0.7,
	}
}

// MakeEnsembleDecision makes a decision using ensemble of active inference models
func (dss *DecisionSupportSystem) MakeEnsembleDecision(observation []methods.Probability) ([]methods.Probability, methods.Probability, error) {
	if len(dss.Models) == 0 {
		return nil, 0, ufmt.Errorf("no models available")
	}

	// Get predictions from all models
	predictions := make([][]methods.Probability, len(dss.Models))
	confidences := make([]methods.Probability, len(dss.Models))

	for i, model := range dss.Models {
		err := model.Perceive(observation)
		if err != nil {
			continue
		}

		predictions[i] = make([]methods.Probability, len(model.CurrentBeliefs))
		copy(predictions[i], model.CurrentBeliefs)

		confidences[i] = model.CognitiveModel.MetaCognition.AssessConfidence(model.CurrentBeliefs)
	}

	// Weighted ensemble prediction
	ensemblePrediction := make([]methods.Probability, len(observation))
	ensembleConfidence := methods.Probability(0)

	for i := range ensemblePrediction {
		weightedSum := methods.Probability(0)
		weightSum := methods.Probability(0)

		for j, prediction := range predictions {
			if j < len(dss.EnsembleWeights) && i < len(prediction) {
				if confidences[j] >= dss.ConfidenceThreshold {
					weightedSum += prediction[i] * dss.EnsembleWeights[j]
					weightSum += dss.EnsembleWeights[j]
				}
			}
		}

		if weightSum > 0 {
			ensemblePrediction[i] = weightedSum / weightSum
		} else {
			ensemblePrediction[i] = 0.5 // Default uncertainty
		}
	}

	// Compute ensemble confidence
	for i, confidence := range confidences {
		if confidence >= dss.ConfidenceThreshold {
			ensembleConfidence += confidence * dss.EnsembleWeights[i]
		}
	}

	return ensemblePrediction, ensembleConfidence, nil
}

// UpdateEnsembleWeights updates model weights based on performance
func (dss *DecisionSupportSystem) UpdateEnsembleWeights(actualOutcome []methods.Probability) {
	learningRate := methods.Probability(0.01)

	for i, model := range dss.Models {
		if i >= len(dss.EnsembleWeights) {
			continue
		}

		// Compute model accuracy
		accuracy := methods.Probability(0)
		if i < len(model.CurrentBeliefs) && len(model.CurrentBeliefs) == len(actualOutcome) {
			for j := range model.CurrentBeliefs {
				diff := methods.Probability(math.Abs(float64(model.CurrentBeliefs[j] - actualOutcome[j])))
				accuracy += 1 - diff
			}
			accuracy /= methods.Probability(len(model.CurrentBeliefs))
		}

		// Update weight based on accuracy
		if accuracy > 0.5 {
			dss.EnsembleWeights[i] += learningRate * (accuracy - 0.5) * 2
		} else {
			dss.EnsembleWeights[i] -= learningRate * (0.5 - accuracy) * 2
		}

		// Ensure non-negative weights
		if dss.EnsembleWeights[i] < 0 {
			dss.EnsembleWeights[i] = 0
		}
	}

	// Renormalize weights
	sum := methods.Probability(0)
	for _, weight := range dss.EnsembleWeights {
		sum += weight
	}

	if sum > 0 {
		for i := range dss.EnsembleWeights {
			dss.EnsembleWeights[i] = dss.EnsembleWeights[i] / sum
		}
	}
}
