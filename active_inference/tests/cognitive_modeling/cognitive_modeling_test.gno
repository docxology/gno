// Package cognitive_modeling_test provides comprehensive tests for cognitive modeling primitives
package cognitive_modeling

import (
	"math"
	"testing"
	"gno.land/p/active_inference/methods"
)

func TestNewCognitiveModel(t *testing.T) {
	model := NewCognitiveModel()

	if model.WorkingMemory == nil {
		t.Error("Expected non-nil WorkingMemory")
	}

	if model.LongTermMemory == nil {
		t.Error("Expected non-nil LongTermMemory")
	}

	if model.Attention == nil {
		t.Error("Expected non-nil AttentionSystem")
	}

	if model.Learning == nil {
		t.Error("Expected non-nil LearningSystem")
	}

	if model.GoalSystem == nil {
		t.Error("Expected non-nil GoalSystem")
	}

	if model.MetaCognition == nil {
		t.Error("Expected non-nil MetaCognition")
	}

	if model.SocialModel == nil {
		t.Error("Expected non-nil SocialCognition")
	}

	if model.FreeEnergy == nil {
		t.Error("Expected non-nil VariationalInference")
	}

	if model.ActiveInference == nil {
		t.Error("Expected non-nil ActiveInference")
	}
}

func TestCognitiveModelProcessStimulus(t *testing.T) {
	model := NewCognitiveModel()

	// Test stimulus processing
	stimulus := []methods.Probability{0.8, 0.6, 0.4, 0.2}
	response, err := model.ProcessStimulus(stimulus)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	if response == nil {
		t.Error("Expected non-nil response")
	}

	if len(response.Perception) != 4 {
		t.Errorf("Expected perception length 4, got %d", len(response.Perception))
	}

	if len(response.AttentionWeights) != 4 {
		t.Errorf("Expected attention weights length 4, got %d", len(response.AttentionWeights))
	}

	if response.SelectedPolicy < 0 {
		t.Errorf("Expected non-negative policy index, got %d", response.SelectedPolicy)
	}

	if len(response.Goals) != 4 {
		t.Errorf("Expected goals length 4, got %d", len(response.Goals))
	}

	if response.Confidence < 0 || response.Confidence > 1 {
		t.Errorf("Expected confidence between 0 and 1, got %f", response.Confidence)
	}

	if response.Action == "" {
		t.Error("Expected non-empty action")
	}
}

func TestWorkingMemory(t *testing.T) {
	wm := NewWorkingMemory(3)

	// Test adding items
	item1 := []methods.Probability{0.5, 0.3}
	item2 := []methods.Probability{0.7, 0.8}
	item3 := []methods.Probability{0.2, 0.9}
	item4 := []methods.Probability{0.1, 0.6}

	err := wm.AddItem(item1)
	if err != nil {
		t.Errorf("Expected no error adding item1, got %v", err)
	}

	err = wm.AddItem(item2)
	if err != nil {
		t.Errorf("Expected no error adding item2, got %v", err)
	}

	err = wm.AddItem(item3)
	if err != nil {
		t.Errorf("Expected no error adding item3, got %v", err)
	}

	// Should still have capacity 3
	contents := wm.GetContents()
	if len(contents) != 3 {
		t.Errorf("Expected 3 items in working memory, got %d", len(contents))
	}

	// Add fourth item - should replace oldest
	err = wm.AddItem(item4)
	if err != nil {
		t.Errorf("Expected no error adding item4, got %v", err)
	}

	contents = wm.GetContents()
	if len(contents) != 3 {
		t.Errorf("Expected still 3 items after adding fourth, got %d", len(contents))
	}

	// Check that item1 was replaced (should be item2, item3, item4)
	if len(contents) >= 1 && len(contents[0]) >= 2 {
		if contents[0][0] != item2[0] || contents[0][1] != item2[1] {
			t.Error("Expected oldest item to be replaced")
		}
	}
}

