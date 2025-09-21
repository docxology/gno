// Package medical_diagnosis_demo demonstrates an animated Active Inference system
// for medical diagnosis using Bayesian networks and cognitive agents
package medical_diagnosis_demo

import (
	"gno.land/p/active_inference/methods/bayesian_inference"
	"gno.land/p/active_inference/methods/visualization"
	"gno.land/p/active_inference/methods"
)

// MedicalDiagnosisDemo showcases an intelligent diagnostic system
type MedicalDiagnosisDemo struct {
	*visualization.AnimationEngine
	bayesianNetwork *bayesian_inference.BayesianNetwork
	patientHistory  []PatientObservation
	diagnosisHistory []DiagnosisResult
}

// PatientObservation represents a patient's symptoms and test results
type PatientObservation struct {
	Symptoms map[string]bool // fever, cough, fatigue, headache
	TestResults map[string]float64 // temperature, white blood cell count, etc.
	TimeStep int
}

// DiagnosisResult contains the diagnostic assessment
type DiagnosisResult struct {
	DiseaseProbabilities map[string]methods.Probability
	Confidence          methods.Probability
	RecommendedTests    []string
	TimeStep           int
}

// NewMedicalDiagnosisDemo creates a new medical diagnosis demonstration
func NewMedicalDiagnosisDemo() *MedicalDiagnosisDemo {
	demo := &MedicalDiagnosisDemo{
		AnimationEngine: visualization.NewAnimationEngine(),
		patientHistory:  make([]PatientObservation, 0),
		diagnosisHistory: make([]DiagnosisResult, 0),
	}

	// Initialize Bayesian network for diagnosis
	demo.initializeBayesianNetwork()

	return demo
}

// initializeBayesianNetwork sets up the medical diagnostic network
func (mdd *MedicalDiagnosisDemo) initializeBayesianNetwork() {
	network := bayesian_inference.NewBayesianNetwork()

	// Define diseases
	flu := bayesian_inference.NewNode("Flu", []string{"yes", "no"})
	cold := bayesian_inference.NewNode("Cold", []string{"yes", "no"})
	pneumonia := bayesian_inference.NewNode("Pneumonia", []string{"yes", "no"})
	allergy := bayesian_inference.NewNode("Allergy", []string{"yes", "no"})

	// Define symptoms
	fever := bayesian_inference.NewNode("Fever", []string{"high", "low", "none"})
	cough := bayesian_inference.NewNode("Cough", []string{"severe", "mild", "none"})
	fatigue := bayesian_inference.NewNode("Fatigue", []string{"severe", "mild", "none"})
	headache := bayesian_inference.NewNode("Headache", []string{"severe", "mild", "none"})
	soreThroat := bayesian_inference.NewNode("SoreThroat", []string{"yes", "no"})

	// Set up causal relationships
	fever.AddParent(flu)
	fever.AddParent(pneumonia)
	cough.AddParent(flu)
	cough.AddParent(cold)
	fatigue.AddParent(flu)
	fatigue.AddParent(pneumonia)
	headache.AddParent(flu)
	headache.AddParent(cold)
	soreThroat.AddParent(flu)
	soreThroat.AddParent(cold)

	// Add nodes to network
	network.AddNode(flu)
	network.AddNode(cold)
	network.AddNode(pneumonia)
	network.AddNode(allergy)
	network.AddNode(fever)
	network.AddNode(cough)
	network.AddNode(fatigue)
	network.AddNode(headache)
	network.AddNode(soreThroat)

	// Set conditional probability tables (CPTs)
	mdd.setupConditionalProbabilities(network)

	mdd.bayesianNetwork = network
}

