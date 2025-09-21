// Package reinforcement_learning_test provides comprehensive tests for reinforcement learning methods
package reinforcement_learning

import (
	"math"
	"testing"
	"gno.land/p/active_inference/methods"
)

func TestQLearningAgent(t *testing.T) {
	actions := []string{"left", "right", "up", "down"}
	agent := NewQLearningAgent(actions)

	// Test initial state
	if len(agent.QTable) != 0 {
		t.Error("Q-table should be empty initially")
	}

	// Test Q-value operations
	state := "state1"
	action := "left"

	// Initial Q-value should be 0
	qValue := agent.GetQValue(state, action)
	if qValue != 0 {
		t.Errorf("Initial Q-value should be 0, got %f", qValue)
	}

	// Set Q-value
	agent.SetQValue(state, action, 0.5)
	qValue = agent.GetQValue(state, action)
	if qValue != 0.5 {
		t.Errorf("Q-value should be 0.5, got %f", qValue)
	}

	// Test action selection
	selectedAction := agent.ChooseAction(state)
	if !contains(actions, selectedAction) {
		t.Errorf("Selected action %s not in action list", selectedAction)
	}

	// Test learning update
	nextState := "state2"
	reward := methods.Probability(1.0)

	oldQ := agent.GetQValue(state, action)
	agent.Update(state, action, nextState, reward)
	newQ := agent.GetQValue(state, action)

	// Q-value should increase after positive reward
	if newQ <= oldQ {
		t.Error("Q-value should increase after positive reward")
	}

	// Test exploration decay
	initialExploration := agent.ExplorationRate
	for i := 0; i < 10; i++ {
		agent.Update(state, action, nextState, 0.1)
	}

	if agent.ExplorationRate >= initialExploration {
		t.Error("Exploration rate should decay over time")
	}

	if agent.ExplorationRate < agent.MinExplorationRate {
		t.Error("Exploration rate should not go below minimum")
	}
}

func TestQLearningConvergence(t *testing.T) {
	actions := []string{"A", "B"}
	agent := NewQLearningAgent(actions)

	// Simple deterministic environment
	// State "S1": Action "A" -> reward 1, state "S1"
	// State "S1": Action "B" -> reward 0, state "S2"
	// State "S2": Action "A" -> reward 0, state "S2"
	// State "S2": Action "B" -> reward 1, state "S2"

	// Train for multiple episodes
	for episode := 0; episode < 100; episode++ {
		state := "S1"

		for step := 0; step < 10; step++ {
			action := agent.ChooseAction(state)
			var reward methods.Probability
			var nextState string

			if state == "S1" {
				if action == "A" {
					reward = 1.0
					nextState = "S1"
				} else {
					reward = 0.0
					nextState = "S2"
				}
			} else { // S2
				if action == "B" {
					reward = 1.0
					nextState = "S2"
				} else {
					reward = 0.0
					nextState = "S2"
				}
			}

			agent.Update(state, action, nextState, reward)
			state = nextState
		}
	}

	// Check if agent learned optimal policy
	bestActionS1 := agent.GetBestAction("S1")
	bestActionS2 := agent.GetBestAction("S2")

	if bestActionS1 != "A" {
		t.Errorf("Optimal action for S1 should be 'A', got '%s'", bestActionS1)
	}

	if bestActionS2 != "B" {
		t.Errorf("Optimal action for S2 should be 'B', got '%s'", bestActionS2)
	}

	// Check Q-values
	qS1A := agent.GetQValue("S1", "A")
	qS1B := agent.GetQValue("S1", "B")
	qS2A := agent.GetQValue("S2", "A")
	qS2B := agent.GetQValue("S2", "B")

	if qS1A <= qS1B {
		t.Error("Q(S1,A) should be higher than Q(S1,B)")
	}

	if qS2B <= qS2A {
		t.Error("Q(S2,B) should be higher than Q(S2,A)")
	}
}

func TestSarsaAgent(t *testing.T) {
	actions := []string{"left", "right"}
	agent := NewSarsaAgent(actions)

	// Test initial state
	if len(agent.QTable) != 0 {
		t.Error("Q-table should be empty initially")
	}

	// Test episode execution
	initialState := "start"
	firstAction := agent.StartEpisode(initialState)

	if !contains(actions, firstAction) {
		t.Errorf("First action %s not in action list", firstAction)
	}

	// Test step updates
	nextState := "middle"
	reward := methods.Probability(0.5)
	nextAction := agent.Step(nextState, firstAction, reward)

	if !contains(actions, nextAction) {
		t.Errorf("Next action %s not in action list", nextAction)
	}

	// Test episode end
	finalReward := methods.Probability(1.0)
	agent.EndEpisode(finalReward)

	// Verify Q-values were updated
	if len(agent.QTable) == 0 {
		t.Error("Q-table should contain learned values")
	}
}

