// Package social_coordination_example demonstrates multi-agent coordination using active inference
//
// This example shows how to:
// - Create multiple active inference agents
// - Implement social coordination mechanisms
// - Model theory of mind and social cognition
// - Demonstrate emergent collective behavior
//
// This is a thin orchestrator that integrates social cognition methods.
package social_coordination_example

import (
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
	"gno.land/p/active_inference/methods/cognitive_modeling"
	"gno.land/p/active_inference/methods/active_inference_core"
)

// SocialCoordinationExample demonstrates multi-agent coordination scenarios
type SocialCoordinationExample struct {
	System     *active_inference_core.MultiAgentSystem
	Emergent   *active_inference_core.EmergentBehaviorSystem
	TaskGoals  []methods.Probability
	TimeStep   int
}

// NewSocialCoordinationExample creates a new social coordination scenario
func NewSocialCoordinationExample() *SocialCoordinationExample {
	// Create multi-agent system
	system := active_inference_core.NewMultiAgentSystem(5) // 5 agents

	// Create emergent behavior system
	emergent := active_inference_core.NewEmergentBehaviorSystem(5)

	// Set up social connections (social network)
	system.SocialGraph["agent0"] = []string{"agent1", "agent2"}
	system.SocialGraph["agent1"] = []string{"agent0", "agent3", "agent4"}
	system.SocialGraph["agent2"] = []string{"agent0", "agent3"}
	system.SocialGraph["agent3"] = []string{"agent1", "agent2", "agent4"}
	system.SocialGraph["agent4"] = []string{"agent1", "agent3"}

	// Set task goals (collective objectives)
	taskGoals := []methods.Probability{0.8, 0.6, 0.7, 0.5, 0.9} // Different goals for agents

	return &SocialCoordinationExample{
		System:    system,
		Emergent:  emergent,
		TaskGoals: taskGoals,
		TimeStep:  0,
	}
}

// RunCoordinationRound executes one round of social coordination
func (sce *SocialCoordinationExample) RunCoordinationRound(sharedObservation []methods.Probability) string {
	result := ufmt.Sprintf("## Coordination Round %d\n\n", sce.TimeStep+1)

	// Each agent perceives the shared observation
	for i, agent := range sce.System.Agents {
		// Add some individual variation to the shared observation
		individualObs := make([]methods.Probability, len(sharedObservation))
		for j, val := range sharedObservation {
			// Add noise based on agent index
			noise := methods.Probability(float64(i) * 0.1)
			individualObs[j] = methods.Probability(float64(val) + float64(noise))
			if individualObs[j] > 1.0 {
				individualObs[j] = 1.0
			}
			if individualObs[j] < 0.0 {
				individualObs[j] = 0.0
			}
		}

		err := agent.Perceive(individualObs)
		if err != nil {
			result += ufmt.Sprintf("Agent %d perception error: %v\n", i, err)
			continue
		}

		// Set individual goals
		if i < len(sce.TaskGoals) {
			agent.GoalSystem.SetGoal(0, sce.TaskGoals[i])
		}

		// Plan
		policies, err := agent.Plan()
		if err != nil {
			result += ufmt.Sprintf("Agent %d planning error: %v\n", i, err)
			continue
		}

		// Select action (simplified - choose first policy)
		err = agent.Act(0)
		if err != nil {
			result += ufmt.Sprintf("Agent %d action error: %v\n", i, err)
			continue
		}

		result += ufmt.Sprintf("Agent %d: Goal=%.2f, Action=%s\n",
			i, sce.TaskGoals[i], agent.policiesToAction(0))
	}

	result += "\n"

	// Coordinate agents socially
	err := sce.System.CoordinateAgents()
	if err != nil {
		result += ufmt.Sprintf("Coordination error: %v\n", err)
	}

	// Detect emergent patterns
	sce.Emergent.DetectEmergentPatterns()

	result += "### Emergent Collective Goals:\n"
	for i, goal := range sce.Emergent.CollectiveGoals {
		result += ufmt.Sprintf("  Goal %d: %.3f\n", i, goal)
	}

	result += "\n### Social Trust Levels:\n"
	for i, agent := range sce.System.Agents {
		agentID := ufmt.Sprintf("agent%d", i)
		trustLevels := make([]string, 0)

		for j := range sce.System.Agents {
			if i != j {
				otherID := ufmt.Sprintf("agent%d", j)
				trust := agent.SocialModel.GetTrustLevel(otherID)
				trustLevels = append(trustLevels,
					ufmt.Sprintf("A%d:%.2f", j, trust))
			}
		}

		trustStr := "["
		for j, trust := range trustLevels {
			if j > 0 {
				trustStr += ", "
			}
			trustStr += trust
		}
		trustStr += "]"
		result += ufmt.Sprintf("Agent %d trust: %s\n", i, trustStr)
	}

	sce.TimeStep++
	return result
}