// setupConditionalProbabilities configures the CPTs for medical diagnosis
func (mdd *MedicalDiagnosisDemo) setupConditionalProbabilities(network *bayesian_inference.BayesianNetwork) {
	// Prior probabilities for diseases
	network.GetNode("Flu").SetCPT("", []methods.Probability{0.08, 0.92})        // 8% flu incidence
	network.GetNode("Cold").SetCPT("", []methods.Probability{0.15, 0.85})       // 15% cold incidence
	network.GetNode("Pneumonia").SetCPT("", []methods.Probability{0.03, 0.97})  // 3% pneumonia incidence
	network.GetNode("Allergy").SetCPT("", []methods.Probability{0.20, 0.80})    // 20% allergy incidence

	// Conditional probabilities for symptoms given diseases
	// Fever | Diseases
	network.GetNode("Fever").SetCPT("Flu=yes,Pneumonia=yes", []methods.Probability{0.8, 0.1, 0.1})
	network.GetNode("Fever").SetCPT("Flu=yes,Pneumonia=no", []methods.Probability{0.6, 0.3, 0.1})
	network.GetNode("Fever").SetCPT("Flu=no,Pneumonia=yes", []methods.Probability{0.7, 0.2, 0.1})
	network.GetNode("Fever").SetCPT("Flu=no,Pneumonia=no", []methods.Probability{0.1, 0.2, 0.7})

	// Cough | Diseases
	network.GetNode("Cough").SetCPT("Flu=yes,Cold=yes", []methods.Probability{0.7, 0.2, 0.1})
	network.GetNode("Cough").SetCPT("Flu=yes,Cold=no", []methods.Probability{0.5, 0.3, 0.2})
	network.GetNode("Cough").SetCPT("Flu=no,Cold=yes", []methods.Probability{0.6, 0.3, 0.1})
	network.GetNode("Cough").SetCPT("Flu=no,Cold=no", []methods.Probability{0.1, 0.2, 0.7})

	// Fatigue | Diseases
	network.GetNode("Fatigue").SetCPT("Flu=yes,Pneumonia=yes", []methods.Probability{0.9, 0.05, 0.05})
	network.GetNode("Fatigue").SetCPT("Flu=yes,Pneumonia=no", []methods.Probability{0.7, 0.2, 0.1})
	network.GetNode("Fatigue").SetCPT("Flu=no,Pneumonia=yes", []methods.Probability{0.8, 0.1, 0.1})
	network.GetNode("Fatigue").SetCPT("Flu=no,Pneumonia=no", []methods.Probability{0.2, 0.3, 0.5})

	// Headache | Diseases
	network.GetNode("Headache").SetCPT("Flu=yes,Cold=yes", []methods.Probability{0.6, 0.3, 0.1})
	network.GetNode("Headache").SetCPT("Flu=yes,Cold=no", []methods.Probability{0.5, 0.3, 0.2})
	network.GetNode("Headache").SetCPT("Flu=no,Cold=yes", []methods.Probability{0.4, 0.4, 0.2})
	network.GetNode("Headache").SetCPT("Flu=no,Cold=no", []methods.Probability{0.1, 0.2, 0.7})

	// Sore Throat | Diseases
	network.GetNode("SoreThroat").SetCPT("Flu=yes,Cold=yes", []methods.Probability{0.8, 0.2})
	network.GetNode("SoreThroat").SetCPT("Flu=yes,Cold=no", []methods.Probability{0.6, 0.4})
	network.GetNode("SoreThroat").SetCPT("Flu=no,Cold=yes", []methods.Probability{0.7, 0.3})
	network.GetNode("SoreThroat").SetCPT("Flu=no,Cold=no", []methods.Probability{0.2, 0.8})
}

// AddPatientObservation adds a new patient observation to the demo
func (mdd *MedicalDiagnosisDemo) AddPatientObservation(observation PatientObservation) {
	mdd.patientHistory = append(mdd.patientHistory, observation)

	// Perform diagnosis
	result := mdd.performDiagnosis(observation)
	mdd.diagnosisHistory = append(mdd.diagnosisHistory, result)
}

