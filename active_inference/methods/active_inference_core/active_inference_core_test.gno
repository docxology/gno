// Package active_inference_core_test provides comprehensive tests for active inference core methods
package active_inference_core

import (
	"math"
	"testing"
	"gno.land/p/active_inference/methods"
)

func TestNewActiveInferenceAgent(t *testing.T) {
	agent := NewActiveInferenceAgent()

	if agent.CognitiveModel == nil {
		t.Error("Expected non-nil CognitiveModel")
	}

	if agent.PlanningHorizon != 3 {
		t.Errorf("Expected planning horizon 3, got %d", agent.PlanningHorizon)
	}

	if agent.TemporalDiscount != 0.95 {
		t.Errorf("Expected temporal discount 0.95, got %f", agent.TemporalDiscount)
	}

	if len(agent.CurrentObservation) != 4 {
		t.Errorf("Expected observation length 4, got %d", len(agent.CurrentObservation))
	}

	if len(agent.ActionHistory) != 0 {
		t.Error("Expected empty action history")
	}
}

func TestActiveInferenceAgentPerceive(t *testing.T) {
	agent := NewActiveInferenceAgent()

	observation := []methods.Probability{0.7, 0.3, 0.8, 0.2}

	err := agent.Perceive(observation)
	if err != nil {
		t.Errorf("Expected no error during perception, got %v", err)
	}

	// Check that observation was stored
	for i := range observation {
		if agent.CurrentObservation[i] != observation[i] {
			t.Errorf("Expected observation[%d] = %f, got %f", i, observation[i], agent.CurrentObservation[i])
		}
	}

	// Check that beliefs were updated
	if len(agent.CurrentBeliefs) != 4 {
		t.Errorf("Expected beliefs length 4, got %d", len(agent.CurrentBeliefs))
	}

	// Test invalid observation length
	invalidObservation := []methods.Probability{0.5, 0.5}
	err = agent.Perceive(invalidObservation)
	if err == nil {
		t.Error("Expected error for invalid observation length")
	}
}

func TestActiveInferenceAgentPlan(t *testing.T) {
	agent := NewActiveInferenceAgent()

	policies, err := agent.Plan()
	if err != nil {
		t.Errorf("Expected no error during planning, got %v", err)
	}

	if len(policies) == 0 {
		t.Error("Expected non-empty policies")
	}

	if len(policies) != len(agent.CurrentPolicies) {
		t.Error("Expected policies stored in agent")
	}

	// Check policy structure
	for i, policy := range policies {
		if len(policy) != 4 {
			t.Errorf("Expected policy %d length 4, got %d", i, len(policy))
		}

		// Check policy values are valid probabilities
		for j, action := range policy {
			if action < 0 || action > 1 {
				t.Errorf("Policy %d, action %d: expected probability between 0 and 1, got %f", i, j, action)
			}
		}
	}
}

func TestActiveInferenceAgentAct(t *testing.T) {
	agent := NewActiveInferenceAgent()

	// Plan first to have policies
	_, err := agent.Plan()
	if err != nil {
		t.Errorf("Expected no error during planning, got %v", err)
	}

	// Act with valid policy index
	err = agent.Act(0)
	if err != nil {
		t.Errorf("Expected no error during action, got %v", err)
	}

	// Check that action was stored in history
	if len(agent.ActionHistory) != 1 {
		t.Errorf("Expected 1 action in history, got %d", len(agent.ActionHistory))
	}

	// Test invalid policy index
	err = agent.Act(-1)
	if err == nil {
		t.Error("Expected error for invalid policy index")
	}

	err = agent.Act(len(agent.CurrentPolicies))
	if err == nil {
		t.Error("Expected error for out-of-bounds policy index")
	}
}

func TestActiveInferenceAgentLearn(t *testing.T) {
	agent := NewActiveInferenceAgent()

	// Set up some initial state
	observation := []methods.Probability{0.6, 0.4, 0.7, 0.3}
	err := agent.Perceive(observation)
	if err != nil {
		t.Errorf("Expected no error during perception, got %v", err)
	}

	// Plan and act to create history
	_, err = agent.Plan()
	if err != nil {
		t.Errorf("Expected no error during planning, got %v", err)
	}

	err = agent.Act(0)
	if err != nil {
		t.Errorf("Expected no error during action, got %v", err)
	}

	// Learn from positive reward
	reward := methods.Probability(0.8)
	err = agent.Learn(reward)
	if err != nil {
		t.Errorf("Expected no error during learning, got %v", err)
	}

	// Check that reward was stored
	if len(agent.RewardHistory) != 1 {
		t.Errorf("Expected 1 reward in history, got %d", len(agent.RewardHistory))
	}

	if agent.RewardHistory[0] != reward {
		t.Errorf("Expected reward %f, got %f", reward, agent.RewardHistory[0])
	}

	// Test learning with negative reward
	negativeReward := methods.Probability(0.2)
	err = agent.Learn(negativeReward)
	if err != nil {
		t.Errorf("Expected no error during learning, got %v", err)
	}

	if len(agent.RewardHistory) != 2 {
		t.Errorf("Expected 2 rewards in history, got %d", len(agent.RewardHistory))
	}
}

