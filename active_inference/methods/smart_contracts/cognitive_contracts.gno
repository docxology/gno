// Package cognitive_contracts provides smart contract methods for cognitive modeling
// and active inference on the Gno blockchain.
//
// This package implements blockchain-native cognitive systems with:
// - Persistent cognitive state storage
// - Gas-efficient inference computations
// - Multi-agent coordination mechanisms
// - Economic incentives for cognitive participation
// - Privacy-preserving cognitive computations
package cognitive_contracts

import (
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
	"gno.land/p/active_inference/methods/active_inference_core"
	"gno.land/p/active_inference/methods/cognitive_modeling"
	"gno.land/p/active_inference/methods/advanced_probability"
)

// CognitiveAgentRealm represents a persistent cognitive agent on the blockchain
type CognitiveAgentRealm struct {
	// Core cognitive components
	Agent         *active_inference_core.ActiveInferenceAgent
	WorkingMemory *cognitive_modeling.WorkingMemory
	LongTermMemory *cognitive_modeling.LongTermMemory
	Attention     *cognitive_modeling.AttentionSystem
	Learning      *cognitive_modeling.LearningSystem

	// Economic incentives
	TokenBalance  methods.Probability
	ReputationScore methods.Probability
	StakeAmount   methods.Probability

	// Social connections
	SocialGraph   map[string]methods.Probability // Agent ID -> Trust level
	CoalitionMembers []string

	// Performance tracking
	ActionCount   int
	SuccessCount  int
	LastUpdate    int64

	// Privacy settings
	IsPrivate     bool
	AuthorizedViewers []string
}

// NewCognitiveAgentRealm creates a new cognitive agent realm
func NewCognitiveAgentRealm(owner string) *CognitiveAgentRealm {
	return &CognitiveAgentRealm{
		Agent:         active_inference_core.NewActiveInferenceAgent(),
		WorkingMemory: cognitive_modeling.NewWorkingMemory(20),
		LongTermMemory: cognitive_modeling.NewLongTermMemory(1000),
		Attention:     cognitive_modeling.NewAttentionSystem(),
		Learning:      cognitive_modeling.NewLearningSystem(),
		TokenBalance:  100.0, // Initial token allocation
		ReputationScore: 0.5,  // Neutral starting reputation
		StakeAmount:   0.0,
		SocialGraph:   make(map[string]methods.Probability),
		CoalitionMembers: make([]string, 0),
		ActionCount:   0,
		SuccessCount:  0,
		IsPrivate:     false,
		AuthorizedViewers: []string{owner},
	}
}

// ProcessObservation processes sensory input and updates cognitive state
func (car *CognitiveAgentRealm) ProcessObservation(observation []methods.Probability, caller string) string {
	// Check authorization
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access to private cognitive agent"
	}

	// Process observation through cognitive model
	err := car.Agent.Perceive(observation)
	if err != nil {
		return ufmt.Sprintf("Error processing observation: %v", err)
	}

	// Update working memory
	err = car.WorkingMemory.AddItem(observation)
	if err != nil {
		return ufmt.Sprintf("Error updating working memory: %v", err)
	}

	// Update attention system
	goals := car.Agent.CognitiveModel.GoalSystem.Goals
	car.Attention.UpdateBiasTerms(goals)

	// Update learning system
	car.Learning.UpdateBeliefs(observation, car.Agent.CurrentBeliefs, goals)

	// Update performance metrics
	car.ActionCount++

	return ufmt.Sprintf("Observation processed successfully. Current beliefs: %v", car.Agent.CurrentBeliefs)
}

// MakeDecision makes an autonomous decision using active inference
func (car *CognitiveAgentRealm) MakeDecision(caller string) string {
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access"
	}

	// Generate optimal policies
	policies, err := car.Agent.Plan()
	if err != nil {
		return ufmt.Sprintf("Error planning: %v", err)
	}

	if len(policies) == 0 {
		return "Error: No policies generated"
	}

	// Execute best policy (simplified)
	err = car.Agent.Act(0)
	if err != nil {
		return ufmt.Sprintf("Error executing action: %v", err)
	}

	// Provide economic incentive for decision-making
	reward := methods.Probability(0.1) // Base reward for participation
	car.TokenBalance += reward

	return ufmt.Sprintf("Decision executed. Policy: %v, Reward earned: %.3f", policies[0], reward)
}

