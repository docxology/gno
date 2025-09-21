// Package cognitive_modeling provides cognitive modeling primitives for active inference
// on the Gno blockchain.
//
// This package implements cognitive architectures that combine:
// - Working memory and long-term memory systems
// - Attention mechanisms and salience maps
// - Learning mechanisms (reinforcement learning, habit formation)
// - Goal-directed behavior and metacognition
// - Social cognition and theory of mind
package cognitive_modeling

import (
	"math"
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
	"gno.land/p/active_inference/methods/free_energy_principle"
)

// CognitiveModel represents a complete cognitive architecture
type CognitiveModel struct {
	// Core cognitive systems
	WorkingMemory  *WorkingMemory
	LongTermMemory *LongTermMemory
	Attention      *AttentionSystem
	Learning       *LearningSystem

	// Executive control
	GoalSystem     *GoalSystem
	MetaCognition  *MetaCognition

	// Social cognition
	SocialModel    *SocialCognition

	// Active inference integration
	FreeEnergy     *free_energy_principle.VariationalInference
	ActiveInference *free_energy_principle.ActiveInference

	// Current cognitive state
	CurrentState   CognitiveState
}

// CognitiveState represents the current state of the cognitive system
type CognitiveState struct {
	AttentionFocus []methods.Probability
	EmotionalState []methods.Probability
	MotivationalState []methods.Probability
	SocialContext   []methods.Probability
	TimeHorizon     int // How far ahead the system plans
}

// NewCognitiveModel creates a new cognitive model
func NewCognitiveModel() *CognitiveModel {
	// Create generative model for active inference
	generativeModel := free_energy_principle.NewGenerativeModel(3, 4)

	// Define policies for active inference
	policies := [][]int{
		{0, 0}, {0, 1}, {1, 0}, {1, 1}, // Simple policies
		{0, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 1, 1}, // Extended policies
		{1, 0, 0}, {1, 0, 1}, {1, 1, 0}, {1, 1, 1},
	}

	activeInf := free_energy_principle.NewActiveInference(generativeModel, policies)

	return &CognitiveModel{
		WorkingMemory:   NewWorkingMemory(10), // Capacity of 10 items
		LongTermMemory:  NewLongTermMemory(1000), // Capacity of 1000 items
		Attention:       NewAttentionSystem(),
		Learning:        NewLearningSystem(),
		GoalSystem:      NewGoalSystem(),
		MetaCognition:   NewMetaCognition(),
		SocialModel:     NewSocialCognition(),
		FreeEnergy:      free_energy_principle.NewVariationalInference(generativeModel),
		ActiveInference: activeInf,
		CurrentState: CognitiveState{
			AttentionFocus:   make([]methods.Probability, 4),
			EmotionalState:   make([]methods.Probability, 3),
			MotivationalState: make([]methods.Probability, 3),
			SocialContext:    make([]methods.Probability, 4),
			TimeHorizon:      2,
		},
	}
}

// ProcessStimulus processes an external stimulus through the cognitive system
func (cm *CognitiveModel) ProcessStimulus(stimulus []methods.Probability) (*CognitiveResponse, error) {
	// 1. Attention processing
	attentionWeights := cm.Attention.ComputeAttentionWeights(stimulus, cm.CurrentState.AttentionFocus)

	// 2. Working memory update
	filteredStimulus := cm.applyAttention(stimulus, attentionWeights)
	err := cm.WorkingMemory.AddItem(filteredStimulus)
	if err != nil {
		return nil, err
	}

	// 3. Active inference for perception and action
	perception, err := cm.FreeEnergy.Infer(filteredStimulus)
	if err != nil {
		return nil, err
	}

	// 4. Goal evaluation
	goals := cm.GoalSystem.EvaluateGoals(cm.WorkingMemory.GetContents())

	// 5. Decision making using active inference
	selectedPolicy, err := cm.ActiveInference.SelectPolicy(cm.CurrentState.AttentionFocus)
	if err != nil {
		return nil, err
	}

	// 6. Learning update
	cm.Learning.UpdateBeliefs(stimulus, perception, goals)

	// 7. Meta-cognitive monitoring
	confidence := cm.MetaCognition.AssessConfidence(perception)

	// 8. Update current state
	cm.updateCognitiveState(stimulus, perception, goals)

	response := &CognitiveResponse{
		Perception:      perception,
		AttentionWeights: attentionWeights,
		SelectedPolicy:  selectedPolicy,
		Goals:           goals,
		Confidence:      confidence,
		Action:          cm.policiesToAction(selectedPolicy),
	}

	return response, nil
}

