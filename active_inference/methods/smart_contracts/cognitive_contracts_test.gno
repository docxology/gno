// Package cognitive_contracts_test provides comprehensive tests for cognitive smart contracts
package cognitive_contracts

import (
	"math"
	"testing"
	"gno.land/p/active_inference/methods"
)

func TestNewCognitiveAgentRealm(t *testing.T) {
	owner := "test_owner"
	agent := NewCognitiveAgentRealm(owner)

	if agent.Agent == nil {
		t.Error("Expected non-nil agent")
	}

	if agent.WorkingMemory == nil {
		t.Error("Expected non-nil working memory")
	}

	if agent.LongTermMemory == nil {
		t.Error("Expected non-nil long-term memory")
	}

	if agent.TokenBalance != 100.0 {
		t.Errorf("Expected initial token balance 100.0, got %f", agent.TokenBalance)
	}

	if agent.ReputationScore != 0.5 {
		t.Errorf("Expected initial reputation 0.5, got %f", agent.ReputationScore)
	}

	if len(agent.AuthorizedViewers) != 1 || agent.AuthorizedViewers[0] != owner {
		t.Error("Expected owner to be in authorized viewers")
	}
}

func TestProcessObservation(t *testing.T) {
	agent := NewCognitiveAgentRealm("owner")
	observation := []methods.Probability{0.6, 0.4, 0.7, 0.3}

	// Test successful processing
	result := agent.ProcessObservation(observation, "owner")
	if !contains(result, "Observation processed successfully") {
		t.Errorf("Expected successful processing, got: %s", result)
	}

	// Verify belief updates
	if len(agent.Agent.CurrentBeliefs) != len(observation) {
		t.Error("Beliefs not updated correctly")
	}

	// Test unauthorized access
	agent.IsPrivate = true
	result = agent.ProcessObservation(observation, "unauthorized")
	if !contains(result, "Unauthorized access") {
		t.Errorf("Expected unauthorized error, got: %s", result)
	}

	agent.IsPrivate = false // Reset for other tests
}

func TestMakeDecision(t *testing.T) {
	agent := NewCognitiveAgentRealm("owner")
	initialBalance := agent.TokenBalance

	// Test successful decision making
	result := agent.MakeDecision("owner")
	if !contains(result, "Decision executed") {
		t.Errorf("Expected successful decision, got: %s", result)
	}

	// Verify token reward
	if agent.TokenBalance <= initialBalance {
		t.Error("Expected token balance to increase after decision")
	}

	// Test unauthorized access
	agent.IsPrivate = true
	result = agent.MakeDecision("unauthorized")
	if !contains(result, "Unauthorized access") {
		t.Errorf("Expected unauthorized error, got: %s", result)
	}
}

func TestLearnFromOutcome(t *testing.T) {
	agent := NewCognitiveAgentRealm("owner")
	outcome := []methods.Probability{0.8, 0.6, 0.9, 0.4}
	initialBalance := agent.TokenBalance
	initialReputation := agent.ReputationScore

	// Test successful learning
	result := agent.LearnFromOutcome(outcome, true, "owner")
	if !contains(result, "Learning completed") {
		t.Errorf("Expected successful learning, got: %s", result)
	}

	// Verify performance updates
	if agent.SuccessCount != 1 {
		t.Error("Success count not updated")
	}

	if agent.TokenBalance <= initialBalance {
		t.Error("Expected token reward for learning")
	}

	// Test with failure
	result = agent.LearnFromOutcome(outcome, false, "owner")
	if agent.SuccessCount != 1 {
		t.Error("Success count should remain 1 after failure")
	}

	// Test unauthorized access
	agent.IsPrivate = true
	result = agent.LearnFromOutcome(outcome, true, "unauthorized")
	if !contains(result, "Unauthorized access") {
		t.Errorf("Expected unauthorized error, got: %s", result)
	}
}

func TestSocialConnections(t *testing.T) {
	agent := NewCognitiveAgentRealm("owner")
	otherAgent := "agent2"

	// Test forming social connection
	result := agent.FormSocialConnection(otherAgent, 0.8, "owner")
	if !contains(result, "Social connection formed") {
		t.Errorf("Expected successful connection, got: %s", result)
	}

	// Verify trust level
	if trust, exists := agent.SocialGraph[otherAgent]; !exists || trust != 0.8 {
		t.Errorf("Expected trust level 0.8, got %f", trust)
	}

	// Test updating trust
	result = agent.UpdateSocialTrust(otherAgent, 0.6, "owner")
	if !contains(result, "Trust updated") {
		t.Errorf("Expected successful trust update, got: %s", result)
	}

	if agent.SocialGraph[otherAgent] != 0.6 {
		t.Error("Trust level not updated correctly")
	}

	// Test updating non-existent connection
	result = agent.UpdateSocialTrust("nonexistent", 0.5, "owner")
	if !contains(result, "No social connection exists") {
		t.Errorf("Expected error for non-existent connection, got: %s", result)
	}
}

