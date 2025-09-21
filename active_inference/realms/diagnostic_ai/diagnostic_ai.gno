// Package diagnostic_ai provides an AI-powered medical diagnosis realm
// using Bayesian networks for probabilistic medical reasoning
package diagnostic_ai

import (
    "gno.land/p/active_inference/methods/bayesian_inference"
    "gno.land/p/active_inference/methods"
    "std"
    "gno.land/p/nt/ufmt"
    "math"
)

// =============================================================================
// GLOBAL STATE - PERSISTED ACROSS TRANSACTIONS
// =============================================================================

// Core diagnostic system
var diagnosticNetwork *bayesian_inference.BayesianNetwork
var inferenceEngine *bayesian_inference.VariableElimination

// Access control
var systemOwner string
var authorizedDoctors []string

// Diagnosis history and analytics
var diagnosisHistory []DiagnosisCase
var systemMetrics SystemMetrics

// Configuration
var confidenceThreshold methods.Probability
var maxHistorySize int
var totalGasUsed uint64

// =============================================================================
// DATA STRUCTURES
// =============================================================================

// DiagnosisCase represents a complete diagnostic assessment
type DiagnosisCase struct {
    PatientID          string
    Timestamp          int64
    Symptoms           map[string]bool
    TestResults        map[string]float64
    Diagnosis          map[string]methods.Probability
    Confidence         methods.Probability
    RecommendedTests   []string
    DoctorID           string
    GasUsed           uint64
    ProcessingTime    int64
}

// SystemMetrics tracks overall system performance
type SystemMetrics struct {
    TotalDiagnoses     int64
    AverageConfidence  methods.Probability
    MostCommonDisease  string
    AverageGasPerCase  uint64
    LastUpdateTime     int64
}

// TestRecommendation represents a recommended diagnostic test
type TestRecommendation struct {
    TestName     string
    Priority     int    // 1=low, 2=medium, 3=high
    Rationale    string
    EstimatedCost float64
}

// =============================================================================
// REALM INITIALIZATION
// =============================================================================

// init initializes the diagnostic AI system
func init() {
    // Initialize Bayesian network
    diagnosticNetwork = createMedicalBayesianNetwork()

    // Initialize inference engine
    var err error
    inferenceEngine, err = bayesian_inference.NewVariableElimination(diagnosticNetwork)
    if err != nil {
        panic("Failed to initialize inference engine: " + err.Error())
    }

    // Initialize access control
    systemOwner = ""
    authorizedDoctors = make([]string, 0)

    // Initialize history and metrics
    diagnosisHistory = make([]DiagnosisCase, 0)
    systemMetrics = SystemMetrics{
        TotalDiagnoses:     0,
        AverageConfidence:  0.0,
        MostCommonDisease:  "None",
        AverageGasPerCase:  0,
        LastUpdateTime:     std.BlockTime(),
    }

    // Set configuration
    confidenceThreshold = 0.7
    maxHistorySize = 1000

    // Emit initialization event
    std.Emit("DiagnosticSystemInitialized", map[string]interface{}{
        "timestamp": std.BlockTime(),
        "networkNodes": len(diagnosticNetwork.Nodes),
        "confidenceThreshold": confidenceThreshold,
    })
}