func TestLongTermMemory(t *testing.T) {
	ltm := NewLongTermMemory(2)

	// Test storing memories
	memory1 := []methods.Probability{0.5, 0.3}
	memory2 := []methods.Probability{0.7, 0.8}
	memory3 := []methods.Probability{0.2, 0.9}

	ltm.Store("memory1", memory1)
	ltm.Store("memory2", memory2)

	// Test retrieving memories
	retrieved1 := ltm.Retrieve("memory1")
	if retrieved1 == nil {
		t.Error("Expected to retrieve memory1")
	} else {
		if len(retrieved1) != len(memory1) {
			t.Errorf("Expected retrieved memory length %d, got %d", len(memory1), len(retrieved1))
		}
		for i := range retrieved1 {
			if retrieved1[i] != memory1[i] {
				t.Errorf("Retrieved memory differs at index %d: expected %f, got %f", i, memory1[i], retrieved1[i])
			}
		}
	}

	// Test retrieving non-existent memory
	retrievedNone := ltm.Retrieve("nonexistent")
	if retrievedNone != nil {
		t.Error("Expected nil for non-existent memory")
	}

	// Test capacity limit
	ltm.Store("memory3", memory3)

	// Should still have only 2 memories due to capacity limit
	strengthKeys := 0
	for range ltm.Strengths {
		strengthKeys++
	}
	if strengthKeys != 2 {
		t.Errorf("Expected 2 memories after capacity limit, got %d", strengthKeys)
	}
}

func TestAttentionSystem(t *testing.T) {
	as := NewAttentionSystem()

	stimulus := []methods.Probability{0.8, 0.4, 0.6, 0.2}
	currentFocus := []methods.Probability{0.3, 0.7, 0.1, 0.9}

	weights := as.ComputeAttentionWeights(stimulus, currentFocus)

	if len(weights) != len(stimulus) {
		t.Errorf("Expected weights length %d, got %d", len(stimulus), len(weights))
	}

	// Check normalization
	sum := methods.Probability(0)
	for _, w := range weights {
		sum += w
	}

	if math.Abs(float64(sum-1.0)) > 1e-6 {
		t.Errorf("Expected normalized weights summing to 1, got %f", sum)
	}

	// Test bias update
	goals := []methods.Probability{0.8, 0.2, 0.6, 0.4}
	as.UpdateBiasTerms(goals)

	// Bias terms should be updated
	for i, bias := range as.BiasTerms {
		if i < len(goals) {
			expectedBias := 0.1 * goals[i] // learning rate * goal
			if math.Abs(float64(bias-expectedBias)) > 1e-6 {
				t.Errorf("Expected bias %d to be %f, got %f", i, expectedBias, bias)
			}
		}
	}
}

func TestLearningSystem(t *testing.T) {
	ls := NewLearningSystem()

	stimulus := []methods.Probability{0.6, 0.4}
	perception := []methods.Probability{0.7, 0.3}
	goals := []methods.Probability{0.8, 0.2}

	// Test belief update
	ls.UpdateBeliefs(stimulus, perception, goals)

	// Should have learned a value for the stimulus state
	stateKey := ls.stateToKey(stimulus)
	if value, exists := ls.ValueFunction[stateKey]; !exists {
		t.Error("Expected value function entry for stimulus")
	} else {
		// Value should be positive based on goals
		if value <= 0 {
			t.Errorf("Expected positive value, got %f", value)
		}
	}

	// Test habit learning
	response := []methods.Probability{0.9, 0.1}
	ls.LearnHabit(stimulus, response)

	retrievedHabit := ls.GetHabit(stimulus)
	if retrievedHabit == nil {
		t.Error("Expected to retrieve learned habit")
	} else {
		for i := range retrievedHabit {
			if i < len(response) {
				if retrievedHabit[i] != response[i] {
					t.Errorf("Retrieved habit differs at index %d: expected %f, got %f", i, response[i], retrievedHabit[i])
				}
			}
		}
	}
}

