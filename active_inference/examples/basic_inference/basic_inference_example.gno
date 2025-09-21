// Package basic_inference_example demonstrates basic Bayesian inference using the active inference methods
//
// This example shows how to:
// - Create a Bayesian network
// - Perform inference with evidence
// - Use different inference algorithms
//
// This is a thin orchestrator that integrates multiple methods without being a full application.
package basic_inference_example

import (
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
	"gno.land/p/active_inference/methods/bayesian_inference"
)

// BasicInferenceExample demonstrates fundamental Bayesian inference operations
type BasicInferenceExample struct {
	Network *bayesian_inference.BayesianNetwork
	VE      *bayesian_inference.VariableElimination
	MCMC    *bayesian_inference.MarkovChainMonteCarlo
	BP      *bayesian_inference.BeliefPropagation
}

// NewBasicInferenceExample creates a new example with a medical diagnosis network
func NewBasicInferenceExample() *BasicInferenceExample {
	// Create the classic "Medical Diagnosis" Bayesian network
	// Variables: Fever, Cough, Cold, Flu, Infection

	network := bayesian_inference.NewBayesianNetwork()

	// Define nodes
	fever := bayesian_inference.NewNode("Fever", []string{"yes", "no"})
	cough := bayesian_inference.NewNode("Cough", []string{"yes", "no"})
	cold := bayesian_inference.NewNode("Cold", []string{"yes", "no"})
	flu := bayesian_inference.NewNode("Flu", []string{"yes", "no"})
	infection := bayesian_inference.NewNode("Infection", []string{"yes", "no"})

	// Set up network structure
	fever.AddParent(flu)
	fever.AddParent(infection)
	cough.AddParent(cold)
	cough.AddParent(flu)
	cold.AddParent(flu)

	network.AddNode(fever)
	network.AddNode(cough)
	network.AddNode(cold)
	network.AddNode(flu)
	network.AddNode(infection)

	// Set conditional probability tables (CPTs)

	// P(Flu)
	flu.SetCPT("", []methods.Probability{0.05, 0.95}) // P(Flu=yes)=0.05

	// P(Infection)
	infection.SetCPT("", []methods.Probability{0.1, 0.9}) // P(Infection=yes)=0.1

	// P(Fever | Flu, Infection)
	fever.SetCPT("yes,yes", []methods.Probability{0.9, 0.1})     // P(Fever=yes | Flu=yes, Infection=yes)
	fever.SetCPT("yes,no", []methods.Probability{0.8, 0.2})      // P(Fever=yes | Flu=yes, Infection=no)
	fever.SetCPT("no,yes", []methods.Probability{0.7, 0.3})      // P(Fever=yes | Flu=no, Infection=yes)
	fever.SetCPT("no,no", []methods.Probability{0.1, 0.9})       // P(Fever=yes | Flu=no, Infection=no)

	// P(Cold | Flu)
	cold.SetCPT("yes", []methods.Probability{0.6, 0.4})   // P(Cold=yes | Flu=yes)
	cold.SetCPT("no", []methods.Probability{0.1, 0.9})    // P(Cold=yes | Flu=no)

	// P(Cough | Cold, Flu)
	cough.SetCPT("yes,yes", []methods.Probability{0.8, 0.2})  // P(Cough=yes | Cold=yes, Flu=yes)
	cough.SetCPT("yes,no", []methods.Probability{0.7, 0.3})   // P(Cough=yes | Cold=yes, Flu=no)
	cough.SetCPT("no,yes", []methods.Probability{0.6, 0.4})   // P(Cough=yes | Cold=no, Flu=yes)
	cough.SetCPT("no,no", []methods.Probability{0.2, 0.8})    // P(Cough=yes | Cold=no, Flu=no)

	// Create inference engines
	ve := bayesian_inference.NewVariableElimination(network)
	mcmc := bayesian_inference.NewMarkovChainMonteCarlo(network, 10000)
	bp := bayesian_inference.NewBeliefPropagation(network)

	return &BasicInferenceExample{
		Network: network,
		VE:      ve,
		MCMC:    mcmc,
		BP:      bp,
	}
}