// createMedicalBayesianNetwork initializes the medical diagnostic network
func createMedicalBayesianNetwork() *bayesian_inference.BayesianNetwork {
    network := bayesian_inference.NewBayesianNetwork()

    // Define diseases
    flu := bayesian_inference.NewNode("Flu", []string{"yes", "no"})
    cold := bayesian_inference.NewNode("Cold", []string{"yes", "no"})
    pneumonia := bayesian_inference.NewNode("Pneumonia", []string{"yes", "no"})
    allergy := bayesian_inference.NewNode("Allergy", []string{"yes", "no"})
    covid := bayesian_inference.NewNode("COVID", []string{"yes", "no"})

    // Define symptoms
    fever := bayesian_inference.NewNode("Fever", []string{"high", "moderate", "none"})
    cough := bayesian_inference.NewNode("Cough", []string{"severe", "mild", "none"})
    fatigue := bayesian_inference.NewNode("Fatigue", []string{"severe", "mild", "none"})
    headache := bayesian_inference.NewNode("Headache", []string{"severe", "mild", "none"})
    soreThroat := bayesian_inference.NewNode("SoreThroat", []string{"yes", "no"})
    shortnessOfBreath := bayesian_inference.NewNode("ShortnessOfBreath", []string{"yes", "no"})
    lossOfTaste := bayesian_inference.NewNode("LossOfTaste", []string{"yes", "no"})

    // Set up causal relationships
    fever.AddParent(flu)
    fever.AddParent(pneumonia)
    fever.AddParent(covid)

    cough.AddParent(flu)
    cough.AddParent(cold)
    cough.AddParent(covid)

    fatigue.AddParent(flu)
    fatigue.AddParent(pneumonia)
    fatigue.AddParent(covid)

    headache.AddParent(flu)
    headache.AddParent(cold)
    headache.AddParent(covid)

    soreThroat.AddParent(flu)
    soreThroat.AddParent(cold)

    shortnessOfBreath.AddParent(pneumonia)
    shortnessOfBreath.AddParent(covid)

    lossOfTaste.AddParent(covid)

    // Add nodes to network
    network.AddNode(flu)
    network.AddNode(cold)
    network.AddNode(pneumonia)
    network.AddNode(allergy)
    network.AddNode(covid)
    network.AddNode(fever)
    network.AddNode(cough)
    network.AddNode(fatigue)
    network.AddNode(headache)
    network.AddNode(soreThroat)
    network.AddNode(shortnessOfBreath)
    network.AddNode(lossOfTaste)

    // Set conditional probability tables
    setupMedicalCPTs(network)

    return network
}

// setupMedicalCPTs configures conditional probability tables
func setupMedicalCPTs(network *bayesian_inference.BayesianNetwork) {
    // Prior probabilities for diseases (based on general population incidence)
    network.GetNode("Flu").SetCPT("", []methods.Probability{0.06, 0.94})        // 6% flu incidence
    network.GetNode("Cold").SetCPT("", []methods.Probability{0.12, 0.88})       // 12% cold incidence
    network.GetNode("Pneumonia").SetCPT("", []methods.Probability{0.02, 0.98})  // 2% pneumonia incidence
    network.GetNode("Allergy").SetCPT("", []methods.Probability{0.15, 0.85})    // 15% allergy incidence
    network.GetNode("COVID").SetCPT("", []methods.Probability{0.08, 0.92})     // 8% COVID incidence

    // Conditional probabilities for symptoms given diseases
    // Fever | Diseases
    network.GetNode("Fever").SetCPT("Flu=yes,Pneumonia=yes,COVID=yes", []methods.Probability{0.9, 0.08, 0.02})
    network.GetNode("Fever").SetCPT("Flu=yes,Pneumonia=yes,COVID=no", []methods.Probability{0.8, 0.15, 0.05})
    network.GetNode("Fever").SetCPT("Flu=yes,Pneumonia=no,COVID=yes", []methods.Probability{0.85, 0.1, 0.05})
    network.GetNode("Fever").SetCPT("Flu=yes,Pneumonia=no,COVID=no", []methods.Probability{0.6, 0.3, 0.1})
    network.GetNode("Fever").SetCPT("Flu=no,Pneumonia=yes,COVID=yes", []methods.Probability{0.9, 0.08, 0.02})
    network.GetNode("Fever").SetCPT("Flu=no,Pneumonia=yes,COVID=no", []methods.Probability{0.75, 0.2, 0.05})
    network.GetNode("Fever").SetCPT("Flu=no,Pneumonia=no,COVID=yes", []methods.Probability{0.7, 0.25, 0.05})
    network.GetNode("Fever").SetCPT("Flu=no,Pneumonia=no,COVID=no", []methods.Probability{0.05, 0.15, 0.8})

    // Cough | Diseases
    network.GetNode("Cough").SetCPT("Flu=yes,Cold=yes,COVID=yes", []methods.Probability{0.95, 0.04, 0.01})
    network.GetNode("Cough").SetCPT("Flu=yes,Cold=yes,COVID=no", []methods.Probability{0.85, 0.12, 0.03})
    network.GetNode("Cough").SetCPT("Flu=yes,Cold=no,COVID=yes", []methods.Probability{0.9, 0.08, 0.02})
    network.GetNode("Cough").SetCPT("Flu=yes,Cold=no,COVID=no", []methods.Probability{0.7, 0.25, 0.05})
    network.GetNode("Cough").SetCPT("Flu=no,Cold=yes,COVID=yes", []methods.Probability{0.8, 0.15, 0.05})
    network.GetNode("Cough").SetCPT("Flu=no,Cold=yes,COVID=no", []methods.Probability{0.6, 0.3, 0.1})
    network.GetNode("Cough").SetCPT("Flu=no,Cold=no,COVID=yes", []methods.Probability{0.75, 0.2, 0.05})
    network.GetNode("Cough").SetCPT("Flu=no,Cold=no,COVID=no", []methods.Probability{0.05, 0.15, 0.8})

    // Similar setup for other symptoms...
    setupRemainingCPTs(network)
}

