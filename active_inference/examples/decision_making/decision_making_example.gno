// Package decision_making_example demonstrates decision support using ensemble active inference
//
// This example shows how to:
// - Create ensemble decision support systems
// - Handle uncertain decision contexts
// - Adapt to changing conditions
// - Make robust decisions under uncertainty
//
// This is a thin orchestrator that integrates decision support methods.
package decision_making_example

import (
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
	"gno.land/p/active_inference/methods/active_inference_core"
)

// DecisionMakingExample demonstrates decision support scenarios
type DecisionMakingExample struct {
	DSS         *active_inference_core.DecisionSupportSystem
	Controller  *active_inference_core.AdaptiveController
	Scenarios   []DecisionScenario
	CurrentStep int
}

// DecisionScenario represents a decision context with options and outcomes
type DecisionScenario struct {
	Context     []methods.Probability
	Options     []string
	Outcomes    [][]methods.Probability // Possible outcomes for each option
	TrueOutcome []methods.Probability   // Actual outcome (revealed later)
}

// NewDecisionMakingExample creates a new decision making scenario
func NewDecisionMakingExample() *DecisionMakingExample {
	// Create decision support system with 3 models
	dss := active_inference_core.NewDecisionSupportSystem(3)

	// Create adaptive controller
	controller := active_inference_core.NewAdaptiveController()

	// Define decision scenarios
	scenarios := []DecisionScenario{
		{
			Context: []methods.Probability{0.7, 0.3, 0.8, 0.2}, // Market conditions
			Options: []string{"Conservative", "Balanced", "Aggressive"},
			Outcomes: [][]methods.Probability{
				{0.6, 0.4, 0.5, 0.5}, // Conservative: stable returns
				{0.7, 0.3, 0.6, 0.4}, // Balanced: moderate risk/reward
				{0.8, 0.2, 0.9, 0.1}, // Aggressive: high risk/reward
			},
			TrueOutcome: []methods.Probability{0.7, 0.3, 0.6, 0.4}, // Balanced actually occurred
		},
		{
			Context: []methods.Probability{0.3, 0.7, 0.2, 0.8}, // Crisis conditions
			Options: []string{"Hold", "Sell", "Buy"},
			Outcomes: [][]methods.Probability{
				{0.4, 0.6, 0.3, 0.7}, // Hold: preserve capital
				{0.2, 0.8, 0.1, 0.9}, // Sell: cut losses
				{0.9, 0.1, 0.8, 0.2}, // Buy: opportunity in crisis
			},
			TrueOutcome: []methods.Probability{0.2, 0.8, 0.1, 0.9}, // Sell was correct
		},
		{
			Context: []methods.Probability{0.5, 0.5, 0.5, 0.5}, // Neutral conditions
			Options: []string{"Wait", "Act", "Monitor"},
			Outcomes: [][]methods.Probability{
				{0.5, 0.5, 0.4, 0.6}, // Wait: maintain position
				{0.6, 0.4, 0.7, 0.3}, // Act: take initiative
				{0.5, 0.5, 0.6, 0.4}, // Monitor: gather information
			},
			TrueOutcome: []methods.Probability{0.6, 0.4, 0.7, 0.3}, // Act was beneficial
		},
	}

	return &DecisionMakingExample{
		DSS:         dss,
		Controller:  controller,
		Scenarios:   scenarios,
		CurrentStep: 0,
	}
}

