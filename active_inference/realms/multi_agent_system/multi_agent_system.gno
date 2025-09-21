// Package multi_agent_system provides a deployable multi-agent coordination realm
// for the Gno blockchain. This realm implements coordination between multiple
// cognitive agents with social learning and consensus formation capabilities.
package multi_agent_system

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
    "std"
    "gno.land/p/nt/ufmt"
)

// =============================================================================
// GLOBAL STATE - PERSISTED ACROSS TRANSACTIONS
// =============================================================================

// Core multi-agent system instance
var coordinator *active_inference_core.MultiAgentSystem

// Access control
var systemOwner string
var registeredAgents map[string]bool

// Coordination history and analytics
var coordinationHistory []CoordinationRecord
var agentConnections map[string][]string
var collectiveBeliefs []methods.Probability

// Performance metrics
var totalCoordinationRounds int64
var averageConsensusLevel methods.Probability
var systemGasUsed uint64

// =============================================================================
// DATA STRUCTURES
// =============================================================================

// CoordinationRecord tracks coordination rounds and outcomes
type CoordinationRecord struct {
    Timestamp      int64
    AgentsActive   int
    CollectiveBelief methods.Probability
    ConsensusLevel methods.Probability
    CoordinationOutcome string
    GasUsed        uint64
}

// AgentRegistration records agent registration information
type AgentRegistration struct {
    AgentID     string
    Timestamp   int64
    InitialBeliefs []methods.Probability
    Capabilities []string
    Status      string
}

// =============================================================================
// REALM INITIALIZATION
// =============================================================================

// init is called when the realm is deployed to the blockchain
func init() {
    coordinator = active_inference_core.NewMultiAgentSystem(0) // Start with no agents
    registeredAgents = make(map[string]bool)
    agentConnections = make(map[string][]string)
    coordinationHistory = make([]CoordinationRecord, 0)
    collectiveBeliefs = make([]methods.Probability, 0)

    // Initialize metrics
    totalCoordinationRounds = 0
    averageConsensusLevel = 0.5
    systemGasUsed = 0
    systemOwner = ""

    ufmt.Printf("Multi-agent coordination realm initialized\n")
}

// =============================================================================
// ACCESS CONTROL METHODS
// =============================================================================

// Deploy initializes the multi-agent system for a specific owner
func Deploy(caller string, owner string) string {
    if systemOwner != "" {
        return "Multi-agent system already deployed"
    }

    if !std.IsValidAddress(owner) {
        return "Invalid owner address"
    }

    systemOwner = owner

    // Emit deployment event
    std.Emit("MultiAgentSystemDeployed", map[string]interface{}{
        "owner": owner,
        "timestamp": std.BlockTime(),
        "systemType": "ActiveInferenceCoordination",
    })

    return "Multi-agent coordination system deployed successfully"
}

// IsAuthorized checks if the caller is authorized to perform actions
func IsAuthorized(caller string) bool {
    return caller == systemOwner || registeredAgents[caller]
}

// =============================================================================
// AGENT MANAGEMENT METHODS
// =============================================================================

// RegisterAgent adds a new agent to the coordination system
func RegisterAgent(caller string, agentID string) string {
    if !IsAuthorized(caller) {
        return "Access denied: not authorized"
    }

    if registeredAgents[agentID] {
        return "Agent already registered"
    }

    // Create new active inference agent
    newAgent := active_inference_core.NewActiveInferenceAgent()
    coordinator.Agents = append(coordinator.Agents, newAgent)
    registeredAgents[agentID] = true

    // Initialize agent with default goals
    newAgent.GoalSystem.SetGoal(0, methods.Probability(0.5))

    // Set up social connections (fully connected by default)
    agentConnections[agentID] = make([]string, 0)
    for existingAgent := range registeredAgents {
        if existingAgent != agentID {
            agentConnections[agentID] = append(agentConnections[agentID], existingAgent)
            agentConnections[existingAgent] = append(agentConnections[existingAgent], agentID)
        }
    }

    // Update social graph in coordinator
    coordinator.SocialGraph = agentConnections

    // Record registration
    registration := AgentRegistration{
        AgentID:     agentID,
        Timestamp:   std.BlockTime(),
        InitialBeliefs: newAgent.CurrentBeliefs,
        Capabilities: []string{"perception", "planning", "action", "learning"},
        Status:      "active",
    }

    // Emit registration event
    std.Emit("AgentRegistered", map[string]interface{}{
        "agentID": agentID,
        "totalAgents": len(coordinator.Agents),
        "registration": registration,
        "timestamp": std.BlockTime(),
    })

    return ufmt.Sprintf("Agent %s registered successfully. Total agents: %d",
        agentID, len(coordinator.Agents))
}

// GetRegisteredAgents returns list of registered agent IDs
func GetRegisteredAgents(caller string) string {
    if !IsAuthorized(caller) {
        return "Access denied"
    }

    if len(registeredAgents) == 0 {
        return "No agents registered"
    }

    result := "Registered Agents:\n"
    for agentID := range registeredAgents {
        result += ufmt.Sprintf("- %s\n", agentID)
    }

    return result
}

// =============================================================================
// COORDINATION METHODS
// =============================================================================