// setupRemainingCPTs sets up CPTs for remaining symptoms
func setupRemainingCPTs(network *bayesian_inference.BayesianNetwork) {
    // Fatigue | Diseases
    network.GetNode("Fatigue").SetCPT("Flu=yes,Pneumonia=yes,COVID=yes", []methods.Probability{0.95, 0.04, 0.01})
    network.GetNode("Fatigue").SetCPT("Flu=yes,Pneumonia=yes,COVID=no", []methods.Probability{0.9, 0.08, 0.02})
    network.GetNode("Fatigue").SetCPT("Flu=yes,Pneumonia=no,COVID=yes", []methods.Probability{0.85, 0.12, 0.03})
    network.GetNode("Fatigue").SetCPT("Flu=yes,Pneumonia=no,COVID=no", []methods.Probability{0.7, 0.25, 0.05})
    network.GetNode("Fatigue").SetCPT("Flu=no,Pneumonia=yes,COVID=yes", []methods.Probability{0.9, 0.08, 0.02})
    network.GetNode("Fatigue").SetCPT("Flu=no,Pneumonia=yes,COVID=no", []methods.Probability{0.8, 0.15, 0.05})
    network.GetNode("Fatigue").SetCPT("Flu=no,Pneumonia=no,COVID=yes", []methods.Probability{0.75, 0.2, 0.05})
    network.GetNode("Fatigue").SetCPT("Flu=no,Pneumonia=no,COVID=no", []methods.Probability{0.1, 0.2, 0.7})

    // Sore Throat | Diseases
    network.GetNode("SoreThroat").SetCPT("Flu=yes,Cold=yes", []methods.Probability{0.8, 0.2})
    network.GetNode("SoreThroat").SetCPT("Flu=yes,Cold=no", []methods.Probability{0.6, 0.4})
    network.GetNode("SoreThroat").SetCPT("Flu=no,Cold=yes", []methods.Probability{0.7, 0.3})
    network.GetNode("SoreThroat").SetCPT("Flu=no,Cold=no", []methods.Probability{0.1, 0.9})

    // Shortness of Breath | Diseases
    network.GetNode("ShortnessOfBreath").SetCPT("Pneumonia=yes,COVID=yes", []methods.Probability{0.9, 0.1})
    network.GetNode("ShortnessOfBreath").SetCPT("Pneumonia=yes,COVID=no", []methods.Probability{0.8, 0.2})
    network.GetNode("ShortnessOfBreath").SetCPT("Pneumonia=no,COVID=yes", []methods.Probability{0.7, 0.3})
    network.GetNode("ShortnessOfBreath").SetCPT("Pneumonia=no,COVID=no", []methods.Probability{0.05, 0.95})

    // Loss of Taste | COVID
    network.GetNode("LossOfTaste").SetCPT("yes", []methods.Probability{0.8, 0.2})
    network.GetNode("LossOfTaste").SetCPT("no", []methods.Probability{0.1, 0.9})
}

// =============================================================================
// DEPLOYMENT AND ACCESS CONTROL
// =============================================================================