// MakeDecision executes one decision-making step
func (dme *DecisionMakingExample) MakeDecision(scenarioIndex int) string {
	if scenarioIndex >= len(dme.Scenarios) {
		return "Invalid scenario index"
	}

	scenario := dme.Scenarios[scenarioIndex]
	result := ufmt.Sprintf("## Decision Scenario %d\n\n", scenarioIndex+1)

	result += "Context: "
	for _, val := range scenario.Context {
		result += ufmt.Sprintf("%.2f ", val)
	}
	result += "\n\n"

	result += "Options:\n"
	for i, option := range scenario.Options {
		result += ufmt.Sprintf("  %d. %s\n", i+1, option)
	}
	result += "\n"

	// Get ensemble decision
	prediction, confidence, err := dme.DSS.MakeEnsembleDecision(scenario.Context)
	if err != nil {
		result += ufmt.Sprintf("Decision error: %v\n", err)
		return result
	}

	result += ufmt.Sprintf("Ensemble Prediction: [%.3f, %.3f, %.3f, %.3f]\n",
		prediction[0], prediction[1], prediction[2], prediction[3])
	result += ufmt.Sprintf("Ensemble Confidence: %.3f\n\n", confidence)

	// Interpret prediction as decision recommendation
	bestOption := 0
	bestScore := methods.Probability(0)

	for i, outcome := range scenario.Outcomes {
		score := methods.Probability(0)
		for j, pred := range prediction {
			if j < len(outcome) {
				// Score based on alignment with predicted outcome
				score += pred * outcome[j]
			}
		}

		result += ufmt.Sprintf("Option %d (%s) alignment score: %.3f\n",
			i+1, scenario.Options[i], score)

		if score > bestScore {
			bestScore = score
			bestOption = i
		}
	}

	result += ufmt.Sprintf("\nRecommended decision: %s (Option %d)\n",
		scenario.Options[bestOption], bestOption+1)

	// Reveal true outcome and update models
	result += "\nTrue outcome: "
	for _, val := range scenario.TrueOutcome {
		result += ufmt.Sprintf("%.2f ", val)
	}
	result += "\n"

	// Calculate decision accuracy
	chosenOutcome := scenario.Outcomes[bestOption]
	accuracy := methods.Probability(0)
	for i := range chosenOutcome {
		if i < len(scenario.TrueOutcome) {
			diff := chosenOutcome[i] - scenario.TrueOutcome[i]
			accuracy += 1 - methods.Probability(abs(float64(diff)))
		}
	}
	accuracy /= methods.Probability(len(chosenOutcome))

	result += ufmt.Sprintf("Decision accuracy: %.3f\n", accuracy)

	// Update ensemble weights based on true outcome
	dme.DSS.UpdateEnsembleWeights(scenario.TrueOutcome)

	result += "\nUpdated model weights: "
	for i, weight := range dme.DSS.EnsembleWeights {
		result += ufmt.Sprintf("%.3f ", weight)
		if i < len(dme.DSS.Models) {
			confidence := dme.DSS.Models[i].CognitiveModel.MetaCognition.AssessConfidence(
				dme.DSS.Models[i].CurrentBeliefs)
			result += ufmt.Sprintf("(confidence: %.2f) ", confidence)
		}
	}
	result += "\n"

	return result
}

// abs returns absolute value of float64
func abs(x float64) float64 {
	if x < 0 {
		return -x
	}
	return x
}

// DemonstrateAdaptiveDecisionMaking shows how the system adapts to changing conditions
func (dme *DecisionMakingExample) DemonstrateAdaptiveDecisionMaking() string {
	result := "# Adaptive Decision Making\n\n"

	// Simulate changing market conditions
	conditions := [][]methods.Probability{
		{0.8, 0.2, 0.9, 0.1}, // Bull market
		{0.3, 0.7, 0.2, 0.8}, // Bear market
		{0.6, 0.4, 0.5, 0.5}, // Sideways market
	}

	result += "Simulating adaptation to changing market conditions:\n\n"

	for i, condition := range conditions {
		result += ufmt.Sprintf("## Period %d: Market Condition\n", i+1)
		result += "Context: "
		for _, val := range condition {
			result += ufmt.Sprintf("%.2f ", val)
		}
		result += "\n"

		// Get ensemble decision
		prediction, confidence, err := dme.DSS.MakeEnsembleDecision(condition)
		if err != nil {
			result += ufmt.Sprintf("Error: %v\n", err)
			continue
		}

		result += ufmt.Sprintf("Ensemble prediction: [%.3f, %.3f, %.3f, %.3f]\n", 
			prediction[0], prediction[1], prediction[2], prediction[3])
		result += ufmt.Sprintf("Confidence: %.3f\n\n", confidence)

		// Simulate performance feedback
		performance := confidence // Use confidence as performance metric
		result += ufmt.Sprintf("Performance feedback: %.3f\n", performance)

		// Adapt system parameters
		for _, model := range dme.DSS.Models {
			dme.Controller.AdaptParameters(model, performance)
		}

		result += "Adapted parameters:\n"
		for j, model := range dme.DSS.Models {
			result += ufmt.Sprintf("  Model %d: Exploration=%.3f, Horizon=%d\n",
				j, model.ExplorationRate, model.PlanningHorizon)
		}
		result += "\n"
	}

	return result
}

