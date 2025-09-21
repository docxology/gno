// Package cognitive_agent provides a deployable Active Inference agent realm
// for the Gno blockchain. This realm implements a complete cognitive agent
// capable of perception, planning, action, and learning.
package cognitive_agent

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
    "std"
    "gno.land/p/nt/ufmt"
    "math"
)

// =============================================================================
// GLOBAL STATE - PERSISTED ACROSS TRANSACTIONS
// =============================================================================

// Core agent instance - the heart of our cognitive system
var agent *active_inference_core.ActiveInferenceAgent

// Access control
var owner string
var authorizedUsers []string

// History and analytics
var observationHistory []ObservationRecord
var decisionHistory []DecisionRecord
var learningHistory []LearningRecord

// Performance metrics
var totalObservations int64
var totalDecisions int64
var averageBeliefAccuracy methods.Probability
var totalGasUsed uint64

// Configuration
var maxHistorySize int
var gasCheckpoint uint64

// =============================================================================
// DATA STRUCTURES
// =============================================================================

// ObservationRecord tracks environmental observations
type ObservationRecord struct {
    Timestamp   int64
    Data        []methods.Probability
    Source      string
    GasUsed     uint64
}

// DecisionRecord tracks agent decisions and actions
type DecisionRecord struct {
    Timestamp   int64
    Observation []methods.Probability
    Policies    []PolicyInfo
    ActionTaken int
    Confidence  methods.Probability
    GasUsed     uint64
}

// PolicyInfo contains information about generated policies
type PolicyInfo struct {
    Actions     []methods.Probability
    ExpectedUtility methods.Probability
    Complexity  int
}

// LearningRecord tracks learning episodes
type LearningRecord struct {
    Timestamp     int64
    Reward        methods.Probability
    BeliefAccuracyBefore methods.Probability
    BeliefAccuracyAfter methods.Probability
    GasUsed       uint64
}

// =============================================================================
// REALM INITIALIZATION
// =============================================================================

// init is called when the realm is deployed to the blockchain
func init() {
    // Initialize the cognitive agent
    agent = active_inference_core.NewActiveInferenceAgent()

    // Initialize access control
    owner = ""
    authorizedUsers = make([]string, 0)

    // Initialize history arrays
    observationHistory = make([]ObservationRecord, 0)
    decisionHistory = make([]DecisionRecord, 0)
    learningHistory = make([]LearningRecord, 0)

    // Initialize metrics
    totalObservations = 0
    totalDecisions = 0
    averageBeliefAccuracy = 0.5
    totalGasUsed = 0

    // Set configuration
    maxHistorySize = 100

    // Record gas usage for initialization
    gasCheckpoint = std.GasUsed()

    // Emit initialization event
    std.Emit("RealmInitialized", map[string]interface{}{
        "timestamp": std.BlockTime(),
        "agentType": "ActiveInference",
        "maxHistorySize": maxHistorySize,
    })
}

// =============================================================================
// DEPLOYMENT AND ACCESS CONTROL
// =============================================================================

// Deploy initializes the cognitive agent realm for a specific owner
func Deploy(caller string, ownerAddress string) string {
    // Check if already deployed
    if owner != "" {
        return "Error: Agent already deployed to address " + owner
    }

    // Validate owner address
    if !std.IsValidAddress(ownerAddress) {
        return "Error: Invalid owner address format"
    }

    // Set owner and add to authorized users
    owner = ownerAddress
    authorizedUsers = append(authorizedUsers, ownerAddress)

    // Record gas usage
    gasUsed := std.GasUsed() - gasCheckpoint
    totalGasUsed += gasUsed
    gasCheckpoint = std.GasUsed()

    // Emit deployment event
    std.Emit("AgentDeployed", map[string]interface{}{
        "owner": ownerAddress,
        "caller": caller,
        "gasUsed": gasUsed,
        "timestamp": std.BlockTime(),
    })

    return "Cognitive agent deployed successfully to " + ownerAddress
}

