// Package free_energy_principle implements the Free Energy Principle methods
// for active inference and cognitive modeling on the Gno blockchain.
//
// The Free Energy Principle (FEP) is a unifying theory that explains how biological
// systems maintain their organization and adapt to their environment through
// variational inference and predictive coding mechanisms.
//
// This implementation provides:
// - Variational inference for approximate Bayesian inference
// - Free energy computation and minimization
// - Predictive coding for hierarchical inference
// - Generative model representation and learning
package free_energy_principle

import (
	"math"
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
)

// GenerativeModel represents a generative model in the Free Energy Principle
type GenerativeModel struct {
	// Hierarchical levels of the model
	Levels []*ModelLevel

	// Precision parameters (inverse variances)
	Precisions []methods.Probability

	// Learning rate for variational updates
	LearningRate methods.Probability
}

// ModelLevel represents one level in a hierarchical generative model
type ModelLevel struct {
	// State variables at this level
	States []methods.Probability

	// Likelihood mapping to lower level (if not bottom level)
	LikelihoodMatrix [][]methods.Probability

	// Prior beliefs at this level
	Priors []methods.Probability

	// Posterior beliefs (variational approximation)
	Posteriors []methods.Probability
}

// NewGenerativeModel creates a new hierarchical generative model
func NewGenerativeModel(numLevels, statesPerLevel int) *GenerativeModel {
	levels := make([]*ModelLevel, numLevels)
	precisions := make([]methods.Probability, numLevels)

	for i := range levels {
		level := &ModelLevel{
			States:   make([]methods.Probability, statesPerLevel),
			Priors:   make([]methods.Probability, statesPerLevel),
			Posteriors: make([]methods.Probability, statesPerLevel),
		}

		// Initialize uniform priors
		uniformProb := methods.Probability(1.0 / float64(statesPerLevel))
		for j := range level.Priors {
			level.Priors[j] = uniformProb
			level.Posteriors[j] = uniformProb
		}

		// Initialize likelihood matrix for non-top levels
		if i < numLevels-1 {
			level.LikelihoodMatrix = make([][]methods.Probability, statesPerLevel)
			for j := range level.LikelihoodMatrix {
				level.LikelihoodMatrix[j] = make([]methods.Probability, statesPerLevel)
				// Initialize with some structure (can be learned)
				for k := range level.LikelihoodMatrix[j] {
					if j == k {
						level.LikelihoodMatrix[j][k] = 0.8 // Strong diagonal
					} else {
						level.LikelihoodMatrix[j][k] = 0.2 / methods.Probability(statesPerLevel-1) // Weak off-diagonal
					}
				}
			}
		}

		levels[i] = level
		precisions[i] = 1.0 // Default precision
	}

	return &GenerativeModel{
		Levels:       levels,
		Precisions:   precisions,
		LearningRate: 0.01,
	}
}

// VariationalInference implements variational inference for the generative model
type VariationalInference struct {
	Model *GenerativeModel
	MaxIterations int
	Tolerance     methods.Probability
}

// NewVariationalInference creates a new variational inference engine
func NewVariationalInference(model *GenerativeModel) *VariationalInference {
	return &VariationalInference{
		Model:         model,
		MaxIterations: 100,
		Tolerance:     1e-6,
	}
}

// Infer performs variational inference to minimize free energy
func (vi *VariationalInference) Infer(observations []methods.Probability) ([]methods.Probability, error) {
	if len(observations) != len(vi.Model.Levels[0].States) {
		return nil, ufmt.Errorf("observations length must match bottom level states")
	}

	// Set observations at bottom level
	for i, obs := range observations {
		vi.Model.Levels[0].Posteriors[i] = obs
	}

	// Perform variational inference
	converged := false
	for iteration := 0; iteration < vi.MaxIterations && !converged; iteration++ {
		converged = true

		// Update each level from bottom to top
		for level := 0; level < len(vi.Model.Levels)-1; level++ {
			oldPosteriors := make([]methods.Probability, len(vi.Model.Levels[level].Posteriors))
			copy(oldPosteriors, vi.Model.Levels[level].Posteriors)

			vi.updateLevel(level)

			// Check convergence
			maxDiff := methods.Probability(0)
			for i := range oldPosteriors {
				diff := methods.Probability(math.Abs(float64(vi.Model.Levels[level].Posteriors[i] - oldPosteriors[i])))
				if diff > maxDiff {
					maxDiff = diff
				}
			}

			if maxDiff > vi.Tolerance {
				converged = false
			}
		}
	}

	return vi.Model.Levels[len(vi.Model.Levels)-1].Posteriors, nil
}