func TestCoalitionOperations(t *testing.T) {
	agent := NewCognitiveAgentRealm("owner")
	coalitionID := "test_coalition"
	members := []string{"agent2", "agent3", "owner"}

	// Test joining coalition
	result := agent.JoinCoalition(coalitionID, members, "owner")
	if !contains(result, "Joined coalition") {
		t.Errorf("Expected successful coalition join, got: %s", result)
	}

	// Verify coalition membership
	found := false
	for _, member := range agent.CoalitionMembers {
		if member == coalitionID {
			found = true
			break
		}
	}
	if !found {
		t.Error("Coalition membership not recorded")
	}

	// Test coordinated action
	action := []methods.Probability{0.7, 0.5, 0.8, 0.3}
	result = agent.CoordinateWithCoalition(action, coalitionID, "owner")
	if !contains(result, "Coordinated action executed") {
		t.Errorf("Expected successful coordination, got: %s", result)
	}

	// Test coordination with non-member
	result = agent.CoordinateWithCoalition(action, "other_coalition", "owner")
	if !contains(result, "Not a member") {
		t.Errorf("Expected membership error, got: %s", result)
	}
}

func TestStakingOperations(t *testing.T) {
	agent := NewCognitiveAgentRealm("owner")
	initialBalance := agent.TokenBalance
	stakeAmount := methods.Probability(50.0)

	// Test staking
	result := agent.StakeTokens(stakeAmount, "owner")
	if !contains(result, "Staked") {
		t.Errorf("Expected successful staking, got: %s", result)
	}

	// Verify staking effects
	if agent.TokenBalance != initialBalance-stakeAmount {
		t.Error("Token balance not updated correctly after staking")
	}

	if agent.StakeAmount != stakeAmount {
		t.Error("Stake amount not recorded correctly")
	}

	// Test unstaking
	result = agent.UnstakeTokens(stakeAmount, "owner")
	if !contains(result, "Unstaked") {
		t.Errorf("Expected successful unstaking, got: %s", result)
	}

	// Verify unstaking effects
	if agent.StakeAmount != 0 {
		t.Error("Stake amount should be zero after unstaking")
	}

	// Test staking insufficient funds
	result = agent.StakeTokens(1000.0, "owner")
	if !contains(result, "Insufficient token balance") {
		t.Errorf("Expected insufficient funds error, got: %s", result)
	}
}

func TestPrivacyControls(t *testing.T) {
	agent := NewCognitiveAgentRealm("owner")

	// Test setting privacy mode
	result := agent.SetPrivacyMode(true, "owner")
	if !contains(result, "Privacy mode enabled") {
		t.Errorf("Expected privacy mode enabled, got: %s", result)
	}

	if !agent.IsPrivate {
		t.Error("Privacy mode not set correctly")
	}

	// Test adding authorized viewer
	result = agent.AddAuthorizedViewer("viewer1", "owner")
	if !contains(result, "Added authorized viewer") {
		t.Errorf("Expected viewer added, got: %s", result)
	}

	// Test accessing private agent
	result = agent.GetCognitiveState("viewer1")
	if contains(result, "Unauthorized access") {
		t.Error("Authorized viewer should have access")
	}

	// Test unauthorized access
	result = agent.GetCognitiveState("unauthorized")
	if !contains(result, "Unauthorized access") {
		t.Errorf("Expected unauthorized error, got: %s", result)
	}

	// Test removing viewer
	result = agent.RemoveAuthorizedViewer("viewer1", "owner")
	if !contains(result, "Removed authorized viewer") {
		t.Errorf("Expected viewer removed, got: %s", result)
	}
}

func TestCognitiveDAORealm(t *testing.T) {
	dao := NewCognitiveDAORealm()

	// Test registering agent
	agent := NewCognitiveAgentRealm("agent1")
	result := dao.RegisterAgent("agent1", agent)
	if !contains(result, "registered successfully") {
		t.Errorf("Expected successful registration, got: %s", result)
	}

	// Verify agent registration
	if _, exists := dao.Agents["agent1"]; !exists {
		t.Error("Agent not registered in DAO")
	}

	// Test submitting proposal
	result = dao.SubmitProposal("agent1", "Test proposal", []methods.Probability{0.1, 0.2, 0.3, 0.4}, "agent1")
	if !contains(result, "Proposal submitted") {
		t.Errorf("Expected successful proposal submission, got: %s", result)
	}

	// Test voting on proposal
	result = dao.VoteOnProposal("agent1", "proposal_1", true, "agent1")
	if !contains(result, "Vote recorded") {
		t.Errorf("Expected successful voting, got: %s", result)
	}

	// Test DAO state
	state := dao.GetDAOState()
	if !contains(state, "total_agents") {
		t.Errorf("Expected DAO state info, got: %s", state)
	}
}