func TestGoalSystem(t *testing.T) {
	gs := NewGoalSystem()

	// Test setting goals
	err := gs.SetGoal(0, 0.8)
	if err != nil {
		t.Errorf("Expected no error setting goal, got %v", err)
	}

	err = gs.SetGoal(1, 0.6)
	if err != nil {
		t.Errorf("Expected no error setting goal, got %v", err)
	}

	// Test invalid goal index
	err = gs.SetGoal(10, 0.5)
	if err == nil {
		t.Error("Expected error for invalid goal index")
	}

	// Test invalid goal strength
	err = gs.SetGoal(0, 1.5)
	if err == nil {
		t.Error("Expected error for invalid goal strength")
	}

	// Test goal evaluation
	workingMemory := [][]methods.Probability{
		{0.7, 0.3},
		{0.5, 0.8},
	}
	evaluatedGoals := gs.EvaluateGoals(workingMemory)

	if len(evaluatedGoals) != len(gs.Goals) {
		t.Errorf("Expected evaluated goals length %d, got %d", len(gs.Goals), len(evaluatedGoals))
	}

	// Goals should be modulated by working memory
	for i, goal := range evaluatedGoals {
		if i < len(gs.Goals) && gs.Goals[i] > 0 {
			if goal <= gs.Goals[i] {
				t.Errorf("Expected goal %d to be modulated upwards, original: %f, evaluated: %f", i, gs.Goals[i], goal)
			}
		}
	}
}

func TestMetaCognition(t *testing.T) {
	mc := NewMetaCognition()

	// Test confidence assessment
	beliefs := []methods.Probability{0.9, 0.1, 0.8, 0.2}
	confidence := mc.AssessConfidence(beliefs)

	if confidence < 0 || confidence > 1 {
		t.Errorf("Expected confidence between 0 and 1, got %f", confidence)
	}

	// High confidence beliefs should give high confidence
	if confidence < 0.5 {
		t.Error("Expected high confidence for polarized beliefs")
	}

	// Test with uniform beliefs
	uniformBeliefs := []methods.Probability{0.5, 0.5, 0.5, 0.5}
	uniformConfidence := mc.AssessConfidence(uniformBeliefs)

	if uniformConfidence >= confidence {
		t.Error("Expected lower confidence for uniform beliefs")
	}

	// Test rethink decision
	for i := 0; i < 10; i++ {
		mc.AssessConfidence(beliefs)
	}

	shouldRethink := mc.ShouldRethink()
	// With high confidence history, should not need to rethink
	if shouldRethink {
		t.Error("Expected no need to rethink with high confidence history")
	}

	// Test with low confidence history
	mc.PerformanceHistory = []methods.Probability{0.1, 0.2, 0.1, 0.15, 0.1}
	shouldRethink = mc.ShouldRethink()
	if !shouldRethink {
		t.Error("Expected need to rethink with low confidence history")
	}
}

func TestSocialCognition(t *testing.T) {
	sc := NewSocialCognition()

	agentID := "agent1"
	observedActions := []methods.Probability{0.8, 0.2, 0.6, 0.4}

	// Test modeling an agent
	sc.ModelAgent(agentID, observedActions)

	if _, exists := sc.OtherAgents[agentID]; !exists {
		t.Error("Expected agent to be modeled")
	}

	agent := sc.OtherAgents[agentID]

	// Check that beliefs were updated
	for i, belief := range agent.Beliefs {
		if i < len(observedActions) {
			if math.Abs(float64(belief-observedActions[i])) > 0.3 {
				t.Errorf("Expected belief %d close to observed action, got %f vs %f", i, belief, observedActions[i])
			}
		}
	}

	// Test action prediction
	prediction := sc.PredictAction(agentID)
	if len(prediction) != 4 {
		t.Errorf("Expected prediction length 4, got %d", len(prediction))
	}

	// Test trust level
	trust := sc.GetTrustLevel(agentID)
	if trust < 0 || trust > 1 {
		t.Errorf("Expected trust between 0 and 1, got %f", trust)
	}

	// Test unknown agent
	unknownPrediction := sc.PredictAction("unknown")
	if len(unknownPrediction) != 4 {
		t.Errorf("Expected prediction length 4 for unknown agent, got %d", len(unknownPrediction))
	}

	unknownTrust := sc.GetTrustLevel("unknown")
	if unknownTrust != 0.5 {
		t.Errorf("Expected neutral trust 0.5 for unknown agent, got %f", unknownTrust)
	}
}

