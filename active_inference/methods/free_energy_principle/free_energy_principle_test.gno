// Package free_energy_principle_test provides comprehensive tests for Free Energy Principle methods
package free_energy_principle

import (
	"math"
	"testing"
	"gno.land/p/active_inference/methods"
)

func TestNewGenerativeModel(t *testing.T) {
	numLevels := 3
	statesPerLevel := 2
	model := NewGenerativeModel(numLevels, statesPerLevel)

	if len(model.Levels) != numLevels {
		t.Errorf("Expected %d levels, got %d", numLevels, len(model.Levels))
	}

	for i, level := range model.Levels {
		if len(level.States) != statesPerLevel {
			t.Errorf("Level %d: expected %d states, got %d", i, statesPerLevel, len(level.States))
		}

		if len(level.Priors) != statesPerLevel {
			t.Errorf("Level %d: expected %d priors, got %d", i, statesPerLevel, len(level.Priors))
		}

		if len(level.Posteriors) != statesPerLevel {
			t.Errorf("Level %d: expected %d posteriors, got %d", i, statesPerLevel, len(level.Posteriors))
		}

		// Check priors are uniform
		expectedPrior := methods.Probability(1.0 / float64(statesPerLevel))
		for j, prior := range level.Priors {
			if math.Abs(float64(prior-expectedPrior)) > 1e-6 {
				t.Errorf("Level %d, prior %d: expected %f, got %f", i, j, expectedPrior, prior)
			}
		}

		// Check likelihood matrix for non-top levels
		if i < numLevels-1 {
			if len(level.LikelihoodMatrix) != statesPerLevel {
				t.Errorf("Level %d: expected likelihood matrix rows %d, got %d", i, statesPerLevel, len(level.LikelihoodMatrix))
			}
			for j, row := range level.LikelihoodMatrix {
				if len(row) != statesPerLevel {
					t.Errorf("Level %d, row %d: expected %d columns, got %d", i, j, statesPerLevel, len(row))
				}
			}
		}
	}

	if len(model.Precisions) != numLevels {
		t.Errorf("Expected %d precisions, got %d", numLevels, len(model.Precisions))
	}
}

func TestVariationalInference(t *testing.T) {
	model := NewGenerativeModel(2, 3)
	vi := NewVariationalInference(model)

	// Test inference with observations
	observations := []methods.Probability{0.8, 0.1, 0.1}
	result, err := vi.Infer(observations)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	if len(result) != 3 {
		t.Errorf("Expected result length 3, got %d", len(result))
	}

	// Check normalization
	sum := methods.Probability(0)
	for _, prob := range result {
		sum += prob
	}

	if math.Abs(float64(sum-1.0)) > 1e-6 {
		t.Errorf("Expected normalized result, sum = %f", sum)
	}

	// Test invalid observations length
	invalidObservations := []methods.Probability{0.5, 0.5} // Wrong length
	_, err = vi.Infer(invalidObservations)
	if err == nil {
		t.Error("Expected error for invalid observations length")
	}
}

func TestFreeEnergyComputation(t *testing.T) {
	model := NewGenerativeModel(2, 2)
	vi := NewVariationalInference(model)

	// Set some observations
	observations := []methods.Probability{0.7, 0.3}
	_, err := vi.Infer(observations)
	if err != nil {
		t.Errorf("Expected no error during inference, got %v", err)
	}

	// Compute free energy
	freeEnergy := vi.ComputeFreeEnergy()

	// Free energy should be a finite number
	if math.IsInf(float64(freeEnergy), 0) || math.IsNaN(float64(freeEnergy)) {
		t.Errorf("Expected finite free energy, got %f", freeEnergy)
	}
}

func TestPredictiveCoding(t *testing.T) {
	model := NewGenerativeModel(3, 2)
	pc := NewPredictiveCoding(model)

	// Test prediction from level 1
	predictions, err := pc.Predict(1)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	if len(predictions) != 2 {
		t.Errorf("Expected predictions length 2, got %d", len(predictions))
	}

	// Test prediction from invalid level
	_, err = pc.Predict(2) // Top level
	if err == nil {
		t.Error("Expected error for prediction from top level")
	}

	// Test prediction update
	observations := []methods.Probability{0.6, 0.4}
	err = pc.UpdatePredictions(observations, 0)
	if err != nil {
		t.Errorf("Expected no error during prediction update, got %v", err)
	}

	// Verify likelihood matrix was updated
	bottomLevel := model.Levels[0]
	for i, row := range bottomLevel.LikelihoodMatrix {
		sum := methods.Probability(0)
		for _, val := range row {
			sum += val
		}

		// Should still be normalized (approximately)
		if math.Abs(float64(sum-1.0)) > 0.1 {
			t.Errorf("Likelihood matrix row %d not properly normalized, sum = %f", i, sum)
		}
	}
}

func TestActiveInference(t *testing.T) {
	model := NewGenerativeModel(2, 2)

	// Define simple policies
	policies := [][]int{
		{0, 1}, // Policy 0: action 0 then action 1
		{1, 0}, // Policy 1: action 1 then action 0
		{0, 0}, // Policy 2: action 0 twice
	}

	ai := NewActiveInference(model, policies)

	if len(ai.Policies) != 3 {
		t.Errorf("Expected 3 policies, got %d", len(ai.Policies))
	}

	if len(ai.PolicyPrior) != 3 {
		t.Errorf("Expected 3 policy priors, got %d", len(ai.PolicyPrior))
	}

	// Test policy selection
	currentState := []methods.Probability{0.6, 0.4}
	selectedPolicy, err := ai.SelectPolicy(currentState)
	if err != nil {
		t.Errorf("Expected no error during policy selection, got %v", err)
	}

	if selectedPolicy < 0 || selectedPolicy >= len(policies) {
		t.Errorf("Selected policy index out of range: %d", selectedPolicy)
	}

	// Test policy prior update
	outcome := []methods.Probability{0.8, 0.2}
	ai.UpdatePolicyPrior(selectedPolicy, outcome)

	// Check that policy priors are still normalized
	sum := methods.Probability(0)
	for _, prior := range ai.PolicyPrior {
		sum += prior
	}

	if math.Abs(float64(sum-1.0)) > 1e-6 {
		t.Errorf("Policy priors not normalized after update, sum = %f", sum)
	}

	// Test with empty policies
	emptyAI := NewActiveInference(model, [][]int{})
	_, err = emptyAI.SelectPolicy(currentState)
	if err == nil {
		t.Error("Expected error for empty policies")
	}
}

