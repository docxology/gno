// Package active_inference_core_test provides comprehensive tests for active inference core methods
package active_inference_core

import (
	"math"
	"gno.land/p/active_inference/methods"
)

// Test suite for Active Inference Core functionality
func runActiveInferenceTests() {
	println("🧠 Running Active Inference Core Tests")

	testAgentCreation()
	testPerception()
	testPlanning()
	testAction()
	testLearning()
	testMultiAgent()
	testEdgeCases()

	println("✅ Active Inference Core Tests Complete")
}

// Test agent creation and initialization
func testAgentCreation() {
	println("Testing agent creation...")

	agent := NewActiveInferenceAgent()
	if agent == nil {
		println("FAIL: NewActiveInferenceAgent returned nil")
		return
	}

	// Check initial state
	if len(agent.CurrentBeliefs) == 0 {
		println("FAIL: Agent should have initial beliefs")
		return
	}

	if agent.GoalSystem == nil {
		println("FAIL: Agent should have goal system")
		return
	}

	if agent.SocialModel == nil {
		println("FAIL: Agent should have social model")
		return
	}

	println("PASS: Agent creation successful")
}

// Test perception functionality
func testPerception() {
	println("Testing perception...")

	agent := NewActiveInferenceAgent()

	// Test valid perception
	observation := []methods.Probability{0.8, 0.6, 0.4, 0.7}
	err := agent.Perceive(observation)
	if err != nil {
		println("FAIL: Valid perception failed:", err.Error())
		return
	}

	// Check that beliefs were updated
	if len(agent.CurrentBeliefs) != len(observation) {
		println("FAIL: Belief length mismatch")
		return
	}

	// Test invalid perception
	invalidObs := []methods.Probability{1.5, 0.5} // Invalid probability
	err = agent.Perceive(invalidObs)
	if err == nil {
		println("FAIL: Invalid perception should have failed")
		return
	}

	println("PASS: Perception tests passed")
}

// Test planning functionality
func testPlanning() {
	println("Testing planning...")

	agent := NewActiveInferenceAgent()

	// Set up agent state
	observation := []methods.Probability{0.7, 0.3, 0.8, 0.2}
	agent.Perceive(observation)

	// Test planning
	policies, err := agent.Plan()
	if err != nil {
		println("FAIL: Planning failed:", err.Error())
		return
	}

	if len(policies) == 0 {
		println("FAIL: Planning should generate policies")
		return
	}

	// Test policy quality
	for i, policy := range policies {
		if len(policy.Actions) == 0 {
			println("FAIL: Policy", i, "has no actions")
			return
		}
	}

	println("PASS: Planning tests passed")
}

// Test action execution
func testAction() {
	println("Testing action execution...")

	agent := NewActiveInferenceAgent()

	// Set up agent state
	observation := []methods.Probability{0.6, 0.4, 0.7, 0.3}
	agent.Perceive(observation)

	// Plan actions
	policies, err := agent.Plan()
	if err != nil {
		println("FAIL: Planning failed during action test:", err.Error())
		return
	}

	if len(policies) == 0 {
		println("FAIL: No policies available for action test")
		return
	}

	// Execute action
	err = agent.Act(0) // Execute first policy
	if err != nil {
		println("FAIL: Action execution failed:", err.Error())
		return
	}

	println("PASS: Action execution tests passed")
}

// Test learning functionality
func testLearning() {
	println("Testing learning...")

	agent := NewActiveInferenceAgent()

	// Initial state
	initialAccuracy := agent.GetBeliefAccuracy()

	// Learning episode
	observation := []methods.Probability{0.8, 0.2, 0.9, 0.1}
	agent.Perceive(observation)
	agent.Plan()
	agent.Act(0)

	// Positive feedback
	reward := methods.Probability(1.0)
	err := agent.Learn(reward)
	if err != nil {
		println("FAIL: Learning failed:", err.Error())
		return
	}

	// Check improvement
	finalAccuracy := agent.GetBeliefAccuracy()
	if finalAccuracy <= initialAccuracy {
		println("FAIL: Learning should improve accuracy")
		return
	}

	// Test negative feedback
	agent.Learn(methods.Probability(0.0)) // No reward
	newAccuracy := agent.GetBeliefAccuracy()
	if newAccuracy > finalAccuracy {
		println("FAIL: Negative feedback should decrease accuracy")
		return
	}

	println("PASS: Learning tests passed")
}

// Test multi-agent functionality
func testMultiAgent() {
	println("Testing multi-agent coordination...")

	system := NewMultiAgentSystem(3)

	if len(system.Agents) != 3 {
		println("FAIL: Multi-agent system should have 3 agents")
		return
	}

	// Test social connections
	system.SocialGraph["agent0"] = []string{"agent1", "agent2"}
	system.SocialGraph["agent1"] = []string{"agent0", "agent2"}
	system.SocialGraph["agent2"] = []string{"agent0", "agent1"}

	// Test coordination
	for i, agent := range system.Agents {
		observation := []methods.Probability{
			methods.Probability(0.5 + 0.1*float64(i)),
			methods.Probability(0.3 + 0.1*float64(i)),
		}
		agent.Perceive(observation)
		agent.GoalSystem.SetGoal(0, methods.Probability(0.6 + 0.1*float64(i)))
	}

	err := system.CoordinateAgents()
	if err != nil {
		println("FAIL: Multi-agent coordination failed:", err.Error())
		return
	}

	println("PASS: Multi-agent coordination tests passed")
}

// Test edge cases and error conditions
func testEdgeCases() {
	println("Testing edge cases...")

	agent := NewActiveInferenceAgent()

	// Test empty observation
	err := agent.Perceive([]methods.Probability{})
	if err == nil {
		println("FAIL: Empty observation should fail")
		return
	}

	// Test extreme probabilities
	extremeObs := []methods.Probability{0.0, 1.0, 0.0, 1.0}
	err = agent.Perceive(extremeObs)
	if err != nil {
		println("FAIL: Extreme probabilities should be valid")
		return
	}

	// Test planning with no prior perception
	agent2 := NewActiveInferenceAgent()
	policies, err := agent2.Plan()
	if err != nil {
		println("FAIL: Planning should work without prior perception")
		return
	}

	// Test action out of bounds
	err = agent2.Act(999) // Invalid policy index
	if err == nil {
		println("FAIL: Invalid action index should fail")
		return
	}

	// Test learning with invalid reward
	err = agent.Learn(methods.Probability(1.5)) // Invalid reward
	if err == nil {
		println("FAIL: Invalid reward should fail")
		return
	}

	println("PASS: Edge case tests passed")
}

// Main test execution
func main() {
	runActiveInferenceTests()
}