// CognitiveResponse represents the output of cognitive processing
type CognitiveResponse struct {
	Perception      []methods.Probability
	AttentionWeights []methods.Probability
	SelectedPolicy  int
	Goals           []methods.Probability
	Confidence      methods.Probability
	Action          string
}

// applyAttention filters stimulus based on attention weights
func (cm *CognitiveModel) applyAttention(stimulus, weights []methods.Probability) []methods.Probability {
	if len(stimulus) != len(weights) {
		// If lengths don't match, return original stimulus
		return stimulus
	}

	filtered := make([]methods.Probability, len(stimulus))
	for i := range stimulus {
		filtered[i] = stimulus[i] * weights[i]
	}

	return filtered
}

// updateCognitiveState updates the current cognitive state
func (cm *CognitiveModel) updateCognitiveState(stimulus, perception, goals []methods.Probability) {
	// Update attention focus based on goals and perception
	for i := range cm.CurrentState.AttentionFocus {
		if i < len(goals) {
			cm.CurrentState.AttentionFocus[i] = goals[i] * 0.7 + perception[i] * 0.3
		}
	}

	// Update emotional state based on goal achievement
	goalAchievement := methods.Probability(0)
	for _, goal := range goals {
		goalAchievement += goal
	}
	goalAchievement /= methods.Probability(len(goals))

	cm.CurrentState.EmotionalState[0] = goalAchievement      // Satisfaction
	cm.CurrentState.EmotionalState[1] = 1 - goalAchievement  // Frustration
	cm.CurrentState.EmotionalState[2] = 0.5                 // Neutral baseline
}

// policiesToAction converts policy index to action string
func (cm *CognitiveModel) policiesToAction(policyIndex int) string {
	actions := []string{
		"explore", "exploit", "communicate", "learn",
		"plan_short", "plan_medium", "plan_long", "rest",
		"social_approach", "social_avoid", "cooperate", "compete",
	}

	if policyIndex >= 0 && policyIndex < len(actions) {
		return actions[policyIndex]
	}

	return "observe"
}

// WorkingMemory implements a limited-capacity working memory system
type WorkingMemory struct {
	Capacity int
	Contents [][]methods.Probability
	DecayRate methods.Probability
}

// NewWorkingMemory creates a new working memory system
func NewWorkingMemory(capacity int) *WorkingMemory {
	return &WorkingMemory{
		Capacity:  capacity,
		Contents:  make([][]methods.Probability, 0),
		DecayRate: 0.1,
	}
}

// AddItem adds a new item to working memory
func (wm *WorkingMemory) AddItem(item []methods.Probability) error {
	if len(wm.Contents) >= wm.Capacity {
		// Remove oldest item
		wm.Contents = wm.Contents[1:]
	}

	wm.Contents = append(wm.Contents, item)
	return nil
}

// GetContents returns current working memory contents
func (wm *WorkingMemory) GetContents() [][]methods.Probability {
	return wm.Contents
}

// Decay reduces the strength of older memories
func (wm *WorkingMemory) Decay() {
	for i := range wm.Contents {
		for j := range wm.Contents[i] {
			wm.Contents[i][j] *= (1 - wm.DecayRate)
		}
	}
}

// LongTermMemory implements a long-term memory system with consolidation
type LongTermMemory struct {
	Capacity   int
	Memories   map[string][]methods.Probability
	Strengths  map[string]methods.Probability
	ConsolidationRate methods.Probability
}