func TestPolicyGradientAgent(t *testing.T) {
	actions := []string{"left", "right", "up", "down"}
	agent := NewPolicyGradientAgent(actions)

	// Test initial policy
	state := "room1"
	probs := agent.GetActionProbabilities(state)

	if len(probs) != len(actions) {
		t.Errorf("Policy should have %d probabilities, got %d", len(actions), len(probs))
	}

	// Check uniform initial policy
	expectedProb := methods.Probability(1.0 / float64(len(actions)))
	for i, prob := range probs {
		if math.Abs(float64(prob-expectedProb)) > 0.01 {
			t.Errorf("Initial probability for action %d should be %.3f, got %.3f",
				i, expectedProb, prob)
		}
	}

	// Test action selection
	selectedAction := agent.ChooseAction(state)
	if !contains(actions, selectedAction) {
		t.Errorf("Selected action %s not in action list", selectedAction)
	}

	// Test trajectory storage
	reward := methods.Probability(1.0)
	agent.StoreTransition(state, selectedAction, reward)

	if len(agent.Trajectory) != 1 {
		t.Errorf("Trajectory should have 1 step, got %d", len(agent.Trajectory))
	}

	// Test policy update
	agent.UpdatePolicy()

	if len(agent.Trajectory) != 0 {
		t.Error("Trajectory should be cleared after policy update")
	}
}

func TestPolicyGradientLearning(t *testing.T) {
	actions := []string{"good", "bad"}
	agent := NewPolicyGradientAgent(actions)

	// Simulate learning scenario
	// "good" action always gives reward 1, "bad" action gives reward 0
	state := "decision_point"

	for episode := 0; episode < 50; episode++ {
		action := agent.ChooseAction(state)

		var reward methods.Probability
		if action == "good" {
			reward = 1.0
		} else {
			reward = 0.0
		}

		agent.StoreTransition(state, action, reward)
		agent.UpdatePolicy()
	}

	// Check if agent learned to prefer "good" action
	probs := agent.GetActionProbabilities(state)
	goodIndex := indexOf(actions, "good")

	if goodIndex == -1 {
		t.Fatal("Could not find 'good' action")
	}

	// Probability of good action should be higher than random (0.5)
	if probs[goodIndex] <= 0.5 {
		t.Errorf("Probability of 'good' action should be > 0.5, got %.3f", probs[goodIndex])
	}
}

func TestActorCriticAgent(t *testing.T) {
	actions := []string{"accelerate", "brake", "steer_left", "steer_right"}
	agent := NewActorCriticAgent(actions)

	// Test initial state
	state := "intersection"
	probs := agent.GetActionProbabilities(state)

	if len(probs) != len(actions) {
		t.Errorf("Actor should have %d action probabilities, got %d", len(actions), len(probs))
	}

	value := agent.GetValue(state)
	if value != 0 {
		t.Errorf("Initial value should be 0, got %f", value)
	}

	// Test episode execution
	firstAction := agent.StartEpisode(state)
	if !contains(actions, firstAction) {
		t.Errorf("First action %s not in action list", firstAction)
	}

	// Test step updates
	nextState := "road"
	reward := methods.Probability(0.8)
	nextAction := agent.Step(nextState, firstAction, reward)

	if !contains(actions, nextAction) {
		t.Errorf("Next action %s not in action list", nextAction)
	}

	// Test episode end
	finalReward := methods.Probability(0.5)
	agent.EndEpisode(finalReward)

	// Verify learning occurred
	if len(agent.ActorNetwork) == 0 {
		t.Error("Actor network should contain learned policies")
	}

	if len(agent.CriticNetwork) == 0 {
		t.Error("Critic network should contain learned values")
	}
}

func TestMultiArmedBandit(t *testing.T) {
	arms := []string{"slot1", "slot2", "slot3"}
	algorithms := []string{"epsilon-greedy", "ucb", "thompson"}

	for _, algorithm := range algorithms {
		t.Run(algorithm, func(t *testing.T) {
			bandit := NewMultiArmedBandit(arms, algorithm)

			// Test initial state
			if len(bandit.Counts) != len(arms) {
				t.Errorf("Bandit should track %d arms, got %d", len(arms), len(bandit.Counts))
			}

			for _, arm := range arms {
				if bandit.Counts[arm] != 0 {
					t.Errorf("Initial count for %s should be 0, got %d", arm, bandit.Counts[arm])
				}
			}

			// Test arm selection
			selectedArm := bandit.SelectArm()
			if !contains(arms, selectedArm) {
				t.Errorf("Selected arm %s not in arm list", selectedArm)
			}

			// Test updates
			reward := methods.Probability(1.0)
			bandit.Update(selectedArm, reward)

			if bandit.Counts[selectedArm] != 1 {
				t.Errorf("Count for %s should be 1 after update, got %d",
					selectedArm, bandit.Counts[selectedArm])
			}

			if bandit.TotalPulls != 1 {
				t.Errorf("Total pulls should be 1, got %d", bandit.TotalPulls)
			}
		})
	}
}