// Deploy initializes the diagnostic AI system
func Deploy(caller string, ownerAddress string) string {
    // Check if already deployed
    if systemOwner != "" {
        return "Error: Diagnostic system already deployed"
    }

    // Validate owner address
    if !std.IsValidAddress(ownerAddress) {
        return "Error: Invalid owner address format"
    }

    systemOwner = ownerAddress
    authorizedDoctors = append(authorizedDoctors, ownerAddress)

    std.Emit("DiagnosticSystemDeployed", map[string]interface{}{
        "owner": ownerAddress,
        "networkSize": len(diagnosticNetwork.Nodes),
        "timestamp": std.BlockTime(),
    })

    return "Diagnostic AI system deployed successfully"
}

// AuthorizeDoctor grants access to medical professionals
func AuthorizeDoctor(caller string, doctorAddress string) string {
    if caller != systemOwner {
        return "Access denied: only system owner can authorize doctors"
    }

    if !std.IsValidAddress(doctorAddress) {
        return "Error: Invalid doctor address format"
    }

    for _, doctor := range authorizedDoctors {
        if doctor == doctorAddress {
            return "Doctor already authorized"
        }
    }

    authorizedDoctors = append(authorizedDoctors, doctorAddress)

    std.Emit("DoctorAuthorized", map[string]interface{}{
        "doctor": doctorAddress,
        "authorizedBy": caller,
        "timestamp": std.BlockTime(),
    })

    return "Doctor authorized successfully"
}

// IsAuthorizedDoctor checks if a user is an authorized medical professional
func IsAuthorizedDoctor(doctorAddress string) bool {
    for _, doctor := range authorizedDoctors {
        if doctor == doctorAddress {
            return true
        }
    }
    return false
}

// =============================================================================
// CORE DIAGNOSTIC FUNCTIONS
// =============================================================================

// DiagnosePatient performs comprehensive diagnostic analysis
func DiagnosePatient(caller string, patientID string, symptoms map[string]bool, testResults map[string]float64) string {
    // Check authorization
    if !IsAuthorizedDoctor(caller) {
        return "Access denied: only authorized doctors can perform diagnoses"
    }

    // Validate inputs
    if patientID == "" {
        return "Error: Patient ID cannot be empty"
    }

    // Record timing and gas usage
    startTime := std.BlockTime()
    startGas := std.GasUsed()

    // Convert symptoms and test results to evidence
    evidence := make(map[string]string)

    // Process fever based on temperature
    if temp, exists := testResults["temperature"]; exists {
        if temp >= 101.0 {
            evidence["Fever"] = "high"
        } else if temp >= 99.0 {
            evidence["Fever"] = "moderate"
        } else {
            evidence["Fever"] = "none"
        }
    } else if symptoms["fever"] {
        evidence["Fever"] = "moderate" // Assume moderate if reported but not measured
    } else {
        evidence["Fever"] = "none"
    }

    // Process cough
    if symptoms["cough"] {
        evidence["Cough"] = "severe" // Assume severe if present
    } else {
        evidence["Cough"] = "none"
    }

    // Process fatigue
    if symptoms["fatigue"] {
        evidence["Fatigue"] = "severe"
    } else {
        evidence["Fatigue"] = "none"
    }

    // Process headache
    if symptoms["headache"] {
        evidence["Headache"] = "severe"
    } else {
        evidence["Headache"] = "none"
    }

    // Process sore throat
    if symptoms["soreThroat"] {
        evidence["SoreThroat"] = "yes"
    } else {
        evidence["SoreThroat"] = "no"
    }

    // Process shortness of breath
    if symptoms["shortnessOfBreath"] {
        evidence["ShortnessOfBreath"] = "yes"
    } else {
        evidence["ShortnessOfBreath"] = "no"
    }

    // Process loss of taste/smell
    if symptoms["lossOfTaste"] || symptoms["lossOfSmell"] {
        evidence["LossOfTaste"] = "yes"
    } else {
        evidence["LossOfTaste"] = "no"
    }

    // Perform Bayesian inference
    diagnosis := make(map[string]methods.Probability)
    diseases := []string{"Flu", "Cold", "Pneumonia", "Allergy", "COVID"}

    for _, disease := range diseases {
        query := map[string]string{disease: ""}
        result := inferenceEngine.Query(query, evidence)
        diagnosis[disease] = result["yes"]
    }

    // Calculate diagnostic confidence
    confidence := calculateDiagnosticConfidence(diagnosis, evidence)

    // Generate test recommendations
    recommendations := generateTestRecommendations(diagnosis, evidence, testResults)

    // Record diagnosis
    endTime := std.BlockTime()
    endGas := std.GasUsed()

    diagnosisCase := DiagnosisCase{
        PatientID:        patientID,
        Timestamp:        startTime,
        Symptoms:         symptoms,
        TestResults:      testResults,
        Diagnosis:        diagnosis,
        Confidence:       confidence,
        RecommendedTests: recommendations,
        DoctorID:         caller,
        GasUsed:          endGas - startGas,
        ProcessingTime:   endTime - startTime,
    }

    // Manage history size
    if len(diagnosisHistory) >= maxHistorySize {
        diagnosisHistory = diagnosisHistory[1:]
    }
    diagnosisHistory = append(diagnosisHistory, diagnosisCase)

    // Update system metrics
    updateSystemMetrics(diagnosisCase)

    // Emit diagnosis event
    std.Emit("DiagnosisCompleted", map[string]interface{}{
        "patientID": patientID,
        "doctor": caller,
        "confidence": confidence,
        "primaryDiagnosis": getPrimaryDiagnosis(diagnosis),
        "gasUsed": diagnosisCase.GasUsed,
        "processingTime": diagnosisCase.ProcessingTime,
        "timestamp": startTime,
    })

    // Format and return results
    return formatDiagnosisResults(diagnosisCase)
}