func TestActiveInferenceAgentMetrics(t *testing.T) {
	agent := NewActiveInferenceAgent()

	// Set up agent state
	observation := []methods.Probability{0.7, 0.3, 0.8, 0.2}
	agent.CurrentObservation = observation
	agent.CurrentBeliefs = []methods.Probability{0.6, 0.4, 0.7, 0.3}

	// Test expected free energy
	efe := agent.GetExpectedFreeEnergy()
	// Free energy can be any finite value
	if math.IsInf(float64(efe), 0) || math.IsNaN(float64(efe)) {
		t.Errorf("Expected finite free energy, got %f", efe)
	}

	// Test belief accuracy
	accuracy := agent.GetBeliefAccuracy()
	if accuracy < 0 || accuracy > 1 {
		t.Errorf("Expected accuracy between 0 and 1, got %f", accuracy)
	}

	// Test with mismatched lengths
	agent.CurrentBeliefs = []methods.Probability{0.5, 0.5}
	mismatchedAccuracy := agent.GetBeliefAccuracy()
	if mismatchedAccuracy != 0 {
		t.Errorf("Expected accuracy 0 for mismatched lengths, got %f", mismatchedAccuracy)
	}
}

func TestActiveInferenceAgentOptimize(t *testing.T) {
	agent := NewActiveInferenceAgent()

	// Set up observation
	observation := []methods.Probability{0.6, 0.4, 0.7, 0.3}
	agent.CurrentObservation = observation

	err := agent.Optimize()
	if err != nil {
		t.Errorf("Expected no error during optimization, got %v", err)
	}

	// Optimization should trigger memory decay and consolidation
	// We can't easily test internal state changes, but we can verify no errors
}

func TestMultiAgentSystem(t *testing.T) {
	numAgents := 3
	system := NewMultiAgentSystem(numAgents)

	if len(system.Agents) != numAgents {
		t.Errorf("Expected %d agents, got %d", numAgents, len(system.Agents))
	}

	for i, agent := range system.Agents {
		if agent == nil {
			t.Errorf("Expected non-nil agent at index %d", i)
		}
	}

	// Test coordination
	err := system.CoordinateAgents()
	if err != nil {
		t.Errorf("Expected no error during coordination, got %v", err)
	}

	// Initially no social connections, so coordination should do nothing
	// but not error
}

func TestMultiAgentSystemWithConnections(t *testing.T) {
	system := NewMultiAgentSystem(3)

	// Create social connections
	system.SocialGraph["agent0"] = []string{"agent1", "agent2"}
	system.SocialGraph["agent1"] = []string{"agent0", "agent2"}

	// Set up different observations for agents
	system.Agents[0].CurrentObservation = []methods.Probability{0.8, 0.2, 0.6, 0.4}
	system.Agents[1].CurrentObservation = []methods.Probability{0.3, 0.7, 0.9, 0.1}
	system.Agents[2].CurrentObservation = []methods.Probability{0.5, 0.5, 0.5, 0.5}

	err := system.CoordinateAgents()
	if err != nil {
		t.Errorf("Expected no error during coordination, got %v", err)
	}

	// Check that social modeling occurred
	agent0 := system.Agents[0]
	if len(agent0.SocialModel.OtherAgents) == 0 {
		t.Error("Expected agent0 to have modeled other agents")
	}
}