// DemonstrateTheoryOfMind shows how agents model each other's mental states
func (sce *SocialCoordinationExample) DemonstrateTheoryOfMind() string {
	result := "# Theory of Mind Demonstration\n\n"

	// Agent 0 observes Agent 1's behavior
	agent0 := sce.System.Agents[0]
	agent1 := sce.System.Agents[1]

	// Agent 1 performs an action that reveals its goals
	agent1Action := []methods.Probability{0.9, 0.1, 0.8, 0.2} // Strong action towards goal 0

	// Agent 0 models Agent 1's behavior
	agent0.SocialModel.ModelAgent("agent1", agent1Action)

	result += "## Agent 0's Model of Agent 1\n"
	result += ufmt.Sprintf("Observed action: [%.2f, %.2f, %.2f, %.2f]\n",
		agent1Action[0], agent1Action[1], agent1Action[2], agent1Action[3])

	// Agent 0 infers Agent 1's beliefs and goals
	inferredBeliefs := agent0.SocialModel.OtherAgents["agent1"].Beliefs
	inferredGoals := agent0.SocialModel.OtherAgents["agent1"].Goals

	result += "Inferred beliefs: "
	for _, belief := range inferredBeliefs {
		result += ufmt.Sprintf("%.2f ", belief)
	}
	result += "\n"

	result += "Inferred goals: "
	for _, goal := range inferredGoals {
		result += ufmt.Sprintf("%.2f ", goal)
	}
	result += "\n"

	// Agent 0 predicts Agent 1's next action
	prediction := agent0.SocialModel.PredictAction("agent1")
	result += "Predicted next action: "
	for _, pred := range prediction {
		result += ufmt.Sprintf("%.2f ", pred)
	}
	result += "\n"

	// Trust level
	trust := agent0.SocialModel.GetTrustLevel("agent1")
	result += ufmt.Sprintf("Trust level: %.2f\n", trust)

	return result
}

// DemonstrateCollectiveDecisionMaking shows how agents make collective decisions
func (sce *SocialCoordinationExample) DemonstrateCollectiveDecisionMaking() string {
	result := "# Collective Decision Making\n\n"

	// Simulate a decision scenario
	decisionContext := []methods.Probability{0.7, 0.3, 0.8, 0.2} // Shared decision context

	result += ufmt.Sprintf("Decision context: [%.2f, %.2f, %.2f, %.2f]\n\n",
		decisionContext[0], decisionContext[1], decisionContext[2], decisionContext[3])

	// Each agent evaluates the decision
	individualDecisions := make([]methods.Probability, len(sce.System.Agents))

	for i, agent := range sce.System.Agents {
		err := agent.Perceive(decisionContext)
		if err != nil {
			continue
		}

		// Agent's decision based on its goals and beliefs
		decisionValue := methods.Probability(0)
		for j, goal := range agent.GoalSystem.Goals {
			if j < len(agent.CurrentBeliefs) {
				decisionValue += goal * agent.CurrentBeliefs[j]
			}
		}
		decisionValue /= methods.Probability(len(agent.GoalSystem.Goals))

		individualDecisions[i] = decisionValue
		result += ufmt.Sprintf("Agent %d decision value: %.3f\n", i, decisionValue)
	}

	// Calculate collective decision
	collectiveDecision := methods.Probability(0)
	for _, decision := range individualDecisions {
		collectiveDecision += decision
	}
	collectiveDecision /= methods.Probability(len(individualDecisions))

	result += ufmt.Sprintf("\nCollective decision: %.3f\n", collectiveDecision)

	// Consensus analysis
	agreement := sce.calculateConsensus(individualDecisions)
	result += ufmt.Sprintf("Consensus level: %.3f (higher = more agreement)\n", agreement)

	return result
}

// calculateConsensus computes agreement level among agents
func (sce *SocialCoordinationExample) calculateConsensus(decisions []methods.Probability) methods.Probability {
	if len(decisions) == 0 {
		return 0
	}

	mean := methods.Probability(0)
	for _, d := range decisions {
		mean += d
	}
	mean /= methods.Probability(len(decisions))

	variance := methods.Probability(0)
	for _, d := range decisions {
		diff := d - mean
		variance += diff * diff
	}
	variance /= methods.Probability(len(decisions))

	// Convert variance to consensus (lower variance = higher consensus)
	consensus := methods.Probability(1.0) / (methods.Probability(1.0) + variance)
	return consensus
}

// RunSocialCoordinationSimulation runs a complete social coordination simulation
func RunSocialCoordinationSimulation() string {
	example := NewSocialCoordinationExample()

	result := "# Active Inference: Social Coordination Example\n\n"
	result += "This example demonstrates multi-agent coordination using active inference.\n\n"

	// Scenario 1: Initial coordination
	result += "## Scenario 1: Team Formation\n"
	sharedObservation1 := []methods.Probability{0.6, 0.4, 0.5, 0.5} // Neutral initial state
	result += example.RunCoordinationRound(sharedObservation1)

	// Scenario 2: Task assignment
	result += "## Scenario 2: Task Assignment\n"
	sharedObservation2 := []methods.Probability{0.8, 0.2, 0.3, 0.7} // Task-related cues
	result += example.RunCoordinationRound(sharedObservation2)

	// Scenario 3: Conflict resolution
	result += "## Scenario 3: Conflict Resolution\n"
	sharedObservation3 := []methods.Probability{0.9, 0.1, 0.1, 0.9} // Conflicting goals
	result += example.RunCoordinationRound(sharedObservation3)

	result += "\n" + example.DemonstrateTheoryOfMind()
	result += "\n" + example.DemonstrateCollectiveDecisionMaking()

	result += "\n## Key Insights\n\n"
	result += "- **Social Learning**: Agents learn from each other's behavior\n"
	result += "- **Trust Dynamics**: Trust levels evolve based on observed consistency\n"
	result += "- **Emergent Coordination**: Collective goals emerge from individual interactions\n"
	result += "- **Theory of Mind**: Agents model and predict each other's mental states\n"
	result += "- **Consensus Formation**: Group decisions balance individual preferences\n\n"

	result += "This demonstrates how active inference enables sophisticated social cognition\n"
	result += "and coordination in multi-agent systems on the blockchain.\n"

	return result
}