// calculateDiagnosticConfidence computes overall confidence in diagnosis
func calculateDiagnosticConfidence(diagnosis map[string]methods.Probability, evidence map[string]string) methods.Probability {
    // Base confidence on evidence strength
    evidenceCount := len(evidence)
    evidenceStrength := methods.Probability(evidenceCount) / 7.0 // Normalize by max possible evidence

    // Calculate probability spread (lower spread = higher confidence)
    probs := make([]methods.Probability, 0, len(diagnosis))
    for _, prob := range diagnosis {
        probs = append(probs, prob)
    }

    // Find max probability
    maxProb := methods.Probability(0)
    for _, prob := range probs {
        if prob > maxProb {
            maxProb = prob
        }
    }

    // Calculate spread from max probability
    spread := methods.Probability(0)
    for _, prob := range probs {
        spread += (maxProb - prob) * (maxProb - prob)
    }
    spread = methods.Probability(math.Sqrt(float64(spread) / float64(len(probs))))

    // Lower spread = higher confidence
    spreadConfidence := methods.Probability(1.0) / (methods.Probability(1.0) + spread)

    // Combine factors
    confidence := (evidenceStrength * 0.6) + (spreadConfidence * 0.4)

    // Ensure reasonable bounds
    if confidence > 1.0 {
        confidence = 1.0
    } else if confidence < 0.0 {
        confidence = 0.0
    }

    return confidence
}

// generateTestRecommendations suggests additional diagnostic tests
func generateTestRecommendations(diagnosis map[string]methods.Probability, evidence map[string]string, testResults map[string]float64) []string {
    tests := make([]string, 0)

    fluProb := diagnosis["Flu"]
    pneumoniaProb := diagnosis["Pneumonia"]
    covidProb := diagnosis["COVID"]

    // Temperature test
    if _, hasTemp := testResults["temperature"]; !hasTemp {
        tests = append(tests, "Temperature measurement")
    }

    // Blood tests
    if fluProb > 0.3 || pneumoniaProb > 0.2 {
        tests = append(tests, "Complete blood count (CBC)")
    }

    // PCR tests for respiratory infections
    if fluProb > 0.4 {
        tests = append(tests, "Influenza PCR test")
    }
    if covidProb > 0.3 {
        tests = append(tests, "COVID-19 PCR test")
    }

    // Imaging studies
    if pneumoniaProb > 0.3 {
        tests = append(tests, "Chest X-ray")
        tests = append(tests, "CT chest scan")
    }

    // Specialized tests
    if covidProb > 0.4 {
        tests = append(tests, "COVID-19 antibody test")
    }

    return tests
}