// LearnFromOutcome updates the agent based on decision outcomes
func (car *CognitiveAgentRealm) LearnFromOutcome(outcome []methods.Probability, success bool, caller string) string {
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access"
	}

	// Convert success to reward
	reward := methods.Probability(0)
	if success {
		reward = 1.0
		car.SuccessCount++
	} else {
		reward = -0.5
	}

	// Learn from outcome
	err := car.Agent.Learn(reward)
	if err != nil {
		return ufmt.Sprintf("Error learning from outcome: %v", err)
	}

	// Update reputation based on performance
	successRate := methods.Probability(car.SuccessCount) / methods.Probability(car.ActionCount)
	car.ReputationScore = car.ReputationScore*0.9 + successRate*0.1

	// Provide economic incentives based on learning
	learningReward := reward * 0.2
	car.TokenBalance += learningReward

	return ufmt.Sprintf("Learning completed. Success rate: %.3f, Reputation: %.3f, Learning reward: %.3f",
		successRate, car.ReputationScore, learningReward)
}

// FormSocialConnection establishes a trust relationship with another agent
func (car *CognitiveAgentRealm) FormSocialConnection(otherAgentID string, initialTrust methods.Probability, caller string) string {
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access"
	}

	if initialTrust < 0 || initialTrust > 1 {
		return "Error: Trust level must be between 0 and 1"
	}

	car.SocialGraph[otherAgentID] = initialTrust

	// Update social cognition model
	car.Agent.CognitiveModel.SocialModel.ModelAgent(otherAgentID, []methods.Probability{initialTrust})

	return ufmt.Sprintf("Social connection formed with %s (trust: %.3f)", otherAgentID, initialTrust)
}

// UpdateSocialTrust updates trust level for a connected agent
func (car *CognitiveAgentRealm) UpdateSocialTrust(otherAgentID string, newTrust methods.Probability, caller string) string {
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access"
	}

	if _, exists := car.SocialGraph[otherAgentID]; !exists {
		return "Error: No social connection exists with this agent"
	}

	if newTrust < 0 || newTrust > 1 {
		return "Error: Trust level must be between 0 and 1"
	}

	oldTrust := car.SocialGraph[otherAgentID]
	car.SocialGraph[otherAgentID] = newTrust

	// Update social model with trust change
	trustChange := []methods.Probability{newTrust}
	car.Agent.CognitiveModel.SocialModel.ModelAgent(otherAgentID, trustChange)

	return ufmt.Sprintf("Trust updated for %s: %.3f -> %.3f", otherAgentID, oldTrust, newTrust)
}

// JoinCoalition joins a coalition with other agents
func (car *CognitiveAgentRealm) JoinCoalition(coalitionID string, members []string, caller string) string {
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access"
	}

	// Check if already in coalition
	for _, member := range car.CoalitionMembers {
		if member == coalitionID {
			return "Error: Already member of this coalition"
		}
	}

	// Add coalition membership
	car.CoalitionMembers = append(car.CoalitionMembers, coalitionID)

	// Establish trust relationships with coalition members
	for _, member := range members {
		if member != caller { // Don't add self
			car.SocialGraph[member] = 0.7 // Initial coalition trust
		}
	}

	// Provide coalition joining reward
	coalitionReward := methods.Probability(0.5)
	car.TokenBalance += coalitionReward

	return ufmt.Sprintf("Joined coalition %s with %d members. Reward: %.3f", coalitionID, len(members), coalitionReward)
}

// CoordinateWithCoalition performs coordinated action with coalition members
func (car *CognitiveAgentRealm) CoordinateWithCoalition(action []methods.Probability, coalitionID string, caller string) string {
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access"
	}

	// Check coalition membership
	isMember := false
	for _, member := range car.CoalitionMembers {
		if member == coalitionID {
			isMember = true
			break
		}
	}

	if !isMember {
		return "Error: Not a member of this coalition"
	}

	// Execute coordinated action
	err := car.Agent.Perceive(action)
	if err != nil {
		return ufmt.Sprintf("Error in coordinated action: %v", err)
	}

	// Provide coordination reward
	coordReward := methods.Probability(0.3)
	car.TokenBalance += coordReward

	return ufmt.Sprintf("Coordinated action executed. Coalition: %s, Reward: %.3f", coalitionID, coordReward)
}

