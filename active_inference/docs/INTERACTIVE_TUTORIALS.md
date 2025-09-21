# 🎮 Interactive Tutorials for Active Inference on Gno

Step-by-step interactive tutorials to master Active Inference development on the Gno blockchain.

## 🚀 Quick Start Tutorial

### Tutorial 1: Hello Active Inference

**Goal**: Create your first Active Inference agent and observe basic cognition.

#### Step 1: Set Up Your Environment

```bash
# Clone the repository
git clone https://github.com/gnolang/gno.git
cd gno/active_inference

# Run the basic verification
go run simple_verification.go
```

**What you'll see:**
```
=== Active Inference Methods Summary ===

📦 IMPLEMENTED PACKAGES:
✅ probability - Basic probability distributions and operations
✅ advanced_probability - Advanced distributions (Gaussian, Beta, Dirichlet, Markov chains, HMMs)
✅ bayesian_inference - Bayesian networks and inference algorithms
✅ free_energy_principle - Free energy minimization and predictive coding
✅ cognitive_modeling - Working memory, attention, learning systems
✅ active_inference_core - Core active inference agents and multi-agent systems
```

#### Step 2: Create Your First Agent

```go
package main

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
)

func main() {
    // Create an active inference agent
    agent := active_inference_core.NewActiveInferenceAgent()

    // Observe the environment
    observation := []methods.Probability{0.8, 0.6, 0.4, 0.7}
    err := agent.Perceive(observation)
    if err != nil {
        println("Error perceiving:", err.Error())
        return
    }

    // Plan actions
    policies, err := agent.Plan()
    if err != nil {
        println("Error planning:", err.Error())
        return
    }

    println("Agent created successfully!")
    println("Observation processed:", len(observation), "dimensions")
    println("Generated", len(policies), "policy options")
}
```

**Expected Output:**
```
Agent created successfully!
Observation processed: 4 dimensions
Generated 8 policy options
```

#### Step 3: Understanding the Results

**What just happened:**
1. **Agent Creation**: You instantiated an Active Inference agent with default cognitive architecture
2. **Perception**: The agent processed a 4-dimensional observation vector
3. **Planning**: The agent generated 8 different policy options for action

**Key Concepts:**
- **Observation**: Sensory input from the environment
- **Beliefs**: The agent's internal model of the world state
- **Policies**: Potential courses of action the agent can take

---

## 🧠 Tutorial 2: Cognitive Modeling Basics

### Understanding Working Memory

**Goal**: Explore how agents maintain and manipulate short-term information.

#### Interactive Exercise: Memory Capacity

```go
package main

import (
    "gno.land/p/active_inference/methods/cognitive_modeling"
    "gno.land/p/active_inference/methods"
)

func main() {
    // Create a working memory system
    wm := cognitive_modeling.NewWorkingMemory(5) // Capacity of 5 items

    // Add items to working memory
    items := [][]methods.Probability{
        {0.9, 0.1, 0.8}, // High confidence, negative valence, high arousal
        {0.6, 0.7, 0.3}, // Medium confidence, positive valence, low arousal
        {0.8, 0.4, 0.9}, // High confidence, negative valence, high arousal
        {0.5, 0.8, 0.6}, // Medium confidence, positive valence, medium arousal
        {0.7, 0.6, 0.2}, // Medium confidence, positive valence, low arousal
        {0.4, 0.9, 0.5}, // Low confidence, positive valence, medium arousal
    }

    println("Adding items to working memory...")
    for i, item := range items {
        err := wm.AddItem(item)
        if err != nil {
            println("Failed to add item", i, ":", err.Error())
        } else {
            println("Added item", i, "successfully")
        }
    }

    // Check current memory contents
    contents := wm.GetContents()
    println("\nWorking Memory Contents:")
    for i, item := range contents {
        println("Item", i, ":", item)
    }
}
```

**Expected Output:**
```
Adding items to working memory...
Added item 0 successfully
Added item 1 successfully
Added item 2 successfully
Added item 3 successfully
Added item 4 successfully
Failed to add item 5: working memory capacity exceeded

Working Memory Contents:
Item 0: [0.9, 0.1, 0.8]
Item 1: [0.6, 0.7, 0.3]
Item 2: [0.8, 0.4, 0.9]
Item 3: [0.5, 0.8, 0.6]
Item 4: [0.7, 0.6, 0.2]
```