// getPrimaryDiagnosis identifies the most likely diagnosis
func getPrimaryDiagnosis(diagnosis map[string]methods.Probability) string {
    maxProb := methods.Probability(0)
    primary := "Unknown"

    for disease, prob := range diagnosis {
        if prob > maxProb {
            maxProb = prob
            primary = disease
        }
    }

    return primary
}

// formatDiagnosisResults creates a human-readable diagnosis report
func formatDiagnosisResults(case DiagnosisCase) string {
    result := "🏥 AI Medical Diagnosis Report\n"
    result += "═══════════════════════════════════════════════\n\n"

    result += "👤 Patient ID: " + case.PatientID + "\n"
    result += ufmt.Sprintf("👨‍⚕️ Doctor: %s\n", case.DoctorID)
    result += ufmt.Sprintf("📅 Diagnosis Time: %d\n", case.Timestamp)
    result += ufmt.Sprintf("⚡ Processing Gas: %d\n\n", case.GasUsed)

    result += "📊 Disease Probabilities:\n"
    diseases := []string{"Flu", "Cold", "Pneumonia", "Allergy", "COVID"}

    for _, disease := range diseases {
        prob := case.Diagnosis[disease]
        barWidth := int(prob * 30)
        bar := ""
        for i := 0; i < barWidth; i++ {
            bar += "█"
        }
        for i := barWidth; i < 30; i++ {
            bar += "░"
        }

        result += ufmt.Sprintf("   %s: %s %.1f%%\n", disease, bar, prob*100)
    }

    result += ufmt.Sprintf("\n🎯 Diagnostic Confidence: %.1f%%\n", case.Confidence*100)

    // Confidence interpretation
    if case.Confidence > 0.8 {
        result += "   🟢 HIGH CONFIDENCE: Strong evidence supports diagnosis\n"
    } else if case.Confidence > 0.6 {
        result += "   🟡 MODERATE CONFIDENCE: Reasonable evidence, consider additional tests\n"
    } else {
        result += "   🔴 LOW CONFIDENCE: Limited evidence, additional testing recommended\n"
    }

    // Primary diagnosis
    primary := getPrimaryDiagnosis(case.Diagnosis)
    primaryProb := case.Diagnosis[primary]
    result += ufmt.Sprintf("\n🏆 Primary Diagnosis: %s (%.1f%% probability)\n", primary, primaryProb*100)

    // Recommendations
    if len(case.RecommendedTests) > 0 {
        result += "\n🧪 Recommended Additional Tests:\n"
        for i, test := range case.RecommendedTests {
            result += ufmt.Sprintf("   %d. %s\n", i+1, test)
        }
    }

    // Clinical insights
    result += "\n🧠 AI Clinical Insights:\n"
    if primaryProb > 0.7 {
        result += "   • High probability diagnosis - proceed with treatment\n"
    } else if primaryProb > 0.5 {
        result += "   • Moderate probability - consider differential diagnosis\n"
    } else {
        result += "   • Low probability - broad differential diagnosis needed\n"
    }

    // Risk assessment
    highRiskCount := 0
    for _, prob := range case.Diagnosis {
        if prob > 0.3 {
            highRiskCount++
        }
    }

    if highRiskCount > 2 {
        result += "   • Multiple differential diagnoses - comprehensive evaluation needed\n"
    }

    return result
}

// updateSystemMetrics updates overall system performance metrics
func updateSystemMetrics(newCase DiagnosisCase) {
    systemMetrics.TotalDiagnoses++

    // Update average confidence
    totalConfidence := systemMetrics.AverageConfidence * methods.Probability(systemMetrics.TotalDiagnoses-1)
    totalConfidence += newCase.Confidence
    systemMetrics.AverageConfidence = totalConfidence / methods.Probability(systemMetrics.TotalDiagnoses)

    // Update most common disease
    diseaseCounts := make(map[string]int)
    for _, case := range diagnosisHistory {
        primary := getPrimaryDiagnosis(case.Diagnosis)
        diseaseCounts[primary]++
    }

    maxCount := 0
    mostCommon := "None"
    for disease, count := range diseaseCounts {
        if count > maxCount {
            maxCount = count
            mostCommon = disease
        }
    }
    systemMetrics.MostCommonDisease = mostCommon

    // Update gas metrics
    totalGas := systemMetrics.AverageGasPerCase * uint64(systemMetrics.TotalDiagnoses-1)
    totalGas += newCase.GasUsed
    systemMetrics.AverageGasPerCase = totalGas / uint64(systemMetrics.TotalDiagnoses)

    systemMetrics.LastUpdateTime = std.BlockTime()
}