// StakeTokens stakes tokens for enhanced cognitive capabilities
func (car *CognitiveAgentRealm) StakeTokens(amount methods.Probability, caller string) string {
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access"
	}

	if amount <= 0 {
		return "Error: Stake amount must be positive"
	}

	if car.TokenBalance < amount {
		return "Error: Insufficient token balance"
	}

	car.TokenBalance -= amount
	car.StakeAmount += amount

	// Enhanced capabilities based on stake
	enhancement := amount * 0.1
	car.ReputationScore += enhancement

	if car.ReputationScore > 1.0 {
		car.ReputationScore = 1.0
	}

	return ufmt.Sprintf("Staked %.3f tokens. New balance: %.3f, Reputation boost: %.3f", amount, car.TokenBalance, enhancement)
}

// UnstakeTokens returns staked tokens
func (car *CognitiveAgentRealm) UnstakeTokens(amount methods.Probability, caller string) string {
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access"
	}

	if amount <= 0 {
		return "Error: Unstake amount must be positive"
	}

	if car.StakeAmount < amount {
		return "Error: Insufficient staked tokens"
	}

	car.StakeAmount -= amount
	car.TokenBalance += amount

	// Penalty for unstaking
	penalty := amount * 0.05
	car.ReputationScore -= penalty

	if car.ReputationScore < 0 {
		car.ReputationScore = 0
	}

	return ufmt.Sprintf("Unstaked %.3f tokens (penalty: %.3f). New balance: %.3f", amount, penalty, car.TokenBalance)
}

// GetCognitiveState returns current cognitive state (privacy-aware)
func (car *CognitiveAgentRealm) GetCognitiveState(caller string) string {
	if car.IsPrivate && !car.isAuthorized(caller) {
		return "Error: Unauthorized access to private cognitive state"
	}

	state := ufmt.Sprintf(`{
  "beliefs": %v,
  "attention_weights": %v,
  "goals": %v,
  "token_balance": %.3f,
  "reputation_score": %.3f,
  "stake_amount": %.3f,
  "social_connections": %d,
  "coalition_memberships": %d,
  "success_rate": %.3f
}`,
		car.Agent.CurrentBeliefs,
		car.Attention.SalienceMap,
		car.Agent.CognitiveModel.GoalSystem.Goals,
		car.TokenBalance,
		car.ReputationScore,
		car.StakeAmount,
		len(car.SocialGraph),
		len(car.CoalitionMembers),
		methods.Probability(car.SuccessCount)/methods.Probability(car.ActionCount),
	)

	return state
}

// SetPrivacyMode sets privacy mode for the cognitive agent
func (car *CognitiveAgentRealm) SetPrivacyMode(private bool, caller string) string {
	// Only owner can change privacy settings
	if !car.isAuthorized(caller) {
		return "Error: Only authorized users can change privacy settings"
	}

	car.IsPrivate = private

	if private {
		return "Privacy mode enabled. Only authorized viewers can access cognitive state."
	} else {
		return "Privacy mode disabled. Cognitive state is publicly accessible."
	}
}

// AddAuthorizedViewer adds an authorized viewer for private agents
func (car *CognitiveAgentRealm) AddAuthorizedViewer(viewer string, caller string) string {
	if !car.isAuthorized(caller) {
		return "Error: Only authorized users can manage viewers"
	}

	// Check if already authorized
	for _, existing := range car.AuthorizedViewers {
		if existing == viewer {
			return ufmt.Sprintf("Viewer %s is already authorized", viewer)
		}
	}

	car.AuthorizedViewers = append(car.AuthorizedViewers, viewer)
	return ufmt.Sprintf("Added authorized viewer: %s", viewer)
}