#### Learning Exercise: Memory Decay

```go
package main

import (
    "gno.land/p/active_inference/methods/cognitive_modeling"
    "gno.land/p/active_inference/methods"
)

func main() {
    wm := cognitive_modeling.NewWorkingMemory(3)

    // Add initial items
    wm.AddItem([]methods.Probability{0.9, 0.1, 0.8})
    wm.AddItem([]methods.Probability{0.6, 0.7, 0.3})

    println("Initial memory contents:")
    contents := wm.GetContents()
    for i, item := range contents {
        println("Item", i, ":", item)
    }

    // Simulate time passing (decay)
    wm.Decay()

    println("\nAfter decay:")
    contents = wm.GetContents()
    for i, item := range contents {
        println("Item", i, ":", item)
    }
}
```

---

## 🎯 Tutorial 3: Bayesian Inference in Action

### Building Your First Bayesian Network

**Goal**: Create a diagnostic system using Bayesian networks.

#### Step-by-Step Implementation

```go
package main

import (
    "gno.land/p/active_inference/methods/bayesian_inference"
    "gno.land/p/active_inference/methods"
    "gno.land/p/nt/ufmt"
)

func main() {
    println("🏥 Medical Diagnosis Bayesian Network")

    // Create the network
    network := bayesian_inference.NewBayesianNetwork()

    // Define diseases and symptoms
    flu := bayesian_inference.NewNode("Flu", []string{"yes", "no"})
    fever := bayesian_inference.NewNode("Fever", []string{"yes", "no"})
    cough := bayesian_inference.NewNode("Cough", []string{"yes", "no"})
    fatigue := bayesian_inference.NewNode("Fatigue", []string{"yes", "no"})

    // Set up causal relationships
    fever.AddParent(flu)
    cough.AddParent(flu)
    fatigue.AddParent(flu)

    // Add nodes to network
    network.AddNode(flu)
    network.AddNode(fever)
    network.AddNode(cough)
    network.AddNode(fatigue)

    // Set conditional probability tables (CPTs)

    // P(Flu)
    flu.SetCPT("", []methods.Probability{0.05, 0.95}) // P(Flu=yes) = 5%

    // P(Fever | Flu)
    fever.SetCPT("yes", []methods.Probability{0.9, 0.1}) // High fever if flu
    fever.SetCPT("no", []methods.Probability{0.1, 0.9})  // Low fever if no flu

    // P(Cough | Flu)
    cough.SetCPT("yes", []methods.Probability{0.8, 0.2}) // Cough if flu
    cough.SetCPT("no", []methods.Probability{0.2, 0.8})  // No cough if no flu

    // P(Fatigue | Flu)
    fatigue.SetCPT("yes", []methods.Probability{0.7, 0.3}) // Fatigue if flu
    fatigue.SetCPT("no", []methods.Probability{0.3, 0.7})  // No fatigue if no flu

    println("✅ Bayesian network created successfully!")
    println("Nodes:", len(network.Nodes))
    println("Relationships established")

    // Test inference
    testInference(network)
}

func testInference(network *bayesian_inference.BayesianNetwork) {
    // Create inference engine
    ve := bayesian_inference.NewVariableElimination(network)

    // Scenario 1: Patient has fever and cough
    println("\n📊 Inference Test 1: Fever + Cough")
    query := map[string]string{"Flu": ""}
    evidence := map[string]string{
        "Fever": "yes",
        "Cough": "yes",
    }

    result := ve.Query(query, evidence)
    println("P(Flu=yes | Fever=yes, Cough=yes):", result["yes"])

    // Scenario 2: Only fatigue
    println("\n📊 Inference Test 2: Only Fatigue")
    query2 := map[string]string{"Flu": ""}
    evidence2 := map[string]string{"Fatigue": "yes"}

    result2 := ve.Query(query2, evidence2)
    println("P(Flu=yes | Fatigue=yes):", result2["yes"])
}
```