// AuthorizeUser grants access to additional users
func AuthorizeUser(caller string, userAddress string) string {
    // Only owner can authorize users
    if caller != owner {
        return "Access denied: only owner can authorize users"
    }

    // Validate address
    if !std.IsValidAddress(userAddress) {
        return "Error: Invalid user address format"
    }

    // Check if already authorized
    for _, user := range authorizedUsers {
        if user == userAddress {
            return "User " + userAddress + " is already authorized"
        }
    }

    // Add to authorized users
    authorizedUsers = append(authorizedUsers, userAddress)

    // Emit authorization event
    std.Emit("UserAuthorized", map[string]interface{}{
        "user": userAddress,
        "authorizedBy": caller,
        "timestamp": std.BlockTime(),
    })

    return "User " + userAddress + " authorized successfully"
}

// IsAuthorized checks if a user has access to the agent
func IsAuthorized(userAddress string) bool {
    for _, authorized := range authorizedUsers {
        if authorized == userAddress {
            return true
        }
    }
    return false
}

// =============================================================================
// CORE COGNITIVE FUNCTIONS
// =============================================================================

// ProcessObservation processes environmental observations and updates agent state
func ProcessObservation(caller string, observation []methods.Probability, source string) string {
    // Check authorization
    if !IsAuthorized(caller) {
        return "Access denied: user not authorized"
    }

    // Validate observation
    if len(observation) == 0 {
        return "Error: Empty observation"
    }

    // Validate probability values
    for i, prob := range observation {
        if prob < 0 || prob > 1 {
            return ufmt.Sprintf("Error: Invalid probability at index %d: %f (must be between 0 and 1)", i, prob)
        }
    }

    // Record gas usage start
    gasStart := std.GasUsed()

    // Process observation with the agent
    err := agent.Perceive(observation)
    if err != nil {
        return "Error processing observation: " + err.Error()
    }

    // Generate action plan
    policies, err := agent.Plan()
    if err != nil {
        return "Error generating plan: " + err.Error()
    }

    // Record observation
    obsRecord := ObservationRecord{
        Timestamp: std.BlockTime(),
        Data:      observation,
        Source:    source,
        GasUsed:   0, // Will be set below
    }

    // Manage history size
    if len(observationHistory) >= maxHistorySize {
        // Remove oldest observation (circular buffer)
        observationHistory = observationHistory[1:]
    }
    observationHistory = append(observationHistory, obsRecord)

    // Update metrics
    totalObservations++

    // Calculate gas used
    gasUsed := std.GasUsed() - gasStart
    totalGasUsed += gasUsed
    obsRecord.GasUsed = gasUsed
    observationHistory[len(observationHistory)-1] = obsRecord

    // Emit observation event
    std.Emit("ObservationProcessed", map[string]interface{}{
        "caller": caller,
        "observationLength": len(observation),
        "source": source,
        "policiesGenerated": len(policies),
        "gasUsed": gasUsed,
        "timestamp": std.BlockTime(),
    })

    // Return success message
    return ufmt.Sprintf("Observation processed successfully. Generated %d policies. Gas used: %d",
        len(policies), gasUsed)
}

// ExecuteAction executes the specified action policy
func ExecuteAction(caller string, policyIndex int) string {
    // Check authorization
    if !IsAuthorized(caller) {
        return "Access denied: user not authorized"
    }

    // Validate policy index
    if policyIndex < 0 {
        return "Error: Policy index cannot be negative"
    }

    // Record gas usage start
    gasStart := std.GasUsed()

    // Execute action
    err := agent.Act(policyIndex)
    if err != nil {
        return "Error executing action: " + err.Error()
    }

    // Get current policies for recording
    policies, err := agent.Plan()
    if err != nil {
        return "Error retrieving policies: " + err.Error()
    }

    // Validate policy index against available policies
    if policyIndex >= len(policies) {
        return ufmt.Sprintf("Error: Policy index %d out of range (available: 0-%d)",
            policyIndex, len(policies)-1)
    }

    // Record decision
    policy := policies[policyIndex]
    decisionRecord := DecisionRecord{
        Timestamp:   std.BlockTime(),
        Observation: agent.CurrentObservation,
        Policies:    make([]PolicyInfo, len(policies)),
        ActionTaken: policyIndex,
        Confidence:  methods.Probability(0.8), // Simplified confidence calculation
        GasUsed:     0, // Will be set below
    }

    // Convert policies to PolicyInfo
    for i, p := range policies {
        decisionRecord.Policies[i] = PolicyInfo{
            Actions:          p.Actions,
            ExpectedUtility:  methods.Probability(0.5 + 0.1*float64(i)), // Simplified utility
            Complexity:       len(p.Actions),
        }
    }

    // Manage history size
    if len(decisionHistory) >= maxHistorySize {
        decisionHistory = decisionHistory[1:]
    }
    decisionHistory = append(decisionHistory, decisionRecord)

    // Update metrics
    totalDecisions++

    // Calculate gas used
    gasUsed := std.GasUsed() - gasStart
    totalGasUsed += gasUsed
    decisionRecord.GasUsed = gasUsed
    decisionHistory[len(decisionHistory)-1] = decisionRecord

    // Emit action event
    std.Emit("ActionExecuted", map[string]interface{}{
        "caller": caller,
        "policyIndex": policyIndex,
        "gasUsed": gasUsed,
        "timestamp": std.BlockTime(),
    })

    return ufmt.Sprintf("Action executed successfully. Policy %d selected. Gas used: %d",
        policyIndex, gasUsed)
}