// NewLongTermMemory creates a new long-term memory system
func NewLongTermMemory(capacity int) *LongTermMemory {
	return &LongTermMemory{
		Capacity:         capacity,
		Memories:         make(map[string][]methods.Probability),
		Strengths:        make(map[string]methods.Probability),
		ConsolidationRate: 0.05,
	}
}

// Store stores a memory with given key
func (ltm *LongTermMemory) Store(key string, memory []methods.Probability) {
	if len(ltm.Memories) >= ltm.Capacity {
		// Remove weakest memory
		ltm.removeWeakestMemory()
	}

	ltm.Memories[key] = memory
	ltm.Strengths[key] = 1.0 // Initial strength
}

// Retrieve retrieves a memory by key
func (ltm *LongTermMemory) Retrieve(key string) []methods.Probability {
	if memory, exists := ltm.Memories[key]; exists {
		// Strengthen the retrieved memory
		ltm.Strengths[key] *= (1 + ltm.ConsolidationRate)
		return memory
	}
	return nil
}

// Consolidate strengthens memories over time
func (ltm *LongTermMemory) Consolidate() {
	for key := range ltm.Strengths {
		ltm.Strengths[key] *= (1 + ltm.ConsolidationRate)
	}
}

// removeWeakestMemory removes the memory with lowest strength
func (ltm *LongTermMemory) removeWeakestMemory() {
	minStrength := methods.Probability(math.Inf(1))
	weakestKey := ""

	for key, strength := range ltm.Strengths {
		if strength < minStrength {
			minStrength = strength
			weakestKey = key
		}
	}

	if weakestKey != "" {
		delete(ltm.Memories, weakestKey)
		delete(ltm.Strengths, weakestKey)
	}
}

// AttentionSystem implements attention mechanisms and salience computation
type AttentionSystem struct {
	SalienceMap []methods.Probability
	BiasTerms   []methods.Probability
}

// NewAttentionSystem creates a new attention system
func NewAttentionSystem() *AttentionSystem {
	return &AttentionSystem{
		SalienceMap: make([]methods.Probability, 4),
		BiasTerms:   make([]methods.Probability, 4),
	}
}

// ComputeAttentionWeights computes attention weights for stimulus
func (as *AttentionSystem) ComputeAttentionWeights(stimulus, currentFocus []methods.Probability) []methods.Probability {
	weights := make([]methods.Probability, len(stimulus))

	for i := range stimulus {
		// Compute salience based on stimulus intensity and novelty
		salience := stimulus[i]

		// Add current focus bias
		if i < len(currentFocus) {
			salience += currentFocus[i] * 0.3
		}

		// Add bias terms
		if i < len(as.BiasTerms) {
			salience += as.BiasTerms[i]
		}

		weights[i] = salience
	}

	// Normalize weights
	sum := methods.Probability(0)
	for _, w := range weights {
		sum += w
	}

	if sum > 0 {
		for i := range weights {
			weights[i] = weights[i] / sum
		}
	}

	return weights
}

// UpdateBiasTerms updates attention bias terms based on goals
func (as *AttentionSystem) UpdateBiasTerms(goals []methods.Probability) {
	learningRate := methods.Probability(0.1)

	for i := range as.BiasTerms {
		if i < len(goals) {
			as.BiasTerms[i] += learningRate * (goals[i] - as.BiasTerms[i])
		}
	}
}

// LearningSystem implements various learning mechanisms
type LearningSystem struct {
	ValueFunction map[string]methods.Probability
	Habits        map[string][]methods.Probability
	LearningRate  methods.Probability
}

// NewLearningSystem creates a new learning system
func NewLearningSystem() *LearningSystem {
	return &LearningSystem{
		ValueFunction: make(map[string]methods.Probability),
		Habits:        make(map[string][]methods.Probability),
		LearningRate:  0.1,
	}
}