// updateLevel performs one update step for a level in variational inference
func (vi *VariationalInference) updateLevel(level int) {
	currentLevel := vi.Model.Levels[level]

	if level == 0 {
		// Bottom level: update based on observations and predictions from level above
		if level < len(vi.Model.Levels)-1 {
			nextLevel := vi.Model.Levels[level+1]

			for i := range currentLevel.Posteriors {
				// Predictive coding: error between prediction and observation
				prediction := methods.Probability(0)
				for j := range nextLevel.Posteriors {
					prediction += nextLevel.Posteriors[j] * vi.Model.Levels[level+1].LikelihoodMatrix[j][i]
				}

				// Update posterior using prediction error
				precision := vi.Model.Precisions[level]
				error := currentLevel.Posteriors[i] - prediction
				currentLevel.Posteriors[i] += vi.Model.LearningRate * precision * error
			}
		}
	} else {
		// Higher levels: update based on level below
		prevLevel := vi.Model.Levels[level-1]

		for i := range currentLevel.Posteriors {
			// Compute expectation from level below
			expectation := methods.Probability(0)
			for j := range prevLevel.Posteriors {
				expectation += prevLevel.Posteriors[j] * currentLevel.LikelihoodMatrix[i][j]
			}

			// Update posterior using variational bound
			precision := vi.Model.Precisions[level]
			error := currentLevel.Posteriors[i] - expectation
			currentLevel.Posteriors[i] += vi.Model.LearningRate * precision * error
		}
	}

	// Normalize posteriors
	vi.normalizeLevel(level)
}

// normalizeLevel ensures posteriors sum to 1
func (vi *VariationalInference) normalizeLevel(level int) {
	currentLevel := vi.Model.Levels[level]

	sum := methods.Probability(0)
	for _, p := range currentLevel.Posteriors {
		sum += p
	}

	if sum > 0 {
		for i := range currentLevel.Posteriors {
			currentLevel.Posteriors[i] = currentLevel.Posteriors[i] / sum
		}
	} else {
		// Fallback to uniform distribution
		uniformProb := methods.Probability(1.0 / float64(len(currentLevel.Posteriors)))
		for i := range currentLevel.Posteriors {
			currentLevel.Posteriors[i] = uniformProb
		}
	}
}

// ComputeFreeEnergy computes the variational free energy of the model
func (vi *VariationalInference) ComputeFreeEnergy() methods.Probability {
	freeEnergy := methods.Probability(0)

	// Compute free energy as negative log evidence lower bound
	for level := range vi.Model.Levels {
		// Accuracy term: expected log likelihood
		accuracy := vi.computeAccuracy(level)
		freeEnergy -= accuracy

		// Complexity term: KL divergence between posterior and prior
		complexity := vi.computeComplexity(level)
		freeEnergy += complexity
	}

	return freeEnergy
}