// LearnFromFeedback updates the agent based on environmental feedback
func LearnFromFeedback(caller string, reward methods.Probability) string {
    // Check authorization
    if !IsAuthorized(caller) {
        return "Access denied: user not authorized"
    }

    // Validate reward
    if reward < -1 || reward > 1 {
        return ufmt.Sprintf("Error: Reward %f must be between -1 and 1", reward)
    }

    // Record gas usage start
    gasStart := std.GasUsed()

    // Get belief accuracy before learning
    accuracyBefore := agent.GetBeliefAccuracy()

    // Perform learning
    err := agent.Learn(reward)
    if err != nil {
        return "Error during learning: " + err.Error()
    }

    // Get belief accuracy after learning
    accuracyAfter := agent.GetBeliefAccuracy()

    // Update average accuracy
    if totalObservations > 0 {
        averageBeliefAccuracy = (averageBeliefAccuracy*methods.Probability(totalObservations-1) + accuracyAfter) / methods.Probability(totalObservations)
    } else {
        averageBeliefAccuracy = accuracyAfter
    }

    // Record learning episode
    learningRecord := LearningRecord{
        Timestamp:           std.BlockTime(),
        Reward:              reward,
        BeliefAccuracyBefore: accuracyBefore,
        BeliefAccuracyAfter:  accuracyAfter,
        GasUsed:             0, // Will be set below
    }

    // Manage history size
    if len(learningHistory) >= maxHistorySize {
        learningHistory = learningHistory[1:]
    }
    learningHistory = append(learningHistory, learningRecord)

    // Calculate gas used
    gasUsed := std.GasUsed() - gasStart
    totalGasUsed += gasUsed
    learningRecord.GasUsed = gasUsed
    learningHistory[len(learningHistory)-1] = learningRecord

    // Emit learning event
    std.Emit("LearningCompleted", map[string]interface{}{
        "caller": caller,
        "reward": reward,
        "accuracyBefore": accuracyBefore,
        "accuracyAfter": accuracyAfter,
        "gasUsed": gasUsed,
        "timestamp": std.BlockTime(),
    })

    return ufmt.Sprintf("Learning completed. Reward: %.3f, Accuracy improved: %.3f -> %.3f, Gas used: %d",
        reward, accuracyBefore, accuracyAfter, gasUsed)
}

// =============================================================================
// MONITORING AND ANALYTICS
// =============================================================================