// DemonstrateUncertaintyQuantification shows how to quantify decision uncertainty
func (dme *DecisionMakingExample) DemonstrateUncertaintyQuantification() string {
	result := "# Uncertainty Quantification\n\n"

	// Test with different levels of context uncertainty
	contexts := [][]methods.Probability{
		{0.9, 0.1, 0.8, 0.2}, // High certainty context
		{0.6, 0.4, 0.5, 0.5}, // Medium certainty context
		{0.5, 0.5, 0.5, 0.5}, // Maximum uncertainty context
	}

	contextNames := []string{"High Certainty", "Medium Certainty", "Maximum Uncertainty"}

	for i, context := range contexts {
		result += ufmt.Sprintf("## %s Context\n", contextNames[i])
		result += "Context: "
		for _, val := range context {
			result += ufmt.Sprintf("%.2f ", val)
		}
		result += "\n"

		// Get multiple predictions to assess variability
		predictions := make([][]methods.Probability, 5)
		confidences := make([]methods.Probability, 5)

		for j := 0; j < 5; j++ {
			pred, conf, err := dme.DSS.MakeEnsembleDecision(context)
			if err != nil {
				continue
			}
			predictions[j] = pred
			confidences[j] = conf
		}

		// Calculate prediction variability
		if len(predictions) > 0 {
			avgPrediction := make([]methods.Probability, len(predictions[0]))
			for _, pred := range predictions {
				for k, val := range pred {
					avgPrediction[k] += val
				}
			}
			for k := range avgPrediction {
				avgPrediction[k] /= methods.Probability(len(predictions))
			}

			variability := methods.Probability(0)
			for _, pred := range predictions {
				for k, val := range pred {
					diff := val - avgPrediction[k]
					variability += diff * diff
				}
			}
			variability /= methods.Probability(len(predictions) * len(avgPrediction))

			avgConfidence := methods.Probability(0)
			for _, conf := range confidences {
				avgConfidence += conf
			}
			avgConfidence /= methods.Probability(len(confidences))

			result += ufmt.Sprintf("Average prediction: [%.3f, %.3f, %.3f, %.3f]\n",
				avgPrediction[0], avgPrediction[1], avgPrediction[2], avgPrediction[3])
			result += ufmt.Sprintf("Prediction variability: %.4f\n", variability)
			result += ufmt.Sprintf("Average confidence: %.3f\n", avgConfidence)
			result += ufmt.Sprintf("Uncertainty assessment: %.3f\n\n",
				1.0-avgConfidence) // Higher uncertainty = lower confidence
		}
	}

	return result
}

// RunDecisionMakingSimulation runs a complete decision-making demonstration
func RunDecisionMakingSimulation() string {
	example := NewDecisionMakingExample()

	result := "# Active Inference: Decision Making Example\n\n"
	result += "This example demonstrates ensemble decision support using active inference.\n\n"

	// Run through all scenarios
	for i := range example.Scenarios {
		result += example.MakeDecision(i)
		result += "\n"
	}

	result += example.DemonstrateAdaptiveDecisionMaking()
	result += "\n" + example.DemonstrateUncertaintyQuantification()

	result += "\n## Key Insights\n\n"
	result += "- **Ensemble Methods**: Combining multiple models improves decision robustness\n"
	result += "- **Adaptive Learning**: System parameters adjust based on performance feedback\n"
	result += "- **Uncertainty Quantification**: Decision confidence helps assess risk\n"
	result += "- **Context Sensitivity**: Different market conditions require different strategies\n"
	result += "- **Model Weighting**: Better-performing models receive higher influence\n\n"

	result += "This demonstrates how active inference enables sophisticated decision-making\n"
	result += "under uncertainty, with continuous learning and adaptation on the blockchain.\n"

	return result
}