func TestCognitiveSecurity(t *testing.T) {
	security := NewCognitiveSecurityRealm()

	// Test adding threat model
	result := security.AddThreatModel("threat1", "Test threat", []string{"indicator1", "indicator2"}, 0.8)
	if !contains(result, "Threat model added") {
		t.Errorf("Expected successful threat model addition, got: %s", result)
	}

	// Test anomaly detection
	normalBehavior := []methods.Probability{0.5, 0.48, 0.52, 0.49}
	result = security.DetectAnomaly(normalBehavior)
	if !contains(result, "Normal behavior") {
		t.Errorf("Expected normal behavior detection, got: %s", result)
	}

	// Test anomaly detection with anomalous data
	anomalousBehavior := []methods.Probability{0.9, 0.1, 0.95, 0.05}
	result = security.DetectAnomaly(anomalousBehavior)
	if !contains(result, "ANOMALY DETECTED") {
		t.Errorf("Expected anomaly detection, got: %s", result)
	}

	// Test cognitive integrity validation
	input := []methods.Probability{0.5, 0.5, 0.5, 0.5}
	output := []methods.Probability{0.6, 0.4, 0.7, 0.3}
	expected := []methods.Probability{0.55, 0.45, 0.65, 0.35}

	result = security.ValidateCognitiveIntegrity(input, output, expected)
	if !contains(result, "integrity validated") {
		t.Errorf("Expected integrity validation success, got: %s", result)
	}

	// Test cognitive health monitoring
	performance := []methods.Probability{0.8, 0.85, 0.75, 0.9}
	resources := []methods.Probability{0.3, 0.25, 0.35, 0.2}

	result = security.MonitorCognitiveHealth(performance, resources)
	if !contains(result, "Cognitive Health") {
		t.Errorf("Expected health monitoring result, got: %s", result)
	}

	// Test security report generation
	report := security.GenerateSecurityReport()
	if !contains(report, "Cognitive Security Report") {
		t.Errorf("Expected security report, got: %s", report)
	}
}

func TestIntegrationScenarios(t *testing.T) {
	// Test complete cognitive agent workflow
	agent := NewCognitiveAgentRealm("test_user")

	// 1. Process observations
	observations := [][]methods.Probability{
		{0.6, 0.4, 0.7, 0.3},
		{0.8, 0.2, 0.9, 0.1},
		{0.4, 0.6, 0.3, 0.7},
	}

	for _, obs := range observations {
		result := agent.ProcessObservation(obs, "test_user")
		if contains(result, "Error") {
			t.Errorf("Unexpected error in observation processing: %s", result)
		}
	}

	// 2. Make decisions
	for i := 0; i < 3; i++ {
		result := agent.MakeDecision("test_user")
		if contains(result, "Error") {
			t.Errorf("Unexpected error in decision making: %s", result)
		}
	}

	// 3. Learn from outcomes
	outcomes := []bool{true, false, true}
	for _, success := range outcomes {
		outcome := []methods.Probability{0.8, 0.6, 0.9, 0.4}
		result := agent.LearnFromOutcome(outcome, success, "test_user")
		if contains(result, "Error") {
			t.Errorf("Unexpected error in learning: %s", result)
		}
	}

	// 4. Form social connections
	agent.FormSocialConnection("friend1", 0.8, "test_user")
	agent.FormSocialConnection("friend2", 0.6, "test_user")

	// 5. Join coalition
	members := []string{"friend1", "friend2", "test_user"}
	agent.JoinCoalition("team_alpha", members, "test_user")

	// 6. Verify final state
	if agent.ActionCount != 6 { // 3 observations + 3 decisions
		t.Errorf("Expected 6 actions, got %d", agent.ActionCount)
	}

	if agent.SuccessCount != 2 { // 2 successful outcomes
		t.Errorf("Expected 2 successes, got %d", agent.SuccessCount)
	}

	if len(agent.SocialGraph) != 2 {
		t.Errorf("Expected 2 social connections, got %d", len(agent.SocialGraph))
	}

	if len(agent.CoalitionMembers) != 1 {
		t.Errorf("Expected 1 coalition membership, got %d", len(agent.CoalitionMembers))
	}

	// 7. Test privacy controls
	agent.SetPrivacyMode(true, "test_user")
	agent.AddAuthorizedViewer("trusted_user", "test_user")

	// Authorized access should work
	state := agent.GetCognitiveState("trusted_user")
	if contains(state, "Unauthorized") {
		t.Error("Authorized user should have access to private agent")
	}

	// Unauthorized access should fail
	state = agent.GetCognitiveState("random_user")
	if !contains(state, "Unauthorized") {
		t.Error("Unauthorized user should not have access to private agent")
	}
}