// UpdateBeliefs updates beliefs using reinforcement learning
func (ls *LearningSystem) UpdateBeliefs(stimulus, perception, goals []methods.Probability) {
	// Simple Q-learning style update
	stateKey := ls.stateToKey(stimulus)

	currentValue := ls.ValueFunction[stateKey]

	// Compute reward based on goal achievement
	reward := methods.Probability(0)
	for _, goal := range goals {
		reward += goal
	}
	reward /= methods.Probability(len(goals))

	// Update value function
	newValue := currentValue + ls.LearningRate * (reward - currentValue)
	ls.ValueFunction[stateKey] = newValue
}

// LearnHabit learns a habit (automatic behavior) for a stimulus-response pair
func (ls *LearningSystem) LearnHabit(stimulus, response []methods.Probability) {
	stateKey := ls.stateToKey(stimulus)

	if _, exists := ls.Habits[stateKey]; !exists {
		ls.Habits[stateKey] = response
	} else {
		// Update existing habit
		for i := range ls.Habits[stateKey] {
			if i < len(response) {
				ls.Habits[stateKey][i] = ls.Habits[stateKey][i]*(1-ls.LearningRate) + response[i]*ls.LearningRate
			}
		}
	}
}

// GetHabit retrieves learned habit for a stimulus
func (ls *LearningSystem) GetHabit(stimulus []methods.Probability) []methods.Probability {
	stateKey := ls.stateToKey(stimulus)
	return ls.Habits[stateKey]
}

// stateToKey converts state vector to string key
func (ls *LearningSystem) stateToKey(state []methods.Probability) string {
	key := ""
	for _, val := range state {
		key += ufmt.Sprintf("%.2f,", val)
	}
	return key
}

// GoalSystem implements goal-directed behavior
type GoalSystem struct {
	Goals         []methods.Probability
	GoalHierarchy map[string][]string
	Priorities    map[string]methods.Probability
}

// NewGoalSystem creates a new goal system
func NewGoalSystem() *GoalSystem {
	return &GoalSystem{
		Goals:         make([]methods.Probability, 4),
		GoalHierarchy: make(map[string][]string),
		Priorities:    make(map[string]methods.Probability),
	}
}

// SetGoal sets the strength of a specific goal
func (gs *GoalSystem) SetGoal(goalIndex int, strength methods.Probability) error {
	if goalIndex < 0 || goalIndex >= len(gs.Goals) {
		return ufmt.Errorf("goal index out of range")
	}

	if strength < 0 || strength > 1 {
		return ufmt.Errorf("goal strength must be between 0 and 1")
	}

	gs.Goals[goalIndex] = strength
	return nil
}

// EvaluateGoals evaluates current goals based on working memory
func (gs *GoalSystem) EvaluateGoals(workingMemory [][]methods.Probability) []methods.Probability {
	// Simple goal evaluation based on working memory contents
	evaluatedGoals := make([]methods.Probability, len(gs.Goals))

	for i := range evaluatedGoals {
		evaluatedGoals[i] = gs.Goals[i]

		// Modulate goals based on recent experiences
		for _, memory := range workingMemory {
			if i < len(memory) {
				evaluatedGoals[i] *= (1 + memory[i]*0.1) // Small modulation
			}
		}
	}

	return evaluatedGoals
}

// MetaCognition implements meta-cognitive monitoring and control
type MetaCognition struct {
	ConfidenceThreshold methods.Probability
	PerformanceHistory  []methods.Probability
}

// NewMetaCognition creates a new meta-cognition system
func NewMetaCognition() *MetaCognition {
	return &MetaCognition{
		ConfidenceThreshold: 0.7,
		PerformanceHistory:  make([]methods.Probability, 0),
	}
}