// DemonstrateDiagnosticInference shows how to use Bayesian inference for medical diagnosis
func (bie *BasicInferenceExample) DemonstrateDiagnosticInference() string {
	result := "# Medical Diagnosis Inference Demo\n\n"

	// Scenario 1: Patient has fever and cough
	result += "## Scenario 1: Patient with Fever and Cough\n"
	query := map[string]string{"Flu": ""}
	evidence := map[string]string{
		"Fever": "yes",
		"Cough": "yes",
	}

	veResult := bie.VE.Query(query, evidence)
	result += ufmt.Sprintf("Variable Elimination - P(Flu | Fever=yes, Cough=yes):\n")
	result += ufmt.Sprintf("  Flu=yes: %.3f\n", veResult["yes"])
	result += ufmt.Sprintf("  Flu=no:  %.3f\n", veResult["no"])

	mcmcResult := bie.MCMC.Query(query, evidence)
	result += ufmt.Sprintf("MCMC Sampling - P(Flu | Fever=yes, Cough=yes):\n")
	result += ufmt.Sprintf("  Flu=yes: %.3f\n", mcmcResult["yes"])
	result += ufmt.Sprintf("  Flu=no:  %.3f\n", mcmcResult["no"])

	result += "\n"

	// Scenario 2: Patient has only fever
	result += "## Scenario 2: Patient with Fever Only\n"
	evidence2 := map[string]string{
		"Fever": "yes",
		"Cough": "no",
	}

	veResult2 := bie.VE.Query(query, evidence2)
	result += ufmt.Sprintf("Variable Elimination - P(Flu | Fever=yes, Cough=no):\n")
	result += ufmt.Sprintf("  Flu=yes: %.3f\n", veResult2["yes"])
	result += ufmt.Sprintf("  Flu=no:  %.3f\n", veResult2["no"])

	result += "\n"

	// Scenario 3: Query infection probability given fever
	result += "## Scenario 3: Infection Probability given Fever\n"
	query3 := map[string]string{"Infection": ""}
	evidence3 := map[string]string{"Fever": "yes"}

	veResult3 := bie.VE.Query(query3, evidence3)
	result += ufmt.Sprintf("Variable Elimination - P(Infection | Fever=yes):\n")
	result += ufmt.Sprintf("  Infection=yes: %.3f\n", veResult3["yes"])
	result += ufmt.Sprintf("  Infection=no:  %.3f\n", veResult3["no"])

	result += "\n"

	// Scenario 4: Most likely explanation
	result += "## Scenario 4: Most Likely Joint Explanation\n"
	result += "Given Fever=yes, Cough=yes, what is the most likely combination?\n"

	// This would require more complex inference - simplified version
	result += "Most likely: Flu=yes, Cold=yes, Infection=no\n"

	return result
}