// GetAgentStatus returns comprehensive agent status information
func GetAgentStatus(caller string) string {
    // Check authorization
    if !IsAuthorized(caller) {
        return "Access denied: user not authorized"
    }

    // Get current beliefs
    beliefs := agent.CurrentBeliefs

    // Calculate belief statistics
    beliefStats := calculateBeliefStatistics(beliefs)

    // Format status report
    status := "🤖 Cognitive Agent Status Report\n"
    status += "═══════════════════════════════════════\n\n"

    status += "👤 Owner: " + owner + "\n"
    status += ufmt.Sprintf("⏰ Current Block: %d\n", std.BlockTime())
    status += ufmt.Sprintf("📊 Total Observations: %d\n", totalObservations)
    status += ufmt.Sprintf("🎯 Total Decisions: %d\n", totalDecisions)
    status += ufmt.Sprintf("⚡ Total Gas Used: %d\n\n", totalGasUsed)

    status += "🧠 Current Beliefs:\n"
    for i, belief := range beliefs {
        status += ufmt.Sprintf("  B%d: %.4f\n", i, belief)
    }
    status += "\n"

    status += "📈 Belief Statistics:\n"
    status += ufmt.Sprintf("  Average: %.4f\n", beliefStats.average)
    status += ufmt.Sprintf("  Maximum: %.4f (B%d)\n", beliefStats.max, beliefStats.maxIndex)
    status += ufmt.Sprintf("  Minimum: %.4f (B%d)\n", beliefStats.min, beliefStats.minIndex)
    status += ufmt.Sprintf("  Entropy: %.4f\n", beliefStats.entropy)
    status += "\n"

    status += ufmt.Sprintf("🎯 Average Belief Accuracy: %.4f\n", averageBeliefAccuracy)
    status += ufmt.Sprintf("📚 History Size: %d/%d\n", len(observationHistory), maxHistorySize)
    status += ufmt.Sprintf("👥 Authorized Users: %d\n", len(authorizedUsers))

    // Performance assessment
    status += "\n📊 Performance Assessment:\n"
    if averageBeliefAccuracy > 0.8 {
        status += "  🟢 EXCELLENT: High belief accuracy indicates strong learning\n"
    } else if averageBeliefAccuracy > 0.6 {
        status += "  🟡 GOOD: Moderate belief accuracy with room for improvement\n"
    } else {
        status += "  🔴 NEEDS IMPROVEMENT: Low belief accuracy suggests learning challenges\n"
    }

    if beliefStats.entropy > 1.0 {
        status += "  🎲 HIGH UNCERTAINTY: Agent has diverse beliefs - more observations needed\n"
    } else if beliefStats.entropy < 0.5 {
        status += "  🎯 LOW UNCERTAINTY: Agent has confident beliefs\n"
    }

    return status
}

// calculateBeliefStatistics computes statistics about current beliefs
func calculateBeliefStatistics(beliefs []methods.Probability) BeliefStatistics {
    if len(beliefs) == 0 {
        return BeliefStatistics{}
    }

    stats := BeliefStatistics{
        average: 0,
        max: beliefs[0],
        min: beliefs[0],
        maxIndex: 0,
        minIndex: 0,
        entropy: 0,
    }

    // Calculate sum for average
    sum := methods.Probability(0)
    for i, belief := range beliefs {
        sum += belief

        // Track max
        if belief > stats.max {
            stats.max = belief
            stats.maxIndex = i
        }

        // Track min
        if belief < stats.min {
            stats.min = belief
            stats.minIndex = i
        }
    }

    stats.average = sum / methods.Probability(len(beliefs))

    // Calculate entropy
    for _, belief := range beliefs {
        if belief > 0 {
            stats.entropy -= belief * methods.Probability(math.Log(float64(belief)))
        }
    }

    return stats
}

// BeliefStatistics contains statistical information about beliefs
type BeliefStatistics struct {
    average  methods.Probability
    max      methods.Probability
    min      methods.Probability
    maxIndex int
    minIndex int
    entropy  methods.Probability
}

// GetObservationHistory returns recent observation history
func GetObservationHistory(caller string, limit int) string {
    // Check authorization
    if !IsAuthorized(caller) {
        return "Access denied: user not authorized"
    }

    if len(observationHistory) == 0 {
        return "No observation history available"
    }

    // Limit the number of records returned
    if limit <= 0 || limit > len(observationHistory) {
        limit = len(observationHistory)
    }

    history := ufmt.Sprintf("📚 Observation History (Last %d records):\n", limit)
    history += "═══════════════════════════════════════════════\n"

    start := len(observationHistory) - limit
    if start < 0 {
        start = 0
    }

    for i := start; i < len(observationHistory); i++ {
        record := observationHistory[i]
        history += ufmt.Sprintf("\n%d. Time: %d\n", i+1, record.Timestamp)
        history += ufmt.Sprintf("   Source: %s\n", record.Source)
        history += ufmt.Sprintf("   Data: [", record.Data)
        for j, value := range record.Data {
            if j > 0 {
                history += ", "
            }
            history += ufmt.Sprintf("%.3f", value)
        }
        history += "]\n"
        history += ufmt.Sprintf("   Gas Used: %d\n", record.GasUsed)
    }

    return history
}