// computeAccuracy computes the accuracy term (expected log likelihood)
func (vi *VariationalInference) computeAccuracy(level int) methods.Probability {
	currentLevel := vi.Model.Levels[level]
	accuracy := methods.Probability(0)

	if level == 0 {
		// Bottom level accuracy based on observations
		for i, posterior := range currentLevel.Posteriors {
			if posterior > 0 {
				accuracy += posterior * methods.Probability(math.Log(float64(posterior)))
			}
		}
	} else {
		// Higher level accuracy based on predictions
		prevLevel := vi.Model.Levels[level-1]
		for i := range currentLevel.Posteriors {
			for j := range prevLevel.Posteriors {
				likelihood := currentLevel.LikelihoodMatrix[i][j]
				if likelihood > 0 {
					accuracy += currentLevel.Posteriors[i] * prevLevel.Posteriors[j] *
						methods.Probability(math.Log(float64(likelihood)))
				}
			}
		}
	}

	return accuracy
}

// computeComplexity computes the complexity term (KL divergence)
func (vi *VariationalInference) computeComplexity(level int) methods.Probability {
	currentLevel := vi.Model.Levels[level]
	complexity := methods.Probability(0)

	for i := range currentLevel.Posteriors {
		posterior := currentLevel.Posteriors[i]
		prior := currentLevel.Priors[i]

		if posterior > 0 && prior > 0 {
			complexity += posterior * methods.Probability(math.Log(float64(posterior/prior)))
		}
	}

	return complexity
}

// PredictiveCoding implements predictive coding for hierarchical inference
type PredictiveCoding struct {
	Model *GenerativeModel
}

// NewPredictiveCoding creates a new predictive coding engine
func NewPredictiveCoding(model *GenerativeModel) *PredictiveCoding {
	return &PredictiveCoding{
		Model: model,
	}
}

// Predict generates predictions for lower levels given higher level states
func (pc *PredictiveCoding) Predict(level int) ([]methods.Probability, error) {
	if level >= len(pc.Model.Levels)-1 {
		return nil, ufmt.Errorf("cannot predict from top level")
	}

	currentLevel := pc.Model.Levels[level]
	nextLevel := pc.Model.Levels[level+1]

	predictions := make([]methods.Probability, len(currentLevel.States))

	for i := range predictions {
		prediction := methods.Probability(0)
		for j := range nextLevel.Posteriors {
			prediction += nextLevel.Posteriors[j] * nextLevel.LikelihoodMatrix[j][i]
		}
		predictions[i] = prediction
	}

	return predictions, nil
}

// UpdatePredictions updates predictions based on prediction errors
func (pc *PredictiveCoding) UpdatePredictions(observations []methods.Probability, level int) error {
	if level >= len(pc.Model.Levels) {
		return ufmt.Errorf("invalid level")
	}

	currentLevel := pc.Model.Levels[level]

	// Compute prediction errors
	predictionErrors := make([]methods.Probability, len(currentLevel.States))
	for i := range predictionErrors {
		if level == 0 {
			// Bottom level: error between observation and posterior
			predictionErrors[i] = observations[i] - currentLevel.Posteriors[i]
		} else {
			// Higher level: error between prediction and posterior
			predictions, err := pc.Predict(level - 1)
			if err != nil {
				return err
			}
			predictionErrors[i] = predictions[i] - currentLevel.Posteriors[i]
		}
	}

	// Update likelihood matrix based on prediction errors
	if level < len(pc.Model.Levels)-1 {
		pc.updateLikelihoodMatrix(level, predictionErrors)
	}

	return nil
}

// updateLikelihoodMatrix updates the likelihood matrix using prediction errors
func (pc *PredictiveCoding) updateLikelihoodMatrix(level int, predictionErrors []methods.Probability) {
	currentLevel := pc.Model.Levels[level]
	nextLevel := pc.Model.Levels[level+1]

	learningRate := pc.Model.LearningRate

	for i := range currentLevel.LikelihoodMatrix {
		for j := range currentLevel.LikelihoodMatrix[i] {
			// Update likelihood based on prediction error and posterior beliefs
			update := learningRate * predictionErrors[j] * nextLevel.Posteriors[i]
			currentLevel.LikelihoodMatrix[i][j] += update

			// Ensure non-negative
			if currentLevel.LikelihoodMatrix[i][j] < 0 {
				currentLevel.LikelihoodMatrix[i][j] = 0
			}
		}

		// Renormalize row
		sum := methods.Probability(0)
		for j := range currentLevel.LikelihoodMatrix[i] {
			sum += currentLevel.LikelihoodMatrix[i][j]
		}

		if sum > 0 {
			for j := range currentLevel.LikelihoodMatrix[i] {
				currentLevel.LikelihoodMatrix[i][j] = currentLevel.LikelihoodMatrix[i][j] / sum
			}
		}
	}
}

