// Package cognitive_visualization_test provides comprehensive tests for cognitive visualization methods
package cognitive_visualization

import (
	"testing"
	"gno.land/p/active_inference/methods"
)

// TestNewCognitiveProcessAnimator tests the creation of cognitive process animator
func TestNewCognitiveProcessAnimator(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	if animator == nil {
		t.Error("Expected non-nil animator")
	}

	if len(animator.Frames) != 0 {
		t.Errorf("Expected empty frames initially, got %d", len(animator.Frames))
	}
}

// TestAddCognitiveState tests adding cognitive states to the animator
func TestAddCognitiveState(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	// Create test cognitive state
	state := CognitiveState{
		Beliefs:         []methods.Probability{0.8, 0.6, 0.4, 0.7},
		Attention:       []methods.Probability{0.9, 0.3, 0.5, 0.2},
		FreeEnergy:      0.15,
		PredictionError: []methods.Probability{0.1, -0.05, 0.08, -0.02},
		TimeStep:        0,
	}

	animator.AddCognitiveState(state, "t=0")

	if len(animator.Frames) != 1 {
		t.Errorf("Expected 1 frame after adding state, got %d", len(animator.Frames))
	}

	// Test adding multiple states
	state2 := CognitiveState{
		Beliefs:         []methods.Probability{0.7, 0.8, 0.5, 0.6},
		Attention:       []methods.Probability{0.8, 0.4, 0.6, 0.3},
		FreeEnergy:      0.12,
		PredictionError: []methods.Probability{0.05, -0.08, 0.03, -0.01},
		TimeStep:        1,
	}

	animator.AddCognitiveState(state2, "t=1")

	if len(animator.Frames) != 2 {
		t.Errorf("Expected 2 frames after adding second state, got %d", len(animator.Frames))
	}
}

// TestAnimateBeliefEvolution tests belief evolution animation
func TestAnimateBeliefEvolution(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	// Add multiple belief states
	for i := 0; i < 5; i++ {
		state := CognitiveState{
			Beliefs: []methods.Probability{
				methods.Probability(0.1 + 0.2*float64(i)),
				methods.Probability(0.9 - 0.1*float64(i)),
				methods.Probability(0.5),
				methods.Probability(0.3 + 0.1*float64(i)),
			},
			Attention:       []methods.Probability{0.8, 0.6, 0.7, 0.4},
			FreeEnergy:      methods.Probability(1.0 - 0.1*float64(i)),
			PredictionError: []methods.Probability{0.2, -0.1, 0.1, -0.05},
			TimeStep:        i,
		}
		animator.AddCognitiveState(state, "t="+string(i))
	}

	frames := animator.AnimateBeliefEvolution()

	if len(frames) != 5 {
		t.Errorf("Expected 5 frames, got %d", len(frames))
	}

	// Check that frames contain belief information
	for i, frame := range frames {
		if len(frame) == 0 {
			t.Errorf("Frame %d is empty", i)
		}
	}
}

// TestAnimateDecisionProcess tests decision process animation
func TestAnimateDecisionProcess(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	options := []string{"Option A", "Option B", "Option C"}

	// Evolving utilities over time
	utilities := [][]methods.Probability{
		{0.3, 0.5, 0.2}, // Initial estimates
		{0.4, 0.6, 0.3}, // After some learning
		{0.5, 0.7, 0.4}, // More confident
		{0.6, 0.8, 0.5}, // Even more confident
		{0.7, 0.9, 0.6}, // Final estimates
	}

	frames := animator.AnimateDecisionProcess(options, utilities)

	if len(frames) != 5 {
		t.Errorf("Expected 5 frames for decision animation, got %d", len(frames))
	}

	// Check that frames contain decision information
	for i, frame := range frames {
		if len(frame) == 0 {
			t.Errorf("Decision frame %d is empty", i)
		}
	}
}