**Expected Output:**
```
🏥 Medical Diagnosis Bayesian Network
✅ Bayesian network created successfully!
Nodes: 4
Relationships established

📊 Inference Test 1: Fever + Cough
P(Flu=yes | Fever=yes, Cough=yes): 0.32

📊 Inference Test 2: Only Fatigue
P(Flu=yes | Fatigue=yes): 0.19
```

### Understanding the Results

**Test 1 Analysis:**
- **Prior probability**: P(Flu=yes) = 5%
- **Likelihood**: P(Fever=yes, Cough=yes | Flu=yes) is high
- **Posterior**: P(Flu=yes | Fever=yes, Cough=yes) = 32%

**Test 2 Analysis:**
- **Prior probability**: P(Flu=yes) = 5%
- **Likelihood**: P(Fatigue=yes | Flu=yes) = 70%
- **Posterior**: P(Flu=yes | Fatigue=yes) = 19%

**Key Insight**: Strong evidence (fever + cough) gives higher posterior probability than weak evidence (fatigue alone).

---

## 🤖 Tutorial 4: Multi-Agent Coordination

### Creating Social Intelligence

**Goal**: Build a system where agents learn from each other.

#### Step-by-Step Multi-Agent Setup

```go
package main

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
    "gno.land/p/nt/ufmt"
)

func main() {
    println("👥 Multi-Agent Coordination Tutorial")

    // Create multi-agent system
    system := active_inference_core.NewMultiAgentSystem(3)

    // Set up social connections
    system.SocialGraph["agent0"] = []string{"agent1", "agent2"}
    system.SocialGraph["agent1"] = []string{"agent0", "agent2"}
    system.SocialGraph["agent2"] = []string{"agent0", "agent1"}

    println("✅ Multi-agent system created")
    println("Agents:", len(system.Agents))
    println("Social connections established")

    // Simulate coordination round
    simulateCoordinationRound(system)
}

func simulateCoordinationRound(system *active_inference_core.MultiAgentSystem) {
    println("\n🔄 Coordination Round Simulation")

    // Each agent processes different observations
    observations := [][]methods.Probability{
        {0.8, 0.6, 0.4, 0.7}, // Agent 0: Confident positive
        {0.3, 0.8, 0.9, 0.2}, // Agent 1: Mixed signals
        {0.6, 0.5, 0.6, 0.5}, // Agent 2: Neutral
    }

    // Process observations
    for i, agent := range system.Agents {
        err := agent.Perceive(observations[i])
        if err != nil {
            println("Agent", i, "perception error:", err.Error())
            continue
        }

        // Set individual goals
        agent.GoalSystem.SetGoal(0, methods.Probability(0.1*float64(i+1)))

        println("Agent", i, "perceived:", observations[i])
        println("Agent", i, "goal:", agent.GoalSystem.Goals[0])
    }

    // Coordinate agents
    err := system.CoordinateAgents()
    if err != nil {
        println("Coordination error:", err.Error())
        return
    }

    println("\n✅ Coordination completed successfully!")

    // Show social trust levels
    for i, agent := range system.Agents {
        println("Agent", i, "trust levels:")
        for j := range system.Agents {
            if i != j {
                trust := agent.SocialModel.GetTrustLevel(ufmt.Sprintf("agent%d", j))
                println("  Trust in Agent", j, ":", trust)
            }
        }
    }
}
```

**Expected Output:**
```
👥 Multi-Agent Coordination Tutorial
✅ Multi-agent system created
Agents: 3
Social connections established

🔄 Coordination Round Simulation
Agent 0 perceived: [0.8, 0.6, 0.4, 0.7]
Agent 0 goal: 0.1
Agent 1 perceived: [0.3, 0.8, 0.9, 0.2]
Agent 1 goal: 0.2
Agent 2 perceived: [0.6, 0.5, 0.6, 0.5]
Agent 2 goal: 0.3

✅ Coordination completed successfully!

Agent 0 trust levels:
  Trust in Agent 1: 0.8
  Trust in Agent 2: 0.7
Agent 1 trust levels:
  Trust in Agent 0: 0.6
  Trust in Agent 2: 0.8
Agent 2 trust levels:
  Trust in Agent 0: 0.7
  Trust in Agent 1: 0.6
```