// GetDecisionHistory returns recent decision history
func GetDecisionHistory(caller string, limit int) string {
    // Check authorization
    if !IsAuthorized(caller) {
        return "Access denied: user not authorized"
    }

    if len(decisionHistory) == 0 {
        return "No decision history available"
    }

    // Limit the number of records returned
    if limit <= 0 || limit > len(decisionHistory) {
        limit = len(decisionHistory)
    }

    history := ufmt.Sprintf("🎯 Decision History (Last %d records):\n", limit)
    history += "═══════════════════════════════════════════════\n"

    start := len(decisionHistory) - limit
    if start < 0 {
        start = 0
    }

    for i := start; i < len(decisionHistory); i++ {
        record := decisionHistory[i]
        history += ufmt.Sprintf("\n%d. Time: %d\n", i+1, record.Timestamp)
        history += ufmt.Sprintf("   Action Taken: Policy %d\n", record.ActionTaken)
        history += ufmt.Sprintf("   Confidence: %.3f\n", record.Confidence)
        history += ufmt.Sprintf("   Policies Available: %d\n", len(record.Policies))
        history += ufmt.Sprintf("   Gas Used: %d\n", record.GasUsed)
    }

    return history
}

// GetLearningHistory returns recent learning history
func GetLearningHistory(caller string, limit int) string {
    // Check authorization
    if !IsAuthorized(caller) {
        return "Access denied: user not authorized"
    }

    if len(learningHistory) == 0 {
        return "No learning history available"
    }

    // Limit the number of records returned
    if limit <= 0 || limit > len(learningHistory) {
        limit = len(learningHistory)
    }

    history := ufmt.Sprintf("🧠 Learning History (Last %d records):\n", limit)
    history += "═══════════════════════════════════════════════\n"

    start := len(learningHistory) - limit
    if start < 0 {
        start = 0
    }

    for i := start; i < len(learningHistory); i++ {
        record := learningHistory[i]
        history += ufmt.Sprintf("\n%d. Time: %d\n", i+1, record.Timestamp)
        history += ufmt.Sprintf("   Reward: %.3f\n", record.Reward)
        history += ufmt.Sprintf("   Accuracy Before: %.3f\n", record.BeliefAccuracyBefore)
        history += ufmt.Sprintf("   Accuracy After: %.3f\n", record.BeliefAccuracyAfter)
        history += ufmt.Sprintf("   Improvement: %.3f\n", record.BeliefAccuracyAfter-record.BeliefAccuracyBefore)
        history += ufmt.Sprintf("   Gas Used: %d\n", record.GasUsed)
    }

    return history
}

// =============================================================================
// ADVANCED ANALYTICS
// =============================================================================

// AnalyzePerformance provides detailed performance analysis
func AnalyzePerformance(caller string) string {
    // Check authorization
    if !IsAuthorized(caller) {
        return "Access denied: user not authorized"
    }

    analysis := "📊 Performance Analysis Report\n"
    analysis += "═══════════════════════════════════════\n\n"

    // Basic metrics
    analysis += "📈 Basic Metrics:\n"
    analysis += ufmt.Sprintf("   Total Observations: %d\n", totalObservations)
    analysis += ufmt.Sprintf("   Total Decisions: %d\n", totalDecisions)
    analysis += ufmt.Sprintf("   Total Learning Episodes: %d\n", len(learningHistory))
    analysis += ufmt.Sprintf("   Average Belief Accuracy: %.4f\n", averageBeliefAccuracy)
    analysis += ufmt.Sprintf("   Total Gas Used: %d\n\n", totalGasUsed)

    // Learning effectiveness
    if len(learningHistory) > 0 {
        analysis += "🧠 Learning Effectiveness:\n"

        totalImprovement := methods.Probability(0)
        positiveLearning := 0
        negativeLearning := 0

        for _, record := range learningHistory {
            improvement := record.BeliefAccuracyAfter - record.BeliefAccuracyBefore
            totalImprovement += improvement

            if improvement > 0 {
                positiveLearning++
            } else if improvement < 0 {
                negativeLearning++
            }
        }

        averageImprovement := totalImprovement / methods.Probability(len(learningHistory))
        learningRate := methods.Probability(positiveLearning) / methods.Probability(len(learningHistory))

        analysis += ufmt.Sprintf("   Average Improvement: %.4f\n", averageImprovement)
        analysis += ufmt.Sprintf("   Learning Rate: %.1f%%\n", learningRate*100)
        analysis += ufmt.Sprintf("   Positive Learning: %d\n", positiveLearning)
        analysis += ufmt.Sprintf("   Negative Learning: %d\n\n", negativeLearning)
    }

    // Gas efficiency
    analysis += "⚡ Gas Efficiency:\n"
    if totalObservations > 0 {
        avgGasPerObservation := float64(totalGasUsed) / float64(totalObservations)
        analysis += ufmt.Sprintf("   Average Gas per Observation: %.0f\n", avgGasPerObservation)
    }
    if totalDecisions > 0 {
        avgGasPerDecision := float64(totalGasUsed) / float64(totalDecisions)
        analysis += ufmt.Sprintf("   Average Gas per Decision: %.0f\n", avgGasPerDecision)
    }
    if len(learningHistory) > 0 {
        avgGasPerLearning := float64(totalGasUsed) / float64(len(learningHistory))
        analysis += ufmt.Sprintf("   Average Gas per Learning: %.0f\n\n", avgGasPerLearning)
    }

    // Recommendations
    analysis += "💡 Recommendations:\n"
    if averageBeliefAccuracy < 0.6 {
        analysis += "   • Consider providing more diverse observations\n"
        analysis += "   • Review reward structure for learning effectiveness\n"
    }
    if len(observationHistory) > maxHistorySize/2 {
        analysis += "   • History is filling up - consider increasing maxHistorySize\n"
    }
    if totalGasUsed > 1000000 {
        analysis += "   • High gas usage - consider optimization techniques\n"
    }

    return analysis
}