// AssessConfidence assesses confidence in current beliefs
func (mc *MetaCognition) AssessConfidence(beliefs []methods.Probability) methods.Probability {
	// Simple confidence measure based on belief consistency
	if len(beliefs) == 0 {
		return 0
	}

	// High confidence if beliefs are polarized (close to 0 or 1)
	confidence := methods.Probability(0)
	for _, belief := range beliefs {
		distanceFromMiddle := math.Abs(float64(belief - 0.5))
		confidence += methods.Probability(distanceFromMiddle * 2)
	}
	confidence /= methods.Probability(len(beliefs))

	mc.PerformanceHistory = append(mc.PerformanceHistory, confidence)

	// Keep history bounded
	if len(mc.PerformanceHistory) > 100 {
		mc.PerformanceHistory = mc.PerformanceHistory[1:]
	}

	return confidence
}

// ShouldRethink determines if the system should rethink its current approach
func (mc *MetaCognition) ShouldRethink() bool {
	if len(mc.PerformanceHistory) < 5 {
		return false
	}

	// Check if recent performance is below threshold
	recentAvg := methods.Probability(0)
	recentCount := 5
	if len(mc.PerformanceHistory) < recentCount {
		recentCount = len(mc.PerformanceHistory)
	}

	for i := len(mc.PerformanceHistory) - recentCount; i < len(mc.PerformanceHistory); i++ {
		recentAvg += mc.PerformanceHistory[i]
	}
	recentAvg /= methods.Probability(recentCount)

	return recentAvg < mc.ConfidenceThreshold
}

// SocialCognition implements social cognition and theory of mind
type SocialCognition struct {
	OtherAgents map[string]*AgentModel
	SocialNorms []methods.Probability
}

// AgentModel represents the model's understanding of another agent
type AgentModel struct {
	Beliefs    []methods.Probability
	Goals      []methods.Probability
	Intentions []methods.Probability
	Trust      methods.Probability
}

// NewSocialCognition creates a new social cognition system
func NewSocialCognition() *SocialCognition {
	return &SocialCognition{
		OtherAgents: make(map[string]*AgentModel),
		SocialNorms: make([]methods.Probability, 4),
	}
}

// ModelAgent creates/updates a model of another agent's mental state
func (sc *SocialCognition) ModelAgent(agentID string, observedActions []methods.Probability) {
	if _, exists := sc.OtherAgents[agentID]; !exists {
		sc.OtherAgents[agentID] = &AgentModel{
			Beliefs:    make([]methods.Probability, 4),
			Goals:      make([]methods.Probability, 4),
			Intentions: make([]methods.Probability, 4),
			Trust:      0.5, // Initial neutral trust
		}
	}

	agent := sc.OtherAgents[agentID]

	// Update beliefs based on observed actions
	for i := range agent.Beliefs {
		if i < len(observedActions) {
			agent.Beliefs[i] = agent.Beliefs[i]*0.8 + observedActions[i]*0.2
		}
	}

	// Infer goals from actions and social norms
	for i := range agent.Goals {
		agent.Goals[i] = agent.Beliefs[i] * sc.SocialNorms[i]
	}

	// Update trust based on consistency
	consistency := methods.Probability(0)
	for i := range agent.Beliefs {
		if i < len(agent.Goals) {
			consistency += 1 - methods.Probability(math.Abs(float64(agent.Beliefs[i]-agent.Goals[i])))
		}
	}
	consistency /= methods.Probability(len(agent.Beliefs))

	agent.Trust = agent.Trust*0.9 + consistency*0.1
}

// PredictAction predicts what an agent will do next
func (sc *SocialCognition) PredictAction(agentID string) []methods.Probability {
	if agent, exists := sc.OtherAgents[agentID]; exists {
		// Simple prediction based on current beliefs and goals
		prediction := make([]methods.Probability, len(agent.Beliefs))
		for i := range prediction {
			prediction[i] = (agent.Beliefs[i] + agent.Goals[i]) / 2
		}
		return prediction
	}

	// Default prediction for unknown agents
	return []methods.Probability{0.25, 0.25, 0.25, 0.25}
}

// GetTrustLevel returns trust level for an agent
func (sc *SocialCognition) GetTrustLevel(agentID string) methods.Probability {
	if agent, exists := sc.OtherAgents[agentID]; exists {
		return agent.Trust
	}
	return 0.5 // Neutral trust for unknown agents
}