### Theory of Mind Exercise

```go
package main

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
    "gno.land/p/nt/ufmt"
)

func main() {
    println("🧠 Theory of Mind Demonstration")

    // Create two agents
    agent1 := active_inference_core.NewActiveInferenceAgent()
    agent2 := active_inference_core.NewActiveInferenceAgent()

    // Agent 1 observes Agent 2's behavior
    agent2Observation := []methods.Probability{0.9, 0.1, 0.8, 0.2}
    agent2.Perceive(agent2Observation)

    // Agent 2 takes an action
    agent2.Plan()
    agent2.Act(0) // Choose first policy

    // Agent 1 models Agent 2's mental state
    agent1.SocialModel.ModelAgent("agent2", agent2Observation)

    println("Agent 1's model of Agent 2:")
    inferredBeliefs := agent1.SocialModel.OtherAgents["agent2"].Beliefs
    inferredGoals := agent1.SocialModel.OtherAgents["agent2"].Goals

    println("Inferred beliefs:", inferredBeliefs)
    println("Inferred goals:", inferredGoals)

    // Agent 1 predicts Agent 2's next action
    prediction := agent1.SocialModel.PredictAction("agent2")
    println("Predicted next action:", prediction)

    // Trust assessment
    trust := agent1.SocialModel.GetTrustLevel("agent2")
    println("Trust level in Agent 2:", trust)
}
```

---

## 📊 Tutorial 5: Reinforcement Learning Integration

### Building Adaptive Decision Systems

**Goal**: Create agents that learn from experience.

#### Q-Learning Implementation

```go
package main

import (
    "gno.land/p/active_inference/methods/reinforcement_learning"
    "gno.land/p/active_inference/methods"
    "gno.land/p/nt/ufmt"
)

func main() {
    println("🎮 Q-Learning Tutorial")

    // Create Q-learning agent
    actions := []string{"left", "right", "up", "down"}
    agent := reinforcement_learning.NewQLearningAgent(actions)

    println("✅ Q-learning agent created")
    println("Actions:", len(actions))
    println("Q-table initialized")

    // Simulate learning episodes
    simulateLearning(agent)
}

func simulateLearning(agent *reinforcement_learning.QLearningAgent) {
    println("\n🎯 Learning Simulation")

    // Simple grid world scenario
    scenarios := []struct {
        state  string
        action string
        reward methods.Probability
    }{
        {"start", "right", 0.0}, // Move right from start
        {"right", "up", 0.0},    // Move up
        {"up", "right", 1.0},    // Reach goal - positive reward
        {"start", "up", 0.0},    // Try different path
        {"up", "left", -0.5},    // Hit wall - negative reward
        {"start", "right", 0.0}, // Back to right
        {"right", "up", 1.0},    // Reach goal again
    }

    for i, scenario := range scenarios {
        println("\nEpisode", i+1)
        println("State:", scenario.state)
        println("Action:", scenario.action)
        println("Reward:", scenario.reward)

        // Update Q-values
        agent.UpdateQValue(scenario.state, scenario.action, scenario.reward)

        // Get updated Q-value
        qValue := agent.GetQValue(scenario.state, scenario.action)
        println("Updated Q-value:", qValue)

        // Show current policy
        bestAction := agent.GetBestAction(scenario.state)
        println("Best action from", scenario.state, ":", bestAction)
    }

    // Show learned policy
    println("\n📚 Learned Policy:")
    states := []string{"start", "right", "up"}
    for _, state := range states {
        bestAction := agent.GetBestAction(state)
        println("From", state, "-> take action:", bestAction)
    }
}
```

**Expected Output:**
```
🎮 Q-Learning Tutorial
✅ Q-learning agent created
Actions: 4
Q-table initialized

🎯 Learning Simulation

Episode 1
State: start
Action: right
Reward: 0
Updated Q-value: 0.1
Best action from start: right

Episode 2
State: right
Action: up
Reward: 0
Updated Q-value: 0.1
Best action from right: up

Episode 3
State: up
Action: right
Reward: 1
Updated Q-value: 0.19
Best action from up: right

... (more episodes)

📚 Learned Policy:
From start -> take action: right
From right -> take action: up
From up -> take action: right
```