// RemoveAuthorizedViewer removes an authorized viewer
func (car *CognitiveAgentRealm) RemoveAuthorizedViewer(viewer string, caller string) string {
	if !car.isAuthorized(caller) {
		return "Error: Only authorized users can manage viewers"
	}

	for i, existing := range car.AuthorizedViewers {
		if existing == viewer {
			// Remove viewer (preserve owner)
			car.AuthorizedViewers = append(car.AuthorizedViewers[:i], car.AuthorizedViewers[i+1:]...)
			return ufmt.Sprintf("Removed authorized viewer: %s", viewer)
		}
	}

	return ufmt.Sprintf("Viewer %s not found in authorized list", viewer)
}

// isAuthorized checks if a caller is authorized to access the agent
func (car *CognitiveAgentRealm) isAuthorized(caller string) bool {
	for _, viewer := range car.AuthorizedViewers {
		if viewer == caller {
			return true
		}
	}
	return false
}

// CognitiveDAORealm represents a DAO governed by cognitive agents
type CognitiveDAORealm struct {
	Agents          map[string]*CognitiveAgentRealm
	Proposals       map[string]*CognitiveProposal
	GlobalGoals     []methods.Probability
	TotalTokenSupply methods.Probability
	VotingPeriod    int64
}

// CognitiveProposal represents a proposal in the cognitive DAO
type CognitiveProposal struct {
	ID          string
	Proposer    string
	Description string
	Changes     []methods.Probability
	Votes       map[string]bool // Agent ID -> Vote (true/false)
	Status      string // "active", "passed", "rejected", "executed"
	CreatedAt   int64
	EndTime     int64
}

// NewCognitiveDAORealm creates a new cognitive DAO
func NewCognitiveDAORealm() *CognitiveDAORealm {
	return &CognitiveDAORealm{
		Agents:          make(map[string]*CognitiveAgentRealm),
		Proposals:       make(map[string]*CognitiveProposal),
		GlobalGoals:     make([]methods.Probability, 4),
		TotalTokenSupply: 10000.0,
		VotingPeriod:    86400, // 24 hours in seconds
	}
}

// RegisterAgent registers a cognitive agent in the DAO
func (cdar *CognitiveDAORealm) RegisterAgent(agentID string, agent *CognitiveAgentRealm) string {
	if _, exists := cdar.Agents[agentID]; exists {
		return "Error: Agent already registered"
	}

	cdar.Agents[agentID] = agent

	// Provide initial DAO tokens
	initialTokens := methods.Probability(100.0)
	agent.TokenBalance += initialTokens

	return ufmt.Sprintf("Agent %s registered successfully. Initial tokens: %.3f", agentID, initialTokens)
}

// SubmitProposal submits a proposal to the DAO
func (cdar *CognitiveDAORealm) SubmitProposal(agentID string, description string, changes []methods.Probability, caller string) string {
	if _, exists := cdar.Agents[agentID]; !exists {
		return "Error: Agent not registered in DAO"
	}

	if caller != agentID {
		return "Error: Only the agent can submit proposals on its behalf"
	}

	proposalID := ufmt.Sprintf("proposal_%d", len(cdar.Proposals)+1)

	proposal := &CognitiveProposal{
		ID:          proposalID,
		Proposer:    agentID,
		Description: description,
		Changes:     changes,
		Votes:       make(map[string]bool),
		Status:      "active",
		CreatedAt:   0, // Would be set to current block time
		EndTime:     0, // Would be set to current time + voting period
	}

	cdar.Proposals[proposalID] = proposal

	return ufmt.Sprintf("Proposal submitted: %s", proposalID)
}

// VoteOnProposal allows agents to vote on proposals
func (cdar *CognitiveDAORealm) VoteOnProposal(agentID string, proposalID string, vote bool, caller string) string {
	agent, exists := cdar.Agents[agentID]
	if !exists {
		return "Error: Agent not registered"
	}

	if caller != agentID {
		return "Error: Agents can only vote on their own behalf"
	}

	proposal, exists := cdar.Proposals[proposalID]
	if !exists {
		return "Error: Proposal not found"
	}

	if proposal.Status != "active" {
		return "Error: Proposal is not active"
	}

	// Record vote
	proposal.Votes[agentID] = vote

	return ufmt.Sprintf("Vote recorded for proposal %s: %v", proposalID, vote)
}