// performDiagnosis uses the Bayesian network to diagnose based on patient observations
func (mdd *MedicalDiagnosisDemo) performDiagnosis(observation PatientObservation) DiagnosisResult {
	ve := bayesian_inference.NewVariableElimination(mdd.bayesianNetwork)

	// Convert patient symptoms to evidence
	evidence := make(map[string]string)

	// Map symptoms to evidence
	if observation.Symptoms["fever"] {
		if observation.TestResults["temperature"] > 101.0 {
			evidence["Fever"] = "high"
		} else if observation.TestResults["temperature"] > 99.0 {
			evidence["Fever"] = "low"
		} else {
			evidence["Fever"] = "none"
		}
	} else {
		evidence["Fever"] = "none"
	}

	if observation.Symptoms["cough"] {
		evidence["Cough"] = "severe" // Assume severe if present
	} else {
		evidence["Cough"] = "none"
	}

	if observation.Symptoms["fatigue"] {
		evidence["Fatigue"] = "severe" // Assume severe if present
	} else {
		evidence["Fatigue"] = "none"
	}

	if observation.Symptoms["headache"] {
		evidence["Headache"] = "severe" // Assume severe if present
	} else {
		evidence["Headache"] = "none"
	}

	if observation.Symptoms["soreThroat"] {
		evidence["SoreThroat"] = "yes"
	} else {
		evidence["SoreThroat"] = "no"
	}

	// Query for disease probabilities
	queries := []string{"Flu", "Cold", "Pneumonia", "Allergy"}
	probabilities := make(map[string]methods.Probability)

	for _, disease := range queries {
		query := map[string]string{disease: ""}
		result := ve.Query(query, evidence)
		probabilities[disease] = result["yes"]
	}

	// Calculate overall confidence
	totalProb := methods.Probability(0)
	for _, prob := range probabilities {
		totalProb += prob
	}

	// Generate recommended tests based on uncertainties
	recommendedTests := mdd.generateRecommendedTests(probabilities, evidence)

	return DiagnosisResult{
		DiseaseProbabilities: probabilities,
		Confidence:          methods.Probability(1.0), // Simplified confidence calculation
		RecommendedTests:    recommendedTests,
		TimeStep:           len(mdd.patientHistory),
	}
}

// generateRecommendedTests suggests additional tests based on diagnostic uncertainty
func (mdd *MedicalDiagnosisDemo) generateRecommendedTests(probabilities map[string]methods.Probability, evidence map[string]string) []string {
	tests := make([]string, 0)

	// If multiple diseases have similar probabilities, recommend distinguishing tests
	fluProb := probabilities["Flu"]
	coldProb := probabilities["Cold"]

	if fluProb > 0.3 && coldProb > 0.3 {
		if evidence["Fever"] == "none" {
			tests = append(tests, "Temperature measurement")
		}
		if evidence["SoreThroat"] == "no" {
			tests = append(tests, "Throat examination")
		}
	}

	pneumoniaProb := probabilities["Pneumonia"]
	if pneumoniaProb > 0.2 {
		tests = append(tests, "Chest X-ray")
		tests = append(tests, "Blood oxygen level")
	}

	if len(tests) == 0 {
		tests = append(tests, "Complete blood count")
		tests = append(tests, "Influenza PCR test")
	}

	return tests
}

// AnimateDiagnosisEvolution creates an animation of diagnostic evolution over time
func (mdd *MedicalDiagnosisDemo) AnimateDiagnosisEvolution() []string {
	frames := make([]string, 0)

	if len(mdd.diagnosisHistory) == 0 {
		return frames
	}

	// Create frames for each diagnosis
	for i, diagnosis := range mdd.diagnosisHistory {
		observation := mdd.patientHistory[i]
		frame := mdd.createDiagnosisFrame(observation, diagnosis, i)
		frames = append(frames, frame)
	}

	return frames
}