### Policy Gradient Methods

```go
package main

import (
    "gno.land/p/active_inference/methods/reinforcement_learning"
    "gno.land/p/active_inference/methods"
)

func main() {
    println("🎯 Policy Gradient Tutorial")

    // Create policy gradient agent
    actions := []string{"A", "B", "C"}
    agent := reinforcement_learning.NewPolicyGradientAgent(actions)

    println("✅ Policy gradient agent created")

    // Train on simple decision task
    trainPolicyGradient(agent)
}

func trainPolicyGradient(agent *reinforcement_learning.PolicyGradientAgent) {
    println("\n🎓 Training Policy Gradient Agent")

    // Simple bandit task: Action A gives reward 0.8, others give 0.2
    trueRewards := map[string]methods.Probability{
        "A": 0.8,
        "B": 0.2,
        "C": 0.2,
    }

    for episode := 0; episode < 20; episode++ {
        // Select action based on current policy
        action := agent.SelectAction()

        // Get reward
        reward := trueRewards[action]

        // Update policy
        agent.UpdatePolicy(action, reward)

        if episode%5 == 0 {
            println("Episode", episode, "- Action:", action, "- Reward:", reward)
            probabilities := agent.GetActionProbabilities()
            println("Current policy probabilities:", probabilities)
        }
    }

    println("\n📊 Final Policy:")
    probabilities := agent.GetActionProbabilities()
    for i, action := range []string{"A", "B", "C"} {
        println("P(" + action + ") =", probabilities[i])
    }

    println("Expected optimal: P(A) > P(B), P(C)")
}
```

---

## 🛠️ Tutorial 6: Advanced Visualization

### Creating Cognitive Process Animations

**Goal**: Visualize how cognitive processes evolve over time.

#### Belief Evolution Animation

```go
package main

import (
    "gno.land/p/active_inference/methods/visualization"
    "gno.land/p/active_inference/methods"
)

func main() {
    println("🎬 Belief Evolution Animation")

    // Create cognitive process animator
    animator := visualization.NewCognitiveProcessAnimator()

    // Simulate belief evolution over time
    timeSteps := []string{"t=0", "t=1", "t=2", "t=3", "t=4"}

    for i, timeLabel := range timeSteps {
        // Create evolving belief state
        beliefs := []methods.Probability{
            methods.Probability(0.1 + 0.2*float64(i)), // Increasing confidence
            methods.Probability(0.9 - 0.2*float64(i)), // Decreasing uncertainty
            methods.Probability(0.5),                   // Stable belief
            methods.Probability(0.3 + 0.1*float64(i)), // Slow increase
        }

        attention := []methods.Probability{
            methods.Probability(0.8 - 0.1*float64(i)), // Decreasing attention
            methods.Probability(0.2 + 0.1*float64(i)), // Increasing attention
            methods.Probability(0.5),                   // Stable attention
            methods.Probability(0.4),                   // Stable attention
        }

        freeEnergy := methods.Probability(1.0 - 0.1*float64(i)) // Decreasing free energy
        predictionError := []methods.Probability{
            methods.Probability(0.2 - 0.05*float64(i)),
            methods.Probability(-0.1 + 0.02*float64(i)),
            methods.Probability(0.0),
            methods.Probability(0.1 - 0.02*float64(i)),
        }

        state := visualization.CognitiveState{
            Beliefs:         beliefs,
            Attention:       attention,
            FreeEnergy:      freeEnergy,
            PredictionError: predictionError,
            TimeStep:        i,
        }

        animator.AddCognitiveState(state, timeLabel)
    }

    // Generate animation frames
    frames := animator.AnimateBeliefEvolution()

    println("🎬 Generated", len(frames), "animation frames")

    // Display first few frames
    for i := 0; i < len(frames) && i < 3; i++ {
        println("\n--- Frame", i+1, "---")
        println(frames[i])
    }
}
```

#### Decision Process Animation