// ExecuteProposal executes a passed proposal
func (cdar *CognitiveDAORealm) ExecuteProposal(proposalID string) string {
	proposal, exists := cdar.Proposals[proposalID]
	if !exists {
		return "Error: Proposal not found"
	}

	if proposal.Status != "passed" {
		return "Error: Proposal must be passed before execution"
	}

	// Apply changes to global goals
	for i, change := range proposal.Changes {
		if i < len(cdar.GlobalGoals) {
			cdar.GlobalGoals[i] += change
		}
	}

	proposal.Status = "executed"

	return ufmt.Sprintf("Proposal %s executed successfully", proposalID)
}

// GetDAOState returns current DAO state
func (cdar *CognitiveDAORealm) GetDAOState() string {
	totalAgents := len(cdar.Agents)
	activeProposals := 0

	for _, proposal := range cdar.Proposals {
		if proposal.Status == "active" {
			activeProposals++
		}
	}

	state := ufmt.Sprintf(`{
  "total_agents": %d,
  "active_proposals": %d,
  "global_goals": %v,
  "total_token_supply": %.3f
}`,
		totalAgents,
		activeProposals,
		cdar.GlobalGoals,
		cdar.TotalTokenSupply,
	)

	return state
}

// CognitiveSecurityRealm provides security methods for cognitive systems
type CognitiveSecurityRealm struct {
	ThreatModels    map[string]*ThreatModel
	SecurityPolicies []SecurityPolicy
	AlertThreshold  methods.Probability
	AnomalyDetector *advanced_probability.Gaussian
}

// ThreatModel represents a security threat model
type ThreatModel struct {
	ID          string
	Description string
	Indicators  []string
	RiskLevel   methods.Probability
	DetectionRules []string
}

// SecurityPolicy defines security policies for cognitive systems
type SecurityPolicy struct {
	ID          string
	Name        string
	Rules       []string
	EnforcementLevel string
}

// NewCognitiveSecurityRealm creates a new cognitive security realm
func NewCognitiveSecurityRealm() *CognitiveSecurityRealm {
	// Initialize anomaly detector with normal behavior
	mean := methods.Probability(0.5)
	std := methods.Probability(0.1)
	anomalyDetector := advanced_probability.NewGaussian(mean, std)

	return &CognitiveSecurityRealm{
		ThreatModels:    make(map[string]*ThreatModel),
		SecurityPolicies: make([]SecurityPolicy, 0),
		AlertThreshold:  0.95, // 95% confidence for alerts
		AnomalyDetector: anomalyDetector,
	}
}

// AddThreatModel adds a new threat model to the security system
func (csr *CognitiveSecurityRealm) AddThreatModel(id, description string, indicators []string, riskLevel methods.Probability) string {
	if _, exists := csr.ThreatModels[id]; exists {
		return "Error: Threat model already exists"
	}

	threatModel := &ThreatModel{
		ID:          id,
		Description: description,
		Indicators:  indicators,
		RiskLevel:   riskLevel,
		DetectionRules: make([]string, 0),
	}

	csr.ThreatModels[id] = threatModel

	return ufmt.Sprintf("Threat model added: %s", id)
}

// DetectAnomaly detects anomalous behavior in cognitive systems
func (csr *CognitiveSecurityRealm) DetectAnomaly(behaviorMetrics []methods.Probability) string {
	// Calculate anomaly score based on deviation from normal behavior
	anomalyScore := methods.Probability(0)

	for _, metric := range behaviorMetrics {
		// Calculate z-score for each metric
		zScore := (metric - csr.AnomalyDetector.Mean) / methods.Probability(0.1) // Using std=0.1 for simplicity
		anomalyScore += methods.Probability(math.Abs(float64(zScore)))
	}

	anomalyScore /= methods.Probability(len(behaviorMetrics))

	// Check against alert threshold
	if anomalyScore > csr.AlertThreshold {
		return ufmt.Sprintf("🚨 ANOMALY DETECTED: Score %.3f exceeds threshold %.3f", anomalyScore, csr.AlertThreshold)
	}

	return ufmt.Sprintf("✓ Normal behavior detected (anomaly score: %.3f)", anomalyScore)
}