func TestEmergentBehaviorSystem(t *testing.T) {
	numAgents := 4
	system := NewEmergentBehaviorSystem(numAgents)

	if len(system.Agents) != numAgents {
		t.Errorf("Expected %d agents, got %d", numAgents, len(system.Agents))
	}

	// Set up agent behaviors
	for i, agent := range system.Agents {
		// Create distinct behavior patterns
		behavior := []methods.Probability{
			methods.Probability(float64(i) / float64(numAgents)),
			methods.Probability(float64(numAgents-i) / float64(numAgents)),
			0.5,
			0.5,
		}
		agent.CurrentBeliefs = behavior
	}

	// Detect emergent patterns
	system.DetectEmergentPatterns()

	// Should have detected patterns
	if len(system.EmergentPatterns) == 0 {
		t.Error("Expected to detect emergent patterns")
	}

	// Collective goals should be updated
	for _, goal := range system.CollectiveGoals {
		if goal < 0 || goal > 1 {
			t.Errorf("Expected collective goal between 0 and 1, got %f", goal)
		}
	}
}

func TestAdaptiveController(t *testing.T) {
	controller := NewAdaptiveController()

	agent := NewActiveInferenceAgent()
	initialExploration := agent.ExplorationRate
	initialHorizon := agent.PlanningHorizon

	// Test adaptation with poor performance
	for i := 0; i < 15; i++ {
		performance := methods.Probability(0.3) // Poor performance
		controller.AdaptParameters(agent, performance)
	}

	// Exploration rate should increase with poor performance
	if agent.ExplorationRate <= initialExploration {
		t.Error("Expected exploration rate to increase with poor performance")
	}

	// Test adaptation with good performance
	for i := 0; i < 25; i++ {
		performance := methods.Probability(0.8) // Good performance
		controller.AdaptParameters(agent, performance)
	}

	// Exploration rate should decrease with good performance
	if agent.ExplorationRate >= initialExploration {
		t.Error("Expected exploration rate to decrease with good performance")
	}

	// Planning horizon should potentially change with stable performance
	// (This is probabilistic and may not always change)
	if agent.PlanningHorizon < 1 || agent.PlanningHorizon > 10 {
		t.Errorf("Expected planning horizon between 1 and 10, got %d", agent.PlanningHorizon)
	}
}

func TestAdaptiveControllerVariance(t *testing.T) {
	controller := NewAdaptiveController()

	// Test variance calculation
	values := []methods.Probability{0.5, 0.6, 0.4, 0.7, 0.3}
	variance := controller.computeVariance(values)

	if variance < 0 {
		t.Errorf("Expected non-negative variance, got %f", variance)
	}

	// Test with constant values (should have zero variance)
	constantValues := []methods.Probability{0.5, 0.5, 0.5, 0.5, 0.5}
	constantVariance := controller.computeVariance(constantValues)

	if constantVariance != 0 {
		t.Errorf("Expected zero variance for constant values, got %f", constantVariance)
	}

	// Test with empty slice
	emptyVariance := controller.computeVariance([]methods.Probability{})
	if emptyVariance != 0 {
		t.Errorf("Expected zero variance for empty slice, got %f", emptyVariance)
	}
}

func TestDecisionSupportSystem(t *testing.T) {
	numModels := 3
	system := NewDecisionSupportSystem(numModels)

	if len(system.Models) != numModels {
		t.Errorf("Expected %d models, got %d", numModels, len(system.Models))
	}

	if len(system.EnsembleWeights) != numModels {
		t.Errorf("Expected %d weights, got %d", numModels, len(system.EnsembleWeights))
	}

	// Test ensemble decision
	observation := []methods.Probability{0.6, 0.4, 0.7, 0.3}

	prediction, confidence, err := system.MakeEnsembleDecision(observation)
	if err != nil {
		t.Errorf("Expected no error during ensemble decision, got %v", err)
	}

	if len(prediction) != len(observation) {
		t.Errorf("Expected prediction length %d, got %d", len(observation), len(prediction))
	}

	if confidence < 0 || confidence > 1 {
		t.Errorf("Expected confidence between 0 and 1, got %f", confidence)
	}

	// Test with no models
	emptySystem := &DecisionSupportSystem{
		Models:          []*ActiveInferenceAgent{},
		EnsembleWeights: []methods.Probability{},
	}

	_, _, err = emptySystem.MakeEnsembleDecision(observation)
	if err == nil {
		t.Error("Expected error for empty model system")
	}
}