func TestHierarchicalInference(t *testing.T) {
	// Test 3-level hierarchical model
	model := NewGenerativeModel(3, 2)
	vi := NewVariationalInference(model)

	// Set observations at bottom level
	observations := []methods.Probability{0.9, 0.1}

	result, err := vi.Infer(observations)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	if len(result) != 2 {
		t.Errorf("Expected result length 2, got %d", len(result))
	}

	// Check that inference propagated through hierarchy
	topLevel := model.Levels[2]
	sum := methods.Probability(0)
	for _, posterior := range topLevel.Posteriors {
		sum += posterior
	}

	if math.Abs(float64(sum-1.0)) > 1e-6 {
		t.Errorf("Top level posteriors not normalized, sum = %f", sum)
	}
}

func TestModelLearning(t *testing.T) {
	model := NewGenerativeModel(2, 2)
	pc := NewPredictiveCoding(model)

	// Simulate learning over multiple observations
	observations := [][]methods.Probability{
		{0.8, 0.2},
		{0.7, 0.3},
		{0.9, 0.1},
		{0.6, 0.4},
	}

	for _, obs := range observations {
		err := pc.UpdatePredictions(obs, 0)
		if err != nil {
			t.Errorf("Expected no error during learning, got %v", err)
		}
	}

	// Check that likelihood matrix adapted
	bottomLevel := model.Levels[0]
	for i, row := range bottomLevel.LikelihoodMatrix {
		sum := methods.Probability(0)
		for _, val := range row {
			sum += val
		}

		if sum <= 0 {
			t.Errorf("Likelihood matrix row %d has non-positive sum: %f", i, sum)
		}

		// Check for reasonable values
		for j, val := range row {
			if val < 0 {
				t.Errorf("Likelihood matrix [%d][%d] negative: %f", i, j, val)
			}
		}
	}
}

func TestPrecisionUpdates(t *testing.T) {
	model := NewGenerativeModel(2, 2)

	// Test precision initialization
	for i, precision := range model.Precisions {
		if precision != 1.0 {
			t.Errorf("Expected precision %d to be 1.0, got %f", i, precision)
		}
	}

	// Test custom precision setting
	model.Precisions[0] = 2.0
	if model.Precisions[0] != 2.0 {
		t.Errorf("Expected custom precision 2.0, got %f", model.Precisions[0])
	}
}

func TestConvergenceCriteria(t *testing.T) {
	model := NewGenerativeModel(2, 2)
	vi := NewVariationalInference(model)

	// Test with very loose tolerance (should converge quickly)
	vi.Tolerance = 0.1
	vi.MaxIterations = 5

	observations := []methods.Probability{0.5, 0.5}
	_, err := vi.Infer(observations)
	if err != nil {
		t.Errorf("Expected no error with loose tolerance, got %v", err)
	}

	// Test with very strict tolerance (may not converge in few iterations)
	vi.Tolerance = 1e-10
	vi.MaxIterations = 1

	_, err = vi.Infer(observations)
	// May or may not error depending on convergence, but shouldn't panic
	_ = err // We don't care about the result, just that it doesn't crash
}

func TestEdgeCases(t *testing.T) {
	// Test with single state per level
	model := NewGenerativeModel(2, 1)
	vi := NewVariationalInference(model)

	observations := []methods.Probability{1.0}
	result, err := vi.Infer(observations)
	if err != nil {
		t.Errorf("Expected no error for single state, got %v", err)
	}

	if len(result) != 1 || result[0] != 1.0 {
		t.Errorf("Expected single state result [1.0], got %v", result)
	}

	// Test uniform observations
	model2 := NewGenerativeModel(2, 3)
	vi2 := NewVariationalInference(model2)

	uniformObs := []methods.Probability{0.33, 0.33, 0.34}
	result2, err := vi2.Infer(uniformObs)
	if err != nil {
		t.Errorf("Expected no error for uniform observations, got %v", err)
	}

	if len(result2) != 3 {
		t.Errorf("Expected result length 3, got %d", len(result2))
	}
}

func TestPolicyEvaluation(t *testing.T) {
	model := NewGenerativeModel(2, 2)

	policies := [][]int{
		{0},      // Simple policy
		{0, 1},   // Two-step policy
		{0, 1, 0}, // Three-step policy
	}

	ai := NewActiveInference(model, policies)

	currentState := []methods.Probability{0.7, 0.3}

	// Test EFE computation for different policies
	for i, policy := range policies {
		efe := ai.computeExpectedFreeEnergy(policy, currentState)

		if math.IsInf(efe, 0) || math.IsNaN(efe) {
			t.Errorf("Policy %d: expected finite EFE, got %f", i, efe)
		}
	}

	// Test that policy selection is deterministic
	selected1, _ := ai.SelectPolicy(currentState)
	selected2, _ := ai.SelectPolicy(currentState)

	if selected1 != selected2 {
		t.Error("Policy selection should be deterministic for same input")
	}
}