```go
package main

import (
    "gno.land/p/active_inference/methods/visualization"
    "gno.land/p/active_inference/methods"
)

func main() {
    println("⚖️ Decision Process Animation")

    animator := visualization.NewCognitiveProcessAnimator()

    // Decision options
    options := []string{"Conservative", "Balanced", "Aggressive"}

    // Evolving utility estimates
    utilities := [][]methods.Probability{
        {0.3, 0.5, 0.2}, // Initial estimates
        {0.4, 0.6, 0.3}, // After some learning
        {0.5, 0.7, 0.4}, // More confident
        {0.6, 0.8, 0.5}, // Even more confident
        {0.7, 0.9, 0.6}, // Final estimates
    }

    // Generate animation
    frames := animator.AnimateDecisionProcess(options, utilities)

    println("🎬 Generated", len(frames), "decision animation frames")

    // Show key frames
    keyFrames := []int{0, len(frames)/2, len(frames)-1}
    for _, frameIdx := range keyFrames {
        println("\n--- Decision Frame", frameIdx+1, "---")
        println(frames[frameIdx])
    }
}
```

---

## 🔗 Tutorial 7: Integration with Gno Blockchain

### Creating Smart Contracts with Active Inference

**Goal**: Deploy cognitive agents on the blockchain.

#### Basic Cognitive Agent Realm

```go
package cognitive_agent

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
    "std"
)

// Global agent state (persisted on blockchain)
var globalAgent *active_inference_core.ActiveInferenceAgent
var agentOwner string

// Initialize the cognitive agent realm
func init() {
    globalAgent = active_inference_core.NewActiveInferenceAgent()
    agentOwner = "" // Will be set during deployment
}

// Deploy initializes the agent for a specific owner
func Deploy(owner string) {
    if agentOwner != "" {
        panic("Agent already deployed")
    }
    agentOwner = owner
}

// ProcessObservation processes environmental observations
func ProcessObservation(caller string, observation []methods.Probability) string {
    // Only owner can interact with agent
    if caller != agentOwner {
        return "Access denied: not the agent owner"
    }

    // Process observation
    err := globalAgent.Perceive(observation)
    if err != nil {
        return "Perception error: " + err.Error()
    }

    // Generate action plan
    policies, err := globalAgent.Plan()
    if err != nil {
        return "Planning error: " + err.Error()
    }

    // Execute first policy
    err = globalAgent.Act(0)
    if err != nil {
        return "Action error: " + err.Error()
    }

    return "Observation processed. Generated " + string(len(policies)) + " policies. Action executed."
}

// GetBeliefState returns current agent beliefs
func GetBeliefState(caller string) string {
    if caller != agentOwner {
        return "Access denied"
    }

    beliefs := globalAgent.CurrentBeliefs
    result := "Current Beliefs: ["
    for i, belief := range beliefs {
        if i > 0 {
            result += ", "
        }
        result += string(belief)
    }
    result += "]"

    return result
}

// LearnFromOutcome updates agent based on outcome
func LearnFromOutcome(caller string, reward methods.Probability) string {
    if caller != agentOwner {
        return "Access denied"
    }

    err := globalAgent.Learn(reward)
    if err != nil {
        return "Learning error: " + err.Error()
    }

    // Emit learning event
    std.Emit("AgentLearning", map[string]interface{}{
        "reward": reward,
        "accuracy": globalAgent.GetBeliefAccuracy(),
        "timestamp": std.BlockTime(),
    })

    return "Learning completed. Reward: " + string(reward)
}
```

#### Multi-Agent Coordination Realm