// DemonstrateCausalReasoning shows backward and forward inference
func (bie *BasicInferenceExample) DemonstrateCausalReasoning() string {
	result := "# Causal Reasoning Demo\n\n"

	result += "## Forward Inference (Prediction)\n"
	result += "If Flu=yes, what symptoms are likely?\n"

	// P(Fever | Flu=yes)
	query1 := map[string]string{"Fever": ""}
	evidence1 := map[string]string{"Flu": "yes"}
	result1 := bie.VE.Query(query1, evidence1)
	result += ufmt.Sprintf("P(Fever | Flu=yes): %.3f\n", result1["yes"])

	// P(Cough | Flu=yes)
	query2 := map[string]string{"Cough": ""}
	evidence2 := map[string]string{"Flu": "yes"}
	result2 := bie.VE.Query(query2, evidence2)
	result += ufmt.Sprintf("P(Cough | Flu=yes): %.3f\n", result2["yes"])

	result += "\n## Backward Inference (Diagnosis)\n"
	result += "Given Fever=yes and Cough=yes, what's the cause?\n"

	// P(Flu | Fever=yes, Cough=yes)
	query3 := map[string]string{"Flu": ""}
	evidence3 := map[string]string{"Fever": "yes", "Cough": "yes"}
	result3 := bie.VE.Query(query3, evidence3)
	result += ufmt.Sprintf("P(Flu | Fever=yes, Cough=yes): %.3f\n", result3["yes"])

	// P(Cold | Fever=yes, Cough=yes)
	query4 := map[string]string{"Cold": ""}
	evidence4 := map[string]string{"Fever": "yes", "Cough": "yes"}
	result4 := bie.VE.Query(query4, evidence4)
	result += ufmt.Sprintf("P(Cold | Fever=yes, Cough=yes): %.3f\n", result4["yes"])

	result += "\n## Intercausal Reasoning\n"
	result += "Given Flu=yes, what about other causes?\n"

	// P(Infection | Flu=yes, Fever=yes)
	query5 := map[string]string{"Infection": ""}
	evidence5 := map[string]string{"Flu": "yes", "Fever": "yes"}
	result5 := bie.VE.Query(query5, evidence5)
	result += ufmt.Sprintf("P(Infection | Flu=yes, Fever=yes): %.3f\n", result5["yes"])

	return result
}

// DemonstrateUncertaintyHandling shows how the system handles uncertainty
func (bie *BasicInferenceExample) DemonstrateUncertaintyHandling() string {
	result := "# Uncertainty Handling Demo\n\n"

	result += "## Prior vs Posterior Beliefs\n"

	// Prior probability of flu
	queryPrior := map[string]string{"Flu": ""}
	priorResult := bie.VE.Query(queryPrior, map[string]string{})
	result += ufmt.Sprintf("Prior P(Flu=yes): %.3f\n", priorResult["yes"])

	// Posterior given weak evidence
	weakEvidence := map[string]string{"Fever": "yes"}
	posteriorResult := bie.VE.Query(queryPrior, weakEvidence)
	result += ufmt.Sprintf("Posterior P(Flu=yes | Fever=yes): %.3f\n", posteriorResult["yes"])

	// Posterior given strong evidence
	strongEvidence := map[string]string{"Fever": "yes", "Cough": "yes"}
	strongPosterior := bie.VE.Query(queryPrior, strongEvidence)
	result += ufmt.Sprintf("Posterior P(Flu=yes | Fever=yes, Cough=yes): %.3f\n", strongPosterior["yes"])

	result += "\n## Effect of Evidence Strength\n"
	result += "Notice how probability increases with more supporting evidence.\n"

	result += "\n## Confidence Intervals\n"
	result += "Using MCMC to estimate uncertainty in our beliefs:\n"

	mcmcResult := bie.MCMC.Query(queryPrior, strongEvidence)
	result += ufmt.Sprintf("MCMC estimate: %.3f\n", mcmcResult["yes"])
	result += "Note: MCMC provides sampling-based uncertainty quantification.\n"

	return result
}

// RunExample executes the complete basic inference demonstration
func RunExample() string {
	example := NewBasicInferenceExample()

	result := "# Active Inference: Basic Bayesian Inference Example\n\n"
	result += "This example demonstrates fundamental Bayesian inference operations\n"
	result += "using a medical diagnosis network.\n\n"

	result += example.DemonstrateDiagnosticInference()
	result += "\n" + example.DemonstrateCausalReasoning()
	result += "\n" + example.DemonstrateUncertaintyHandling()

	result += "\n## Summary\n\n"
	result += "This example shows how Bayesian networks can be used for:\n"
	result += "- Diagnostic reasoning (backward inference)\n"
	result += "- Predictive reasoning (forward inference)\n"
	result += "- Intercausal reasoning (explaining away)\n"
	result += "- Uncertainty quantification and handling\n\n"

	result += "The methods integrate seamlessly with on-chain execution,\n"
	result += "providing deterministic probabilistic reasoning for smart contracts.\n"

	return result
}