func TestCognitiveStateUpdate(t *testing.T) {
	model := NewCognitiveModel()

	stimulus := []methods.Probability{0.7, 0.3, 0.8, 0.2}
	perception := []methods.Probability{0.6, 0.4, 0.7, 0.3}
	goals := []methods.Probability{0.9, 0.1, 0.8, 0.2}

	model.updateCognitiveState(stimulus, perception, goals)

	// Check attention focus update
	for i, focus := range model.CurrentState.AttentionFocus {
		if i < len(goals) && i < len(perception) {
			expectedFocus := goals[i]*0.7 + perception[i]*0.3
			if math.Abs(float64(focus-expectedFocus)) > 1e-6 {
				t.Errorf("Expected attention focus %d to be %f, got %f", i, expectedFocus, focus)
			}
		}
	}

	// Check emotional state update
	goalAchievement := (goals[0] + goals[1] + goals[2] + goals[3]) / 4
	expectedSatisfaction := goalAchievement
	expectedFrustration := 1 - goalAchievement

	if math.Abs(float64(model.CurrentState.EmotionalState[0]-expectedSatisfaction)) > 1e-6 {
		t.Error("Emotional state satisfaction not updated correctly")
	}

	if math.Abs(float64(model.CurrentState.EmotionalState[1]-expectedFrustration)) > 1e-6 {
		t.Error("Emotional state frustration not updated correctly")
	}
}

func TestApplyAttention(t *testing.T) {
	model := NewCognitiveModel()

	stimulus := []methods.Probability{0.8, 0.4, 0.6, 0.2}
	weights := []methods.Probability{0.4, 0.3, 0.2, 0.1}

	filtered := model.applyAttention(stimulus, weights)

	if len(filtered) != len(stimulus) {
		t.Errorf("Expected filtered length %d, got %d", len(stimulus), len(filtered))
	}

	for i := range filtered {
		expected := stimulus[i] * weights[i]
		if filtered[i] != expected {
			t.Errorf("Expected filtered[%d] = %f, got %f", i, expected, filtered[i])
		}
	}

	// Test mismatched lengths
	mismatchedWeights := []methods.Probability{0.5, 0.5}
	filteredMismatched := model.applyAttention(stimulus, mismatchedWeights)

	// Should return original stimulus when lengths don't match
	for i := range filteredMismatched {
		if filteredMismatched[i] != stimulus[i] {
			t.Errorf("Expected original stimulus when lengths mismatch, got %f vs %f", filteredMismatched[i], stimulus[i])
		}
	}
}

func TestPoliciesToAction(t *testing.T) {
	model := NewCognitiveModel()

	testCases := []struct {
		policyIndex int
		expected    string
	}{
		{0, "explore"},
		{1, "exploit"},
		{2, "communicate"},
		{3, "learn"},
		{4, "plan_short"},
		{5, "plan_medium"},
		{6, "plan_long"},
		{7, "rest"},
		{8, "social_approach"},
		{9, "social_avoid"},
		{10, "cooperate"},
		{11, "compete"},
		{12, "observe"}, // Out of bounds
		{-1, "observe"}, // Invalid
	}

	for _, tc := range testCases {
		action := model.policiesToAction(tc.policyIndex)
		if action != tc.expected {
			t.Errorf("Expected action '%s' for policy %d, got '%s'", tc.expected, tc.policyIndex, action)
		}
	}
}

func TestMemoryDecay(t *testing.T) {
	wm := NewWorkingMemory(3)

	item := []methods.Probability{1.0, 1.0}
	wm.AddItem(item)

	wm.Decay()

	decayedItem := wm.GetContents()[0]
	for i, val := range decayedItem {
		expected := item[i] * (1 - wm.DecayRate)
		if val != expected {
			t.Errorf("Expected decayed value %d to be %f, got %f", i, expected, val)
		}
	}
}

func TestMemoryConsolidation(t *testing.T) {
	ltm := NewLongTermMemory(10)

	ltm.Store("test", []methods.Probability{0.5, 0.5})
	initialStrength := ltm.Strengths["test"]

	ltm.Consolidate()

	newStrength := ltm.Strengths["test"]
	expectedStrength := initialStrength * (1 + ltm.ConsolidationRate)

	if newStrength != expectedStrength {
		t.Errorf("Expected consolidated strength %f, got %f", expectedStrength, newStrength)
	}
}