func TestEconomicIncentives(t *testing.T) {
	agent := NewCognitiveAgentRealm("test_user")
	initialBalance := agent.TokenBalance

	// Test decision-making rewards
	agent.MakeDecision("test_user")
	if agent.TokenBalance <= initialBalance {
		t.Error("Expected token reward for decision making")
	}

	decisionReward := agent.TokenBalance - initialBalance
	initialBalance = agent.TokenBalance

	// Test learning rewards
	outcome := []methods.Probability{0.8, 0.6, 0.9, 0.4}
	agent.LearnFromOutcome(outcome, true, "test_user")
	if agent.TokenBalance <= initialBalance {
		t.Error("Expected token reward for learning")
	}

	learningReward := agent.TokenBalance - initialBalance
	initialBalance = agent.TokenBalance

	// Test staking rewards
	stakeAmount := methods.Probability(20.0)
	agent.StakeTokens(stakeAmount, "test_user")
	if agent.StakeAmount != stakeAmount {
		t.Error("Staking not recorded correctly")
	}

	// Test coalition rewards
	members := []string{"agent2", "agent3", "test_user"}
	agent.JoinCoalition("test_coalition", members, "test_user")
	if agent.TokenBalance <= initialBalance {
		t.Error("Expected token reward for joining coalition")
	}

	// Verify all rewards are positive
	if decisionReward <= 0 || learningReward <= 0 {
		t.Error("All rewards should be positive")
	}

	// Test reputation system
	if agent.ReputationScore < 0 || agent.ReputationScore > 1 {
		t.Errorf("Reputation score should be between 0 and 1, got %f", agent.ReputationScore)
	}
}

// Helper function to check if string contains substring
func contains(s, substr string) bool {
	return len(s) >= len(substr) && findSubstring(s, substr) >= 0
}

func findSubstring(s, substr string) int {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return i
		}
	}
	return -1
}

// Additional test helper functions
func TestDAOGovernance(t *testing.T) {
	dao := NewCognitiveDAORealm()

	// Register multiple agents
	agents := make([]*CognitiveAgentRealm, 3)
	agentIDs := []string{"alice", "bob", "charlie"}

	for i, id := range agentIDs {
		agents[i] = NewCognitiveAgentRealm(id)
		dao.RegisterAgent(id, agents[i])
	}

	// Submit proposal
	changes := []methods.Probability{0.1, -0.05, 0.2, 0.0}
	dao.SubmitProposal("alice", "Update global goals", changes, "alice")

	// Vote on proposal
	dao.VoteOnProposal("alice", "proposal_1", true, "alice")
	dao.VoteOnProposal("bob", "proposal_1", true, "bob")
	dao.VoteOnProposal("charlie", "proposal_1", false, "charlie")

	// Check proposal status (would need to implement voting logic)
	// This tests the basic voting infrastructure
}

func TestSecurityMonitoring(t *testing.T) {
	security := NewCognitiveSecurityRealm()

	// Add multiple threat models
	threats := []struct {
		id          string
		description string
		risk        methods.Probability
	}{
		{"adversarial_input", "Adversarial input manipulation", 0.9},
		{"model_poisoning", "Training data poisoning", 0.8},
		{"inference_attack", "Inference-time attacks", 0.7},
	}

	for _, threat := range threats {
		result := security.AddThreatModel(threat.id, threat.description, []string{}, threat.risk)
		if !contains(result, "Threat model added") {
			t.Errorf("Failed to add threat model: %s", threat.id)
		}
	}

	// Test comprehensive monitoring
	metrics := []methods.Probability{0.5, 0.6, 0.4, 0.7, 0.3}
	anomalyResult := security.DetectAnomaly(metrics)

	healthMetrics := []methods.Probability{0.8, 0.75, 0.85, 0.9}
	resourceMetrics := []methods.Probability{0.3, 0.25, 0.35, 0.2}
	healthResult := security.MonitorCognitiveHealth(healthMetrics, resourceMetrics)

	if !contains(anomalyResult, "Normal behavior") && !contains(anomalyResult, "ANOMALY DETECTED") {
		t.Error("Anomaly detection should return clear result")
	}

	if !contains(healthResult, "Cognitive Health") {
		t.Error("Health monitoring should return health assessment")
	}
}