// TestAnimateMultiAgentCoordination tests multi-agent coordination animation
func TestAnimateMultiAgentCoordination(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	agents := []string{"Agent 1", "Agent 2", "Agent 3"}

	// Agent beliefs evolving over time
	agentBeliefs := [][][]methods.Probability{
		{{0.8, 0.6, 0.4}, {0.7, 0.8, 0.5}, {0.6, 0.7, 0.8}}, // Time 1
		{{0.7, 0.7, 0.5}, {0.8, 0.6, 0.6}, {0.7, 0.8, 0.7}}, // Time 2
		{{0.75, 0.65, 0.6}, {0.7, 0.75, 0.7}, {0.8, 0.7, 0.75}}, // Time 3
	}

	frames := animator.AnimateMultiAgentCoordination(agents, agentBeliefs)

	if len(frames) != 3 {
		t.Errorf("Expected 3 frames for coordination animation, got %d", len(frames))
	}

	// Check that frames contain coordination information
	for i, frame := range frames {
		if len(frame) == 0 {
			t.Errorf("Coordination frame %d is empty", i)
		}
	}
}

// TestAnimateProbabilityDistribution tests probability distribution animation
func TestAnimateProbabilityDistribution(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	labels := []string{"State A", "State B", "State C", "State D"}

	// Distributions evolving over time
	distributions := [][]methods.Probability{
		{0.4, 0.3, 0.2, 0.1}, // Initial
		{0.3, 0.4, 0.2, 0.1}, // Shift
		{0.2, 0.3, 0.4, 0.1}, // Further shift
		{0.1, 0.2, 0.3, 0.4}, // Final
	}

	frames := animator.AnimateProbabilityDistribution(labels, distributions)

	if len(frames) != 4 {
		t.Errorf("Expected 4 frames for distribution animation, got %d", len(frames))
	}

	// Check normalization of distributions
	for i, dist := range distributions {
		sum := methods.Probability(0)
		for _, prob := range dist {
			sum += prob
		}

		if sum != 1.0 {
			t.Errorf("Distribution %d is not normalized, sum = %f", i, sum)
		}
	}
}

// TestCognitiveStateValidation tests cognitive state validation
func TestCognitiveStateValidation(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	// Test valid state
	validState := CognitiveState{
		Beliefs:         []methods.Probability{0.8, 0.2},
		Attention:       []methods.Probability{0.9, 0.1},
		FreeEnergy:      0.15,
		PredictionError: []methods.Probability{0.1, -0.1},
		TimeStep:        0,
	}

	animator.AddCognitiveState(validState, "valid")

	if len(animator.Frames) != 1 {
		t.Error("Expected valid state to be added")
	}

	// Test invalid state - mismatched lengths
	invalidState := CognitiveState{
		Beliefs:         []methods.Probability{0.8, 0.2},
		Attention:       []methods.Probability{0.9, 0.1, 0.0}, // Wrong length
		FreeEnergy:      0.15,
		PredictionError: []methods.Probability{0.1, -0.1},
		TimeStep:        1,
	}

	// This should handle the mismatch gracefully
	animator.AddCognitiveState(invalidState, "invalid")

	// Should still have only 1 frame since invalid state was handled
	if len(animator.Frames) != 1 {
		t.Error("Expected invalid state to be handled gracefully")
	}
}

// TestFrameGeneration tests frame generation functionality
func TestFrameGeneration(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	// Add some states
	states := []CognitiveState{
		{
			Beliefs:         []methods.Probability{0.8, 0.2},
			Attention:       []methods.Probability{0.9, 0.1},
			FreeEnergy:      0.15,
			PredictionError: []methods.Probability{0.1, -0.1},
			TimeStep:        0,
		},
		{
			Beliefs:         []methods.Probability{0.7, 0.3},
			Attention:       []methods.Probability{0.8, 0.2},
			FreeEnergy:      0.12,
			PredictionError: []methods.Probability{0.05, -0.05},
			TimeStep:        1,
		},
	}

	for i, state := range states {
		animator.AddCognitiveState(state, "t="+string(i))
	}

	// Test belief evolution animation
	frames := animator.AnimateBeliefEvolution()
	if len(frames) != 2 {
		t.Errorf("Expected 2 frames, got %d", len(frames))
	}

	// Test that frames contain expected content
	for i, frame := range frames {
		if len(frame) == 0 {
			t.Errorf("Frame %d is empty", i)
		}
	}
}