func TestBanditLearning(t *testing.T) {
	arms := []string{"good", "bad"}
	bandit := NewMultiArmedBandit(arms, "epsilon-greedy")

	// Simulate learning: "good" arm gives reward 0.8, "bad" arm gives reward 0.2
	for i := 0; i < 100; i++ {
		selectedArm := bandit.SelectArm()

		var reward methods.Probability
		if selectedArm == "good" {
			reward = 0.8
		} else {
			reward = 0.2
		}

		bandit.Update(selectedArm, reward)
	}

	// Check if bandit learned to prefer "good" arm
	bestArm := bandit.GetBestArm()
	if bestArm != "good" {
		t.Errorf("Bandit should learn to prefer 'good' arm, got '%s'", bestArm)
	}

	goodValue := bandit.Values["good"]
	badValue := bandit.Values["bad"]

	if goodValue <= badValue {
		t.Errorf("Good arm value (%.3f) should be higher than bad arm value (%.3f)",
			goodValue, badValue)
	}
}

func TestReinforcementLearningIntegration(t *testing.T) {
	// Test integration of different RL algorithms

	actions := []string{"north", "south", "east", "west"}
	state := "maze_start"

	// Create different agents
	qAgent := NewQLearningAgent(actions)
	sarsaAgent := NewSarsaAgent(actions)
	pgAgent := NewPolicyGradientAgent(actions)
	acAgent := NewActorCriticAgent(actions)

	agents := []interface{ ChooseAction(string) string }{
		qAgent, sarsaAgent, pgAgent, acAgent,
	}

	// All agents should be able to select actions
	for i, agent := range agents {
		action := agent.ChooseAction(state)
		if !contains(actions, action) {
			t.Errorf("Agent %d selected invalid action: %s", i, action)
		}
	}

	// Test Q-learning specific operations
	qAgent.SetQValue(state, "north", 1.0)
	qValue := qAgent.GetQValue(state, "north")
	if qValue != 1.0 {
		t.Errorf("Q-learning agent Q-value should be 1.0, got %f", qValue)
	}

	// Test policy gradient specific operations
	pgProbs := pgAgent.GetActionProbabilities(state)
	if len(pgProbs) != len(actions) {
		t.Errorf("Policy gradient agent should have %d probabilities, got %d",
			len(actions), len(pgProbs))
	}

	// Test actor-critic specific operations
	acValue := acAgent.GetValue(state)
	if acValue != 0 {
		t.Errorf("Actor-critic initial value should be 0, got %f", acValue)
	}
}

func TestExplorationExploitationTradeoff(t *testing.T) {
	actions := []string{"explore", "exploit"}
	agent := NewQLearningAgent(actions)

	// Set up scenario where exploitation should eventually dominate
	state := "decision"

	// Train agent with consistent rewards
	for episode := 0; episode < 50; episode++ {
		action := agent.ChooseAction(state)

		var reward methods.Probability
		if action == "exploit" {
			reward = 1.0 // Exploitation is always better
		} else {
			reward = 0.1 // Exploration gives small reward
		}

		agent.Update(state, action, state, reward)
	}

	// Later episodes should prefer exploitation
	exploitCount := 0
	for i := 0; i < 20; i++ {
		action := agent.ChooseAction(state)
		if action == "exploit" {
			exploitCount++
		}
	}

	// Should prefer exploitation at least 80% of the time
	exploitRate := float64(exploitCount) / 20.0
	if exploitRate < 0.8 {
		t.Errorf("Agent should prefer exploitation (%.1f%%), got %.1f%%",
			80.0, exploitRate*100)
	}
}

func TestTemporalCreditAssignment(t *testing.T) {
	actions := []string{"immediate", "delayed"}
	agent := NewQLearningAgent(actions)

	// Test delayed reward scenario
	// Action "immediate" gives immediate small reward
	// Action "delayed" gives large reward after delay

	state := "choice"
	steps := 0

	for episode := 0; episode < 20; episode++ {
		currentState := state
		steps = 0

		for steps < 10 {
			action := agent.ChooseAction(currentState)

			var reward methods.Probability
			var nextState string

			if action == "immediate" {
				reward = 0.5
				nextState = "end"
			} else { // delayed
				if steps < 3 {
					reward = 0.0
					nextState = "delayed_" + string(rune(steps+1))
				} else {
					reward = 2.0 // Large delayed reward
					nextState = "end"
				}
			}

			agent.Update(currentState, action, nextState, reward)
			currentState = nextState
			steps++

			if currentState == "end" {
				break
			}
		}
	}

	// Agent should learn to prefer delayed reward
	delayedQ := agent.GetQValue(state, "delayed")
	immediateQ := agent.GetQValue(state, "immediate")

	if delayedQ <= immediateQ {
		t.Errorf("Agent should prefer delayed reward (%.3f) over immediate (%.3f)",
			delayedQ, immediateQ)
	}
}

// Helper functions
func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

func indexOf(slice []string, item string) int {
	for i, s := range slice {
		if s == item {
			return i
		}
	}
	return -1
}