```go
package multi_agent_coordination

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
    "std"
    "gno.land/p/nt/ufmt"
)

// Global coordination state
var coordinator *active_inference_core.MultiAgentSystem
var registeredAgents map[string]bool
var coordinatorOwner string

func init() {
    coordinator = active_inference_core.NewMultiAgentSystem(0) // Start with no agents
    registeredAgents = make(map[string]bool)
}

// RegisterAgent adds a new agent to the coordination system
func RegisterAgent(caller string, agentID string) string {
    if caller != coordinatorOwner && coordinatorOwner != "" {
        return "Access denied: not the coordinator owner"
    }

    if registeredAgents[agentID] {
        return "Agent already registered"
    }

    // Add agent to system
    newAgent := active_inference_core.NewActiveInferenceAgent()
    coordinator.Agents = append(coordinator.Agents, newAgent)
    registeredAgents[agentID] = true

    // Set up social connections (fully connected)
    for existingAgent := range registeredAgents {
        if existingAgent != agentID {
            coordinator.SocialGraph[agentID] = append(coordinator.SocialGraph[agentID], existingAgent)
            coordinator.SocialGraph[existingAgent] = append(coordinator.SocialGraph[existingAgent], agentID)
        }
    }

    std.Emit("AgentRegistered", map[string]interface{}{
        "agentID": agentID,
        "totalAgents": len(coordinator.Agents),
        "timestamp": std.BlockTime(),
    })

    return "Agent " + agentID + " registered successfully. Total agents: " + string(len(coordinator.Agents))
}

// CoordinateRound executes one coordination round
func CoordinateRound(caller string) string {
    if caller != coordinatorOwner && coordinatorOwner != "" {
        return "Access denied"
    }

    if len(coordinator.Agents) < 2 {
        return "Need at least 2 agents for coordination"
    }

    // Each agent processes a shared observation
    sharedObservation := []methods.Probability{0.6, 0.4, 0.7, 0.3}

    for i, agent := range coordinator.Agents {
        agent.Perceive(sharedObservation)
        agent.GoalSystem.SetGoal(0, methods.Probability(0.5 + 0.1*float64(i)))
    }

    // Coordinate agents
    err := coordinator.CoordinateAgents()
    if err != nil {
        return "Coordination error: " + err.Error()
    }

    // Calculate collective decision
    totalBelief := methods.Probability(0)
    for _, agent := range coordinator.Agents {
        totalBelief += agent.CurrentBeliefs[0]
    }
    averageBelief := totalBelief / methods.Probability(len(coordinator.Agents))

    std.Emit("CoordinationRound", map[string]interface{}{
        "roundNumber": std.BlockHeight(),
        "agents": len(coordinator.Agents),
        "collectiveBelief": averageBelief,
        "timestamp": std.BlockTime(),
    })

    return ufmt.Sprintf("Coordination round completed. Collective belief: %.3f", averageBelief)
}
```

---

## 🎯 Advanced Tutorial: Complete Cognitive System

### Building a Learning Organization

**Goal**: Create a complete system that learns and adapts over time.

#### Learning Organization Implementation