// TestEdgeCases tests edge cases and boundary conditions
func TestEdgeCases(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	// Test with empty states
	emptyState := CognitiveState{
		Beliefs:         []methods.Probability{},
		Attention:       []methods.Probability{},
		FreeEnergy:      0.0,
		PredictionError: []methods.Probability{},
		TimeStep:        0,
	}

	animator.AddCognitiveState(emptyState, "empty")

	// Should handle gracefully
	if len(animator.Frames) != 1 {
		t.Error("Expected empty state to be handled")
	}

	// Test with extreme values
	extremeState := CognitiveState{
		Beliefs:         []methods.Probability{1.0, 0.0, 1.0, 0.0},
		Attention:       []methods.Probability{1.0, 0.0, 1.0, 0.0},
		FreeEnergy:      10.0,
		PredictionError: []methods.Probability{5.0, -5.0, 5.0, -5.0},
		TimeStep:        1,
	}

	animator.AddCognitiveState(extremeState, "extreme")

	if len(animator.Frames) != 2 {
		t.Error("Expected extreme state to be handled")
	}

	// Test animation with single state
	singleAnimator := NewCognitiveProcessAnimator()
	singleAnimator.AddCognitiveState(emptyState, "single")

	frames := singleAnimator.AnimateBeliefEvolution()
	if len(frames) != 1 {
		t.Errorf("Expected 1 frame for single state, got %d", len(frames))
	}
}

// TestCompleteWorkflow tests a complete visualization workflow
func TestCompleteWorkflow(t *testing.T) {
	animator := NewCognitiveProcessAnimator()

	// Simulate a complete cognitive process evolution
	timeSteps := 10
	for i := 0; i < timeSteps; i++ {
		// Create evolving cognitive state
		progress := float64(i) / float64(timeSteps-1)
		state := CognitiveState{
			Beliefs: []methods.Probability{
				methods.Probability(0.2 + 0.6*progress), // Increasing confidence
				methods.Probability(0.8 - 0.6*progress), // Decreasing uncertainty
				methods.Probability(0.5),                  // Stable belief
			},
			Attention: []methods.Probability{
				methods.Probability(0.9 - 0.4*progress), // Decreasing attention
				methods.Probability(0.1 + 0.4*progress), // Increasing attention
				methods.Probability(0.5),
			},
			FreeEnergy:      methods.Probability(1.0 - 0.8*progress), // Decreasing free energy
			PredictionError: []methods.Probability{
				methods.Probability(0.5 - 0.4*progress),
				methods.Probability(-0.3 + 0.2*progress),
				methods.Probability(0.1 - 0.1*progress),
			},
			TimeStep: i,
		}

		animator.AddCognitiveState(state, "t="+string(i))
	}

	// Test multiple animation types
	beliefFrames := animator.AnimateBeliefEvolution()
	if len(beliefFrames) != timeSteps {
		t.Errorf("Expected %d belief frames, got %d", timeSteps, len(beliefFrames))
	}

	decisionFrames := animator.AnimateDecisionProcess(
		[]string{"Option A", "Option B"},
		[][]methods.Probability{
			{0.6, 0.4},
			{0.7, 0.3},
			{0.8, 0.2},
		},
	)
	if len(decisionFrames) != 3 {
		t.Errorf("Expected 3 decision frames, got %d", len(decisionFrames))
	}

	// Verify frame quality
	for i, frame := range beliefFrames {
		if len(frame) == 0 {
			t.Errorf("Belief frame %d is empty", i)
		}
	}

	for i, frame := range decisionFrames {
		if len(frame) == 0 {
			t.Errorf("Decision frame %d is empty", i)
		}
	}
}

// TestRealm tests the complete visualization functionality
func TestRealm(t *testing.T) {
	t.Log("=== Cognitive Visualization Tests ===")

	TestNewCognitiveProcessAnimator(t)
	TestAddCognitiveState(t)
	TestAnimateBeliefEvolution(t)
	TestAnimateDecisionProcess(t)
	TestAnimateMultiAgentCoordination(t)
	TestAnimateProbabilityDistribution(t)
	TestCognitiveStateValidation(t)
	TestFrameGeneration(t)
	TestEdgeCases(t)
	TestCompleteWorkflow(t)

	t.Log("=== Cognitive Visualization Tests Complete ===")
}