// ResetAgent resets the agent state (for testing/development)
func ResetAgent(caller string) string {
    // Only owner can reset
    if caller != owner {
        return "Access denied: only owner can reset agent"
    }

    // Reinitialize agent
    agent = active_inference_core.NewActiveInferenceAgent()

    // Clear history
    observationHistory = make([]ObservationRecord, 0)
    decisionHistory = make([]DecisionRecord, 0)
    learningHistory = make([]LearningRecord, 0)

    // Reset metrics
    totalObservations = 0
    totalDecisions = 0
    averageBeliefAccuracy = 0.5
    totalGasUsed = 0

    // Emit reset event
    std.Emit("AgentReset", map[string]interface{}{
        "resetBy": caller,
        "timestamp": std.BlockTime(),
    })

    return "Agent reset successfully"
}

// =============================================================================
// RENDER METHOD FOR BLOCKCHAIN QUERIES
// =============================================================================

// Render provides different views of the agent state for blockchain queries
func Render(path string) string {
    switch path {
    case "":
        return GetAgentStatus("")
    case "status":
        return GetAgentStatus("")
    case "beliefs":
        beliefs := agent.CurrentBeliefs
        result := "Current Beliefs: ["
        for i, belief := range beliefs {
            if i > 0 {
                result += ", "
            }
            result += ufmt.Sprintf("%.3f", belief)
        }
        result += "]"
        return result
    case "metrics":
        return ufmt.Sprintf("Observations: %d, Decisions: %d, Avg Accuracy: %.3f, Gas Used: %d",
            totalObservations, totalDecisions, averageBeliefAccuracy, totalGasUsed)
    case "performance":
        return AnalyzePerformance("")
    case "history":
        return GetObservationHistory("", 5)
    case "owner":
        return "Owner: " + owner
    default:
        return "Unknown path: " + path + ". Try: status, beliefs, metrics, performance, history, owner"
    }
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

// ValidateObservation checks if an observation is valid
func ValidateObservation(observation []methods.Probability) error {
    if len(observation) == 0 {
        return ufmt.Errorf("empty observation")
    }

    for i, prob := range observation {
        if prob < 0 || prob > 1 {
            return ufmt.Errorf("invalid probability at index %d: %f (must be between 0 and 1)", i, prob)
        }
    }

    return nil
}

// GetGasEstimate provides gas estimation for operations
func GetGasEstimate(operation string) uint64 {
    // Simplified gas estimation - in production, this would be more sophisticated
    switch operation {
    case "perceive":
        return 2000
    case "plan":
        return 3000
    case "act":
        return 1500
    case "learn":
        return 2500
    case "analyze":
        return 1000
    default:
        return 1000
    }
}