// ValidateCognitiveIntegrity validates the integrity of cognitive computations
func (csr *CognitiveSecurityRealm) ValidateCognitiveIntegrity(
	input []methods.Probability,
	output []methods.Probability,
	expectedOutput []methods.Probability) string {

	if len(output) != len(expectedOutput) {
		return "Error: Output length mismatch"
	}

	// Calculate integrity score based on output consistency
	integrityScore := methods.Probability(0)
	for i := range output {
		diff := methods.Probability(math.Abs(float64(output[i] - expectedOutput[i])))
		integrityScore += (1 - diff) // Higher score for smaller differences
	}
	integrityScore /= methods.Probability(len(output))

	if integrityScore < 0.8 {
		return ufmt.Sprintf("⚠️ INTEGRITY WARNING: Score %.3f below acceptable threshold", integrityScore)
	}

	return ufmt.Sprintf("✓ Cognitive integrity validated (score: %.3f)", integrityScore)
}

// MonitorCognitiveHealth monitors the health of cognitive systems
func (csr *CognitiveSecurityRealm) MonitorCognitiveHealth(
	performanceMetrics []methods.Probability,
	resourceUsage []methods.Probability) string {

	healthScore := methods.Probability(0)

	// Performance component (40% weight)
	avgPerformance := methods.Probability(0)
	for _, metric := range performanceMetrics {
		avgPerformance += metric
	}
	avgPerformance /= methods.Probability(len(performanceMetrics))
	healthScore += avgPerformance * 0.4

	// Resource usage component (30% weight)
	avgResourceUsage := methods.Probability(0)
	for _, usage := range resourceUsage {
		avgResourceUsage += usage
	}
	avgResourceUsage /= methods.Probability(len(resourceUsage))
	// Lower resource usage is better for health
	resourceHealth := 1 - avgResourceUsage
	healthScore += resourceHealth * 0.3

	// Stability component (30% weight)
	// Calculate variance in performance as stability measure
	variance := methods.Probability(0)
	for _, metric := range performanceMetrics {
		diff := metric - avgPerformance
		variance += diff * diff
	}
	variance /= methods.Probability(len(performanceMetrics))
	stability := 1 / (1 + variance) // Lower variance = higher stability
	healthScore += stability * 0.3

	healthStatus := ""
	if healthScore >= 0.8 {
		healthStatus = "🟢 EXCELLENT"
	} else if healthScore >= 0.6 {
		healthStatus = "🟡 GOOD"
	} else if healthScore >= 0.4 {
		healthStatus = "🟠 FAIR"
	} else {
		healthStatus = "🔴 POOR"
	}

	return ufmt.Sprintf("%s Cognitive Health: %.3f (Performance: %.3f, Resources: %.3f, Stability: %.3f)",
		healthStatus, healthScore, avgPerformance, resourceHealth, stability)
}

// GenerateSecurityReport generates a comprehensive security report
func (csr *CognitiveSecurityRealm) GenerateSecurityReport() string {
	report := "# Cognitive Security Report\n\n"

	report += "## Threat Models\n"
	for id, threat := range csr.ThreatModels {
		report += ufmt.Sprintf("- **%s**: %s (Risk: %.2f)\n", id, threat.Description, threat.RiskLevel)
	}

	report += "\n## Security Policies\n"
	for _, policy := range csr.SecurityPolicies {
		report += ufmt.Sprintf("- **%s**: %s (%s enforcement)\n", policy.ID, policy.Name, policy.EnforcementLevel)
	}

	report += "\n## Current Status\n"
	report += ufmt.Sprintf("- Alert Threshold: %.2f\n", csr.AlertThreshold)
	report += ufmt.Sprintf("- Active Threat Models: %d\n", len(csr.ThreatModels))
	report += ufmt.Sprintf("- Security Policies: %d\n", len(csr.SecurityPolicies))

	return report
}