// CoordinateRound executes one coordination round with shared observation
func CoordinateRound(caller string, sharedObservation []methods.Probability) string {
    if !IsAuthorized(caller) {
        return "Access denied"
    }

    if len(coordinator.Agents) < 2 {
        return "Need at least 2 agents for coordination"
    }

    // Each agent processes the shared observation
    for i, agent := range coordinator.Agents {
        err := agent.Perceive(sharedObservation)
        if err != nil {
            return ufmt.Sprintf("Agent %d perception error: %s", i, err.Error())
        }

        // Set individual goals (slightly different for diversity)
        agent.GoalSystem.SetGoal(0, methods.Probability(0.5 + 0.1*methods.Probability(i)))
        agent.Plan()
        agent.Act(0)
    }

    // Coordinate agents
    err := coordinator.CoordinateAgents()
    if err != nil {
        return "Coordination error: " + err.Error()
    }

    // Calculate collective metrics
    totalBelief := methods.Probability(0)
    for _, agent := range coordinator.Agents {
        if len(agent.CurrentBeliefs) > 0 {
            totalBelief += agent.CurrentBeliefs[0] // Use first belief dimension
        }
    }
    collectiveBelief := totalBelief / methods.Probability(len(coordinator.Agents))

    // Calculate consensus level (inverse of belief variance)
    variance := methods.Probability(0)
    for _, agent := range coordinator.Agents {
        if len(agent.CurrentBeliefs) > 0 {
            diff := agent.CurrentBeliefs[0] - collectiveBelief
            variance += diff * diff
        }
    }
    if len(coordinator.Agents) > 0 {
        variance /= methods.Probability(len(coordinator.Agents))
    }
    consensusLevel := methods.Probability(1.0) / (methods.Probability(1.0) + variance)

    // Determine coordination outcome
    outcome := "partial_consensus"
    if consensusLevel > 0.8 {
        outcome = "strong_consensus"
    } else if consensusLevel < 0.3 {
        outcome = "divergence_detected"
    }

    // Record coordination
    record := CoordinationRecord{
        Timestamp:       std.BlockTime(),
        AgentsActive:    len(coordinator.Agents),
        CollectiveBelief: collectiveBelief,
        ConsensusLevel:  consensusLevel,
        CoordinationOutcome: outcome,
        GasUsed:         std.GasUsed(),
    }
    coordinationHistory = append(coordinationHistory, record)

    // Update metrics
    totalCoordinationRounds++
    averageConsensusLevel = (averageConsensusLevel*methods.Probability(totalCoordinationRounds-1) + consensusLevel) / methods.Probability(totalCoordinationRounds)

    // Store collective belief
    collectiveBeliefs = append(collectiveBeliefs, collectiveBelief)

    // Emit coordination event
    std.Emit("CoordinationCompleted", map[string]interface{}{
        "roundNumber": totalCoordinationRounds,
        "agents": len(coordinator.Agents),
        "collectiveBelief": collectiveBelief,
        "consensusLevel": consensusLevel,
        "outcome": outcome,
        "timestamp": std.BlockTime(),
    })

    return ufmt.Sprintf(`Coordination Round %d Completed:
Agents Active: %d
Collective Belief: %.3f
Consensus Level: %.3f
Outcome: %s
Observation Dimensions: %d`,
        totalCoordinationRounds, len(coordinator.Agents), collectiveBelief,
        consensusLevel, outcome, len(sharedObservation))
}

// =============================================================================
// QUERY METHODS
// =============================================================================

// GetCoordinationHistory returns coordination history
func GetCoordinationHistory(caller string) string {
    if !IsAuthorized(caller) {
        return "Access denied"
    }

    if len(coordinationHistory) == 0 {
        return "No coordination history available"
    }

    history := "Coordination History:\n"
    for i, record := range coordinationHistory {
        history += ufmt.Sprintf(`Round %d (Time: %d):
  Agents: %d
  Collective Belief: %.3f
  Consensus Level: %.3f
  Outcome: %s

`,
            i+1, record.Timestamp, record.AgentsActive,
            record.CollectiveBelief, record.ConsensusLevel, record.CoordinationOutcome)
    }

    return history
}

// GetSystemStatus returns current system status
func GetSystemStatus(caller string) string {
    if !IsAuthorized(caller) {
        return "Access denied"
    }

    latestConsensus := methods.Probability(0)
    if len(coordinationHistory) > 0 {
        latestConsensus = coordinationHistory[len(coordinationHistory)-1].ConsensusLevel
    }

    return ufmt.Sprintf(`Multi-Agent System Status:
Owner: %s
Total Agents: %d
Registered Agents: %d
Coordination Rounds: %d
Average Consensus Level: %.3f
Latest Consensus: %.3f
System Gas Used: %d
Block Height: %d`,
        systemOwner, len(coordinator.Agents), len(registeredAgents),
        totalCoordinationRounds, averageConsensusLevel, latestConsensus,
        systemGasUsed, std.BlockHeight())
}

// GetAgentBeliefs returns current beliefs of all agents
func GetAgentBeliefs(caller string) string {
    if !IsAuthorized(caller) {
        return "Access denied"
    }

    if len(coordinator.Agents) == 0 {
        return "No agents available"
    }

    result := "Current Agent Beliefs:\n"
    for i, agent := range coordinator.Agents {
        result += ufmt.Sprintf("Agent %d: [", i)
        for j, belief := range agent.CurrentBeliefs {
            if j > 0 {
                result += ", "
            }
            result += ufmt.Sprintf("%.3f", belief)
        }
        result += "]\n"
    }

    return result
}

// =============================================================================
// RENDER METHOD FOR REALM QUERIES
// =============================================================================

// Render provides string representation for queries
func Render(path string) string {
    switch path {
    case "":
        return GetSystemStatus("")
    case "status":
        return GetSystemStatus("")
    case "agents":
        return GetRegisteredAgents("")
    case "beliefs":
        return GetAgentBeliefs("")
    case "history":
        return GetCoordinationHistory("")
    default:
        return "Unknown path: " + path
    }
}