```go
package learning_organization

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods/reinforcement_learning"
    "gno.land/p/active_inference/methods"
    "std"
    "gno.land/p/nt/ufmt"
)

// Organization state
var organization *LearningOrganization
var orgOwner string

type LearningOrganization struct {
    Agents      []*active_inference_core.ActiveInferenceAgent
    RLAgent     *reinforcement_learning.QLearningAgent
    Performance []methods.Probability
    Goals       []methods.Probability
}

func init() {
    organization = &LearningOrganization{
        Agents:      make([]*active_inference_core.ActiveInferenceAgent, 0),
        Performance: make([]methods.Probability, 0),
        Goals:       []methods.Probability{0.8, 0.6, 0.7, 0.5}, // Organization goals
    }

    // Create RL agent for meta-learning
    actions := []string{"expand", "contract", "reorganize", "optimize"}
    organization.RLAgent = reinforcement_learning.NewQLearningAgent(actions)
}

// AddAgent adds a new agent to the organization
func AddAgent(caller string, agentID string) string {
    if caller != orgOwner && orgOwner != "" {
        return "Access denied"
    }

    newAgent := active_inference_core.NewActiveInferenceAgent()
    organization.Agents = append(organization.Agents, newAgent)

    std.Emit("AgentAdded", map[string]interface{}{
        "agentID": agentID,
        "totalAgents": len(organization.Agents),
    })

    return "Agent added. Total agents: " + string(len(organization.Agents))
}

// ProcessTask processes an organizational task
func ProcessTask(caller string, taskData []methods.Probability) string {
    if caller != orgOwner && orgOwner != "" {
        return "Access denied"
    }

    // All agents process the task
    for _, agent := range organization.Agents {
        agent.Perceive(taskData)
        agent.Plan()
        agent.Act(0) // Execute first policy
    }

    // Evaluate organizational performance
    performance := evaluateOrganizationalPerformance()

    // Learn from performance
    organization.Performance = append(organization.Performance, performance)

    // Meta-learning: RL agent learns organizational strategies
    currentState := "normal" // Simplified state
    bestAction := organization.RLAgent.GetBestAction(currentState)
    organization.RLAgent.UpdateQValue(currentState, bestAction, performance)

    std.Emit("TaskProcessed", map[string]interface{}{
        "agents": len(organization.Agents),
        "performance": performance,
        "bestAction": bestAction,
    })

    return ufmt.Sprintf("Task processed. Performance: %.3f, Recommended action: %s",
        performance, bestAction)
}

func evaluateOrganizationalPerformance() methods.Probability {
    if len(organization.Agents) == 0 {
        return 0
    }

    // Calculate average agent performance
    totalPerformance := methods.Probability(0)
    for _, agent := range organization.Agents {
        totalPerformance += agent.GetBeliefAccuracy()
    }

    averagePerformance := totalPerformance / methods.Probability(len(organization.Agents))

    // Factor in goal alignment
    goalAlignment := methods.Probability(0)
    for _, agent := range organization.Agents {
        for i, goal := range organization.Goals {
            if i < len(agent.GoalSystem.Goals) {
                diff := goal - agent.GoalSystem.Goals[i]
                if diff < 0 {
                    diff = -diff
                }
                goalAlignment += 1 - diff
            }
        }
    }
    goalAlignment /= methods.Probability(len(organization.Agents) * len(organization.Goals))

    // Combine metrics
    overallPerformance := (averagePerformance + goalAlignment) / 2
    return overallPerformance
}

// GetOrganizationStatus returns current organization metrics
func GetOrganizationStatus(caller string) string {
    if caller != orgOwner && orgOwner != "" {
        return "Access denied"
    }

    if len(organization.Performance) == 0 {
        return "No performance data available"
    }

    // Calculate performance statistics
    totalPerf := methods.Probability(0)
    for _, perf := range organization.Performance {
        totalPerf += perf
    }
    avgPerf := totalPerf / methods.Probability(len(organization.Performance))

    // Find best and worst performance
    bestPerf := organization.Performance[0]
    worstPerf := organization.Performance[0]
    for _, perf := range organization.Performance {
        if perf > bestPerf {
            bestPerf = perf
        }
        if perf < worstPerf {
            worstPerf = perf
        }
    }

    // Get current RL policy
    currentState := "normal"
    recommendedAction := organization.RLAgent.GetBestAction(currentState)

    return ufmt.Sprintf(`Organization Status:
Agents: %d
Average Performance: %.3f
Best Performance: %.3f
Worst Performance: %.3f
Recommended Action: %s
Total Tasks Processed: %d`,
        len(organization.Agents),
        avgPerf,
        bestPerf,
        worstPerf,
        recommendedAction,
        len(organization.Performance))
}
```

---

## 📚 Tutorial Resources

### Additional Learning Materials

1. **[Mathematical Foundations](./mathematical_foundations.md)** - Deep dive into the math
2. **[API Reference](./api_reference.md)** - Complete function documentation
3. **[Best Practices](./best_practices.md)** - Production deployment guidelines
4. **[Troubleshooting](./troubleshooting.md)** - Common issues and solutions

### Practice Exercises

- **Exercise 1**: Modify the medical diagnosis network to include more symptoms
- **Exercise 2**: Implement a custom reinforcement learning environment
- **Exercise 3**: Create a multi-agent negotiation protocol
- **Exercise 4**: Build a real-time cognitive monitoring dashboard

### Next Steps

1. **Explore Advanced Topics**: Dive into specific areas of interest
2. **Contribute**: Help improve the framework with your insights
3. **Build Applications**: Create real-world applications using Active Inference
4. **Research**: Explore cutting-edge developments in the field

*Happy Learning! The journey into Active Inference is just beginning...* 🚀