func TestDecisionSupportSystemWeightUpdate(t *testing.T) {
	system := NewDecisionSupportSystem(2)

	// Set up different model predictions
	system.Models[0].CurrentBeliefs = []methods.Probability{0.8, 0.2, 0.6, 0.4}
	system.Models[1].CurrentBeliefs = []methods.Probability{0.3, 0.7, 0.9, 0.1}

	// Update weights with actual outcome closer to first model
	actualOutcome := []methods.Probability{0.7, 0.3, 0.5, 0.5}

	initialWeight0 := system.EnsembleWeights[0]
	system.UpdateEnsembleWeights(actualOutcome)

	// First model should have increased weight (better prediction)
	if system.EnsembleWeights[0] <= initialWeight0 {
		t.Error("Expected first model weight to increase")
	}

	// Weights should still sum to 1
	sum := methods.Probability(0)
	for _, weight := range system.EnsembleWeights {
		sum += weight
	}

	if math.Abs(float64(sum-1.0)) > 1e-6 {
		t.Errorf("Expected weights to sum to 1, got %f", sum)
	}
}

func TestIntegrationScenario(t *testing.T) {
	// Test a complete active inference scenario
	agent := NewActiveInferenceAgent()

	// Scenario: Agent learning to navigate towards rewarding states
	scenarios := []struct {
		observation []methods.Probability
		reward      methods.Probability
	}{
		{[]methods.Probability{0.9, 0.1, 0.8, 0.2}, 0.8}, // High reward state
		{[]methods.Probability{0.2, 0.8, 0.3, 0.7}, 0.2}, // Low reward state
		{[]methods.Probability{0.7, 0.3, 0.6, 0.4}, 0.6}, // Medium reward state
		{[]methods.Probability{0.8, 0.2, 0.9, 0.1}, 0.9}, // Very high reward state
	}

	for _, scenario := range scenarios {
		// Perceive
		err := agent.Perceive(scenario.observation)
		if err != nil {
			t.Errorf("Expected no error during perception, got %v", err)
		}

		// Plan
		_, err = agent.Plan()
		if err != nil {
			t.Errorf("Expected no error during planning, got %v", err)
		}

		// Act (choose first policy for simplicity)
		err = agent.Act(0)
		if err != nil {
			t.Errorf("Expected no error during action, got %v", err)
		}

		// Learn
		err = agent.Learn(scenario.reward)
		if err != nil {
			t.Errorf("Expected no error during learning, got %v", err)
		}

		// Optimize
		err = agent.Optimize()
		if err != nil {
			t.Errorf("Expected no error during optimization, got %v", err)
		}
	}

	// Verify learning occurred
	if len(agent.RewardHistory) != len(scenarios) {
		t.Errorf("Expected %d rewards in history, got %d", len(scenarios), len(agent.RewardHistory))
	}

	if len(agent.ActionHistory) != len(scenarios) {
		t.Errorf("Expected %d actions in history, got %d", len(scenarios), len(agent.ActionHistory))
	}
}

func TestPolicyGeneration(t *testing.T) {
	agent := NewActiveInferenceAgent()

	// Test policy generation
	policy := agent.generatePolicy()

	if len(policy) != 4 {
		t.Errorf("Expected policy length 4, got %d", len(policy))
	}

	for i, action := range policy {
		if action < 0 || action > 1 {
			t.Errorf("Policy action %d: expected between 0 and 1, got %f", i, action)
		}
	}

	// Generate multiple policies to ensure variety
	policy2 := agent.generatePolicy()

	// Policies should be different (with high probability)
	different := false
	for i := range policy {
		if policy[i] != policy2[i] {
			different = true
			break
		}
	}

	if !different {
		t.Error("Expected different policies on multiple generations")
	}
}

func TestFreeEnergyTracking(t *testing.T) {
	agent := NewActiveInferenceAgent()

	// Generate some free energy history
	for i := 0; i < 5; i++ {
		observation := []methods.Probability{
			methods.Probability(float64(i) / 5.0),
			methods.Probability(float64(5-i) / 5.0),
			0.5,
			0.5,
		}

		err := agent.Perceive(observation)
		if err != nil {
			t.Errorf("Expected no error during perception %d, got %v", i, err)
		}
	}

	// Should have free energy history
	if len(agent.FreeEnergyHistory) == 0 {
		t.Error("Expected non-empty free energy history")
	}

	// All free energy values should be finite
	for i, fe := range agent.FreeEnergyHistory {
		if math.IsInf(float64(fe), 0) || math.IsNaN(float64(fe)) {
			t.Errorf("Free energy %d: expected finite value, got %f", i, fe)
		}
	}

	// Test history bounding
	for i := 0; i < 1000; i++ {
		observation := []methods.Probability{0.5, 0.5, 0.5, 0.5}
		agent.Perceive(observation)
	}

	// History should be bounded to reasonable size
	if len(agent.FreeEnergyHistory) > 1001 {
		t.Errorf("Expected bounded free energy history, got length %d", len(agent.FreeEnergyHistory))
	}
}