// =============================================================================
// MONITORING AND ANALYTICS
// =============================================================================

// GetSystemStatus returns comprehensive system status
func GetSystemStatus(caller string) string {
    if !IsAuthorizedDoctor(caller) {
        return "Access denied: only authorized doctors can view system status"
    }

    status := "🏥 Diagnostic AI System Status\n"
    status += "═══════════════════════════════════════════════\n\n"

    status += "👑 System Owner: " + systemOwner + "\n"
    status += ufmt.Sprintf("👨‍⚕️ Authorized Doctors: %d\n", len(authorizedDoctors))
    status += ufmt.Sprintf("📊 Total Diagnoses: %d\n", systemMetrics.TotalDiagnoses)
    status += ufmt.Sprintf("🎯 Average Confidence: %.1f%%\n", systemMetrics.AverageConfidence*100)
    status += "🏆 Most Common Diagnosis: " + systemMetrics.MostCommonDisease + "\n"
    status += ufmt.Sprintf("⚡ Average Gas per Diagnosis: %d\n", systemMetrics.AverageGasPerCase)
    status += ufmt.Sprintf("📚 Diagnosis History Size: %d/%d\n", len(diagnosisHistory), maxHistorySize)
    status += ufmt.Sprintf("⏰ Last Update: %d\n\n", systemMetrics.LastUpdateTime)

    status += "🧠 Bayesian Network Status:\n"
    status += ufmt.Sprintf("   • Disease Nodes: 5\n")
    status += ufmt.Sprintf("   • Symptom Nodes: 7\n")
    status += ufmt.Sprintf("   • Total Nodes: %d\n", len(diagnosticNetwork.Nodes))
    status += ufmt.Sprintf("   • Confidence Threshold: %.1f\n\n", confidenceThreshold)

    status += "📈 Performance Assessment:\n"
    if systemMetrics.AverageConfidence > 0.8 {
        status += "   🟢 EXCELLENT: High diagnostic confidence across cases\n"
    } else if systemMetrics.AverageConfidence > 0.6 {
        status += "   🟡 GOOD: Moderate diagnostic confidence\n"
    } else {
        status += "   🔴 NEEDS IMPROVEMENT: Low diagnostic confidence\n"
    }

    if systemMetrics.AverageGasPerCase < 50000 {
        status += "   🟢 EFFICIENT: Gas usage is within acceptable limits\n"
    } else {
        status += "   ⚠️  HIGH GAS USAGE: Consider optimization\n"
    }

    return status
}

// GetDiagnosisHistory returns recent diagnosis history
func GetDiagnosisHistory(caller string, limit int) string {
    if !IsAuthorizedDoctor(caller) {
        return "Access denied: only authorized doctors can view diagnosis history"
    }

    if len(diagnosisHistory) == 0 {
        return "No diagnosis history available"
    }

    if limit <= 0 || limit > len(diagnosisHistory) {
        limit = len(diagnosisHistory)
    }

    history := ufmt.Sprintf("📚 Diagnosis History (Last %d cases):\n", limit)
    history += "═══════════════════════════════════════════════\n"

    start := len(diagnosisHistory) - limit
    if start < 0 {
        start = 0
    }

    for i := start; i < len(diagnosisHistory); i++ {
        case := diagnosisHistory[i]
        history += ufmt.Sprintf("\nCase %d: Patient %s\n", i+1, case.PatientID)
        history += ufmt.Sprintf("   Time: %d\n", case.Timestamp)
        history += ufmt.Sprintf("   Confidence: %.1f%%\n", case.Confidence*100)

        primary := getPrimaryDiagnosis(case.Diagnosis)
        primaryProb := case.Diagnosis[primary]
        history += ufmt.Sprintf("   Primary Diagnosis: %s (%.1f%%)\n", primary, primaryProb*100)
        history += ufmt.Sprintf("   Gas Used: %d\n", case.GasUsed)
    }

    return history
}