// ActiveInference combines free energy minimization with action selection
type ActiveInference struct {
	*GenerativeModel
	Policies    [][]int // Available policies (sequences of actions)
	PolicyPrior []methods.Probability // Prior beliefs over policies
}

// NewActiveInference creates a new active inference system
func NewActiveInference(model *GenerativeModel, policies [][]int) *ActiveInference {
	numPolicies := len(policies)
	policyPrior := make([]methods.Probability, numPolicies)

	// Initialize uniform policy prior
	uniformProb := methods.Probability(1.0 / float64(numPolicies))
	for i := range policyPrior {
		policyPrior[i] = uniformProb
	}

	return &ActiveInference{
		GenerativeModel: model,
		Policies:        policies,
		PolicyPrior:     policyPrior,
	}
}

// SelectPolicy selects the optimal policy using expected free energy minimization
func (ai *ActiveInference) SelectPolicy(currentState []methods.Probability) (int, error) {
	if len(ai.Policies) == 0 {
		return -1, ufmt.Errorf("no policies available")
	}

	minEFE := math.Inf(1)
	bestPolicy := -1

	// Evaluate expected free energy for each policy
	for i, policy := range ai.Policies {
		efe := ai.computeExpectedFreeEnergy(policy, currentState)

		if efe < minEFE {
			minEFE = efe
			bestPolicy = i
		}
	}

	if bestPolicy == -1 {
		return 0, nil // Fallback to first policy
	}

	return bestPolicy, nil
}

// computeExpectedFreeEnergy computes the expected free energy for a policy
func (ai *ActiveInference) computeExpectedFreeEnergy(policy []int, currentState []methods.Probability) float64 {
	// Simplified EFE computation
	// In practice, this would simulate the policy and compute expected outcomes
	expectedFE := 0.0

	// Add extrinsic value (goal-directed behavior)
	for _, action := range policy {
		expectedFE -= float64(ai.PolicyPrior[action%len(ai.PolicyPrior)]) // Prefer higher prior policies
	}

	// Add epistemic value (information-seeking behavior)
	for _, stateProb := range currentState {
		if stateProb > 0 {
			expectedFE -= float64(stateProb) * math.Log(float64(stateProb)) // Entropy reduction
		}
	}

	return expectedFE
}

// UpdatePolicyPrior updates policy priors based on outcomes
func (ai *ActiveInference) UpdatePolicyPrior(selectedPolicy int, outcome []methods.Probability) {
	// Simplified policy learning
	// In practice, this would use more sophisticated reinforcement learning

	learningRate := ai.LearningRate

	// Increase probability of successful policies
	successMeasure := methods.Probability(0)
	for _, prob := range outcome {
		successMeasure += prob
	}
	successMeasure = successMeasure / methods.Probability(len(outcome))

	// Update policy prior
	for i := range ai.PolicyPrior {
		if i == selectedPolicy {
			ai.PolicyPrior[i] += learningRate * successMeasure
		} else {
			ai.PolicyPrior[i] -= learningRate * successMeasure / methods.Probability(len(ai.PolicyPrior)-1)
		}

		// Ensure non-negative
		if ai.PolicyPrior[i] < 0 {
			ai.PolicyPrior[i] = 0
		}
	}

	// Renormalize
	sum := methods.Probability(0)
	for _, prob := range ai.PolicyPrior {
		sum += prob
	}

	if sum > 0 {
		for i := range ai.PolicyPrior {
			ai.PolicyPrior[i] = ai.PolicyPrior[i] / sum
		}
	}
}