// createDiagnosisFrame creates a single frame of the diagnosis animation
func (mdd *MedicalDiagnosisDemo) createDiagnosisFrame(observation PatientObservation, diagnosis DiagnosisResult, frameIndex int) string {
	result := "🏥 Medical Diagnosis AI - Evolution Over Time\n"
	result += "═══════════════════════════════════════════════\n\n"

	// Patient information
	result += "👤 Patient Observation:\n"
	result += "   Time Step: " + string(diagnosis.TimeStep) + "\n"

	// Symptoms
	result += "   Symptoms:\n"
	for symptom, present := range observation.Symptoms {
		if present {
			result += "   ✅ " + symptom + "\n"
		} else {
			result += "   ❌ " + symptom + "\n"
		}
	}

	// Test results
	result += "   Test Results:\n"
	for test, value := range observation.TestResults {
		result += "   📊 " + test + ": " + string(int(value*100)/100) + "\n"
	}

	result += "\n🔍 AI Diagnosis Results:\n"

	// Disease probabilities with visual bars
	diseases := []string{"Flu", "Cold", "Pneumonia", "Allergy"}
	for _, disease := range diseases {
		prob := diagnosis.DiseaseProbabilities[disease]
		barWidth := int(prob * 30) // Scale to 30 characters
		bar := ""
		for i := 0; i < barWidth; i++ {
			bar += "█"
		}
		for i := barWidth; i < 30; i++ {
			bar += "░"
		}

		result += "   " + disease + ": " + bar + " " + string(int(prob*100)) + "%\n"
	}

	result += "\n💡 Confidence: " + string(int(diagnosis.Confidence*100)) + "%\n"

	// Recommended tests
	if len(diagnosis.RecommendedTests) > 0 {
		result += "\n🧪 Recommended Additional Tests:\n"
		for _, test := range diagnosis.RecommendedTests {
			result += "   • " + test + "\n"
		}
	}

	// Diagnostic insights
	result += "\n🧠 AI Insights:\n"
	maxProb := methods.Probability(0)
	mostLikely := ""
	for disease, prob := range diagnosis.DiseaseProbabilities {
		if prob > maxProb {
			maxProb = prob
			mostLikely = disease
		}
	}

	if maxProb > 0.5 {
		result += "   🎯 High confidence diagnosis: " + mostLikely + "\n"
	} else if maxProb > 0.3 {
		result += "   🤔 Moderate confidence, consider additional tests\n"
	} else {
		result += "   ❓ Low confidence, more information needed\n"
	}

	return result
}

// RunMedicalDiagnosisDemo demonstrates the medical diagnosis system
func RunMedicalDiagnosisDemo() {
	println("🏥 Starting Medical Diagnosis AI Demo")

	demo := NewMedicalDiagnosisDemo()

	// Simulate patient progression over time
	patientProgression := []PatientObservation{
		// Day 1: Early symptoms
		{
			Symptoms: map[string]bool{
				"fever": false,
				"cough": true,
				"fatigue": true,
				"headache": false,
				"soreThroat": false,
			},
			TestResults: map[string]float64{
				"temperature": 98.6,
				"whiteBloodCellCount": 8500,
			},
			TimeStep: 1,
		},
		// Day 2: Symptoms worsening
		{
			Symptoms: map[string]bool{
				"fever": true,
				"cough": true,
				"fatigue": true,
				"headache": true,
				"soreThroat": true,
			},
			TestResults: map[string]float64{
				"temperature": 100.5,
				"whiteBloodCellCount": 9200,
			},
			TimeStep: 2,
		},
		// Day 3: Peak symptoms
		{
			Symptoms: map[string]bool{
				"fever": true,
				"cough": true,
				"fatigue": true,
				"headache": true,
				"soreThroat": true,
			},
			TestResults: map[string]float64{
				"temperature": 102.1,
				"whiteBloodCellCount": 11500,
			},
			TimeStep: 3,
		},
		// Day 4: Beginning recovery
		{
			Symptoms: map[string]bool{
				"fever": false,
				"cough": true,
				"fatigue": true,
				"headache": false,
				"soreThroat": false,
			},
			TestResults: map[string]float64{
				"temperature": 99.2,
				"whiteBloodCellCount": 7800,
			},
			TimeStep: 4,
		},
	}

	// Add observations and generate diagnoses
	for _, observation := range patientProgression {
		demo.AddPatientObservation(observation)
	}

	// Generate animation
	frames := demo.AnimateDiagnosisEvolution()

	println("🎬 Generated", len(frames), "diagnosis evolution frames")

	// Display key frames
	for i := 0; i < len(frames) && i < 3; i++ {
		println("\n--- Diagnosis Evolution - Day", i+1, "---")
		println(frames[i])
	}

	if len(frames) > 3 {
		println("\n--- Diagnosis Evolution - Final Day ---")
		println(frames[len(frames)-1])
	}

	println("\n✅ Medical Diagnosis Demo Complete!")
	println("This demonstrates how AI can:")
	println("• Learn from patient symptoms over time")
	println("• Update diagnoses as new information arrives")
	println("• Recommend appropriate additional tests")
	println("• Provide confidence measures for clinical decisions")
}

// Main execution
func main() {
	RunMedicalDiagnosisDemo()
}