// AnalyzeDiagnosticPerformance provides detailed performance analysis
func AnalyzeDiagnosticPerformance(caller string) string {
    if !IsAuthorizedDoctor(caller) {
        return "Access denied: only authorized doctors can analyze performance"
    }

    analysis := "📊 Diagnostic Performance Analysis\n"
    analysis += "═══════════════════════════════════════════════\n\n"

    if len(diagnosisHistory) == 0 {
        return analysis + "No diagnosis data available for analysis"
    }

    // Confidence distribution
    highConfidence := 0
    mediumConfidence := 0
    lowConfidence := 0

    for _, case := range diagnosisHistory {
        if case.Confidence > 0.8 {
            highConfidence++
        } else if case.Confidence > 0.6 {
            mediumConfidence++
        } else {
            lowConfidence++
        }
    }

    analysis += "🎯 Confidence Distribution:\n"
    analysis += ufmt.Sprintf("   High (>80%%): %d cases (%.1f%%)\n",
        highConfidence, float64(highConfidence)/float64(len(diagnosisHistory))*100)
    analysis += ufmt.Sprintf("   Medium (60-80%%): %d cases (%.1f%%)\n",
        mediumConfidence, float64(mediumConfidence)/float64(len(diagnosisHistory))*100)
    analysis += ufmt.Sprintf("   Low (<60%%): %d cases (%.1f%%)\n\n",
        lowConfidence, float64(lowConfidence)/float64(len(diagnosisHistory))*100)

    // Disease frequency analysis
    diseaseFreq := make(map[string]int)
    for _, case := range diagnosisHistory {
        primary := getPrimaryDiagnosis(case.Diagnosis)
        diseaseFreq[primary]++
    }

    analysis += "🏥 Disease Frequency:\n"
    diseases := []string{"Flu", "Cold", "Pneumonia", "Allergy", "COVID"}
    for _, disease := range diseases {
        count := diseaseFreq[disease]
        percentage := float64(count) / float64(len(diagnosisHistory)) * 100
        analysis += ufmt.Sprintf("   %s: %d cases (%.1f%%)\n", disease, count, percentage)
    }

    analysis += "\n💡 Recommendations:\n"
    if float64(lowConfidence)/float64(len(diagnosisHistory)) > 0.3 {
        analysis += "   • Consider improving evidence collection\n"
        analysis += "   • Review symptom assessment protocols\n"
    }

    mostCommon := ""
    maxFreq := 0
    for disease, freq := range diseaseFreq {
        if freq > maxFreq {
            maxFreq = freq
            mostCommon = disease
        }
    }

    if maxFreq > len(diagnosisHistory)/2 {
        analysis += ufmt.Sprintf("   • High incidence of %s - consider public health measures\n", mostCommon)
    }

    return analysis
}

// =============================================================================
// RENDER METHOD FOR BLOCKCHAIN QUERIES
// =============================================================================

// Render provides different views of the diagnostic system
func Render(path string) string {
    switch path {
    case "":
        return GetSystemStatus("")
    case "status":
        return GetSystemStatus("")
    case "metrics":
        return ufmt.Sprintf(`System Metrics:
Diagnoses: %d
Avg Confidence: %.1f%%
Most Common: %s
Avg Gas: %d`,
            systemMetrics.TotalDiagnoses,
            systemMetrics.AverageConfidence*100,
            systemMetrics.MostCommonDisease,
            systemMetrics.AverageGasPerCase)
    case "performance":
        return AnalyzeDiagnosticPerformance("")
    case "history":
        return GetDiagnosisHistory("", 5)
    case "network":
        return ufmt.Sprintf("Bayesian Network: %d nodes, %d diagnoses completed",
            len(diagnosticNetwork.Nodes), len(diagnosisHistory))
    default:
        return "Unknown path: " + path + ". Try: status, metrics, performance, history, network"
    }
}

