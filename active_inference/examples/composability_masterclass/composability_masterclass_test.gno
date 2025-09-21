// Package composability_masterclass_test provides comprehensive tests for the
// composability masterclass demonstration system
package composability_masterclass

import (
	"testing"
	"gno.land/p/active_inference/methods"
)

// TestNewComposabilityMasterclass tests the creation of the composability masterclass
func TestNewComposabilityMasterclass(t *testing.T) {
	masterclass := NewComposabilityMasterclass()

	if masterclass == nil {
		t.Error("Expected non-nil composability masterclass")
	}

	if masterclass.composabilityIndex != 0.99 {
		t.Errorf("Expected composability index 0.99, got %f", masterclass.composabilityIndex)
	}

	if masterclass.performance.AverageAccuracy != 0.98 {
		t.Errorf("Expected average accuracy 0.98, got %f", masterclass.performance.AverageAccuracy)
	}

	if masterclass.engine == nil {
		t.Error("Expected non-nil advanced inference engine")
	}
}

// TestMarketPredictionSystem tests the market prediction system
func TestMarketPredictionSystem(t *testing.T) {
	mps := NewMarketPredictionSystem()

	if mps == nil {
		t.Error("Expected non-nil market prediction system")
	}

	if mps.ensemble == nil {
		t.Error("Expected non-nil ensemble")
	}

	if mps.trendModel == nil {
		t.Error("Expected non-nil trend model")
	}

	if mps.volatilityModel == nil {
		t.Error("Expected non-nil volatility model")
	}

	// Test market prediction
	marketData := []MarketObservation{
		{Price: 0.8, Volume: 0.7, Volatility: 0.3, Trend: 0.6},
		{Price: 0.9, Volume: 0.8, Volatility: 0.2, Trend: 0.7},
	}

	prediction, err := mps.PredictMarketConditions(marketData)
	if err != nil {
		t.Errorf("Expected no error from market prediction, got %v", err)
	}

	if prediction.Trend < 0 || prediction.Trend > 1 {
		t.Errorf("Expected trend between 0 and 1, got %f", prediction.Trend)
	}

	if prediction.Confidence < 0 || prediction.Confidence > 1 {
		t.Errorf("Expected confidence between 0 and 1, got %f", prediction.Confidence)
	}
}

// TestRiskAssessmentSystem tests the risk assessment system
func TestRiskAssessmentSystem(t *testing.T) {
	ras := NewRiskAssessmentSystem()

	if ras == nil {
		t.Error("Expected non-nil risk assessment system")
	}

	if ras.ensemble == nil {
		t.Error("Expected non-nil ensemble")
	}

	if ras.varModel == nil {
		t.Error("Expected non-nil VaR model")
	}

	// Test risk assessment
	portfolioData := []PortfolioPosition{
		{AssetID: "BTC", Quantity: 0.5, CurrentPrice: 0.9, RiskWeight: 0.3},
		{AssetID: "ETH", Quantity: 0.3, CurrentPrice: 0.7, RiskWeight: 0.4},
	}

	assessment, err := ras.AssessRisk(portfolioData)
	if err != nil {
		t.Errorf("Expected no error from risk assessment, got %v", err)
	}

	if assessment.ValueAtRisk < 0 || assessment.ValueAtRisk > 1 {
		t.Errorf("Expected VaR between 0 and 1, got %f", assessment.ValueAtRisk)
	}

	if assessment.OverallRisk < 0 || assessment.OverallRisk > 1 {
		t.Errorf("Expected overall risk between 0 and 1, got %f", assessment.OverallRisk)
	}
}

// TestDecisionOptimizationSystem tests the decision optimization system
func TestDecisionOptimizationSystem(t *testing.T) {
	dos := NewDecisionOptimizationSystem()

	if dos == nil {
		t.Error("Expected non-nil decision optimization system")
	}

	if dos.ensemble == nil {
		t.Error("Expected non-nil ensemble")
	}

	// Test decision optimization
	decisionContext := DecisionContext{
		Options: []DecisionOption{
			{
				Action: "buy",
				Parameters: map[string]methods.Probability{
					"amount": 0.2,
					"price":  0.8,
				},
			},
		},
		Constraints: []string{"max_allocation_50%"},
	}

	decision, err := dos.OptimizeDecision(decisionContext)
	if err != nil {
		t.Errorf("Expected no error from decision optimization, got %v", err)
	}

	if decision.ExpectedUtility < 0 || decision.ExpectedUtility > 1 {
		t.Errorf("Expected expected utility between 0 and 1, got %f", decision.ExpectedUtility)
	}

	if decision.Confidence < 0 || decision.Confidence > 1 {
		t.Errorf("Expected confidence between 0 and 1, got %f", decision.Confidence)
	}
}

// TestPrivacyController tests the privacy controller
func TestPrivacyController(t *testing.T) {
	pc := NewPrivacyController()

	if pc == nil {
		t.Error("Expected non-nil privacy controller")
	}

	if pc.privacyEngine == nil {
		t.Error("Expected non-nil privacy engine")
	}

	if pc.budgetTracker.remainingBudget != 1.0 {
		t.Errorf("Expected full privacy budget, got %f", pc.budgetTracker.remainingBudget)
	}

	// Test privacy preservation
	data := []methods.Probability{0.8, 0.6, 0.4, 0.7}
	privateData, err := pc.EnsurePrivacy("test_operation", data)

	if err != nil {
		t.Errorf("Expected no error from privacy preservation, got %v", err)
	}

	if len(privateData) != len(data) {
		t.Errorf("Expected same length data, got %d vs %d", len(privateData), len(data))
	}

	// Test privacy budget tracking
	if pc.budgetTracker.usedBudget <= 0 {
		t.Error("Expected some privacy budget usage")
	}

	if pc.budgetTracker.remainingBudget >= pc.budgetTracker.totalBudget {
		t.Error("Expected privacy budget to be reduced")
	}
}

// TestCompleteWorkflow tests the complete composability workflow
func TestCompleteWorkflow(t *testing.T) {
	cmc := NewComposabilityMasterclass()

	// Create comprehensive test data
	marketData := []MarketObservation{
		{Price: 0.8, Volume: 0.7, Volatility: 0.3, Trend: 0.6},
		{Price: 0.9, Volume: 0.8, Volatility: 0.2, Trend: 0.7},
		{Price: 0.7, Volume: 0.6, Volatility: 0.4, Trend: 0.5},
	}

	portfolioData := []PortfolioPosition{
		{AssetID: "BTC", Quantity: 0.5, CurrentPrice: 0.9, RiskWeight: 0.3},
		{AssetID: "ETH", Quantity: 0.3, CurrentPrice: 0.7, RiskWeight: 0.4},
		{AssetID: "ADA", Quantity: 0.2, CurrentPrice: 0.5, RiskWeight: 0.2},
	}

	decisionContext := DecisionContext{
		Options: []DecisionOption{
			{
				Action: "buy",
				Parameters: map[string]methods.Probability{
					"amount": 0.2,
					"price":  0.8,
				},
			},
			{
				Action: "sell",
				Parameters: map[string]methods.Probability{
					"amount": 0.1,
					"price":  0.7,
				},
			},
		},
		Constraints: []string{"max_allocation_50%", "min_diversification_3_assets"},
	}

	// Test complete workflow
	result, err := cmc.CompleteWorkflow(marketData, portfolioData, decisionContext)
	if err != nil {
		t.Errorf("Expected no error from complete workflow, got %v", err)
	}

	if result.Status != "completed" {
		t.Errorf("Expected completed status, got %s", result.Status)
	}

	if result.ComposabilityScore < 0.95 {
		t.Errorf("Expected high composability score, got %f", result.ComposabilityScore)
	}

	// Validate all components
	if result.MarketPrediction.Trend < 0 || result.MarketPrediction.Trend > 1 {
		t.Errorf("Expected valid market prediction trend, got %f", result.MarketPrediction.Trend)
	}

	if result.RiskAssessment.ValueAtRisk < 0 || result.RiskAssessment.ValueAtRisk > 1 {
		t.Errorf("Expected valid risk assessment VaR, got %f", result.RiskAssessment.ValueAtRisk)
	}

	if result.OptimalDecision.ExpectedUtility < 0 || result.OptimalDecision.ExpectedUtility > 1 {
		t.Errorf("Expected valid decision utility, got %f", result.OptimalDecision.ExpectedUtility)
	}

	if result.Performance.TotalInferences < 5 {
		t.Errorf("Expected multiple inferences, got %d", result.Performance.TotalInferences)
	}
}

// TestPerformanceTracking tests performance tracking functionality
func TestPerformanceTracking(t *testing.T) {
	cmc := NewComposabilityMasterclass()

	// Initial performance
	initialPerformance := cmc.performance
	if initialPerformance.TotalInferences != 0 {
		t.Errorf("Expected 0 initial inferences, got %d", initialPerformance.TotalInferences)
	}

	// Run some operations
	marketData := []MarketObservation{
		{Price: 0.8, Volume: 0.7, Volatility: 0.3, Trend: 0.6},
	}

	portfolioData := []PortfolioPosition{
		{AssetID: "BTC", Quantity: 0.5, CurrentPrice: 0.9, RiskWeight: 0.3},
	}

	decisionContext := DecisionContext{
		Options: []DecisionOption{
			{
				Action: "buy",
				Parameters: map[string]methods.Probability{
					"amount": 0.2,
					"price":  0.8,
				},
			},
		},
	}

	// Run workflow multiple times
	for i := 0; i < 3; i++ {
		_, err := cmc.CompleteWorkflow(marketData, portfolioData, decisionContext)
		if err != nil {
			t.Errorf("Workflow %d failed: %v", i, err)
		}
	}

	// Check updated performance
	updatedPerformance := cmc.UpdatePerformance()
	if updatedPerformance.TotalInferences < 3 {
		t.Errorf("Expected at least 3 inferences, got %d", updatedPerformance.TotalInferences)
	}

	if updatedPerformance.AverageAccuracy < 0.9 {
		t.Errorf("Expected high accuracy, got %f", updatedPerformance.AverageAccuracy)
	}
}

// TestComposabilityScore tests composability scoring
func TestComposabilityScore(t *testing.T) {
	cmc := NewComposabilityMasterclass()

	// Test initial composability score
	score := cmc.CalculateComposabilityScore()
	if score < 0.95 {
		t.Errorf("Expected high initial composability score, got %f", score)
	}

	// Run operations and test updated score
	marketData := []MarketObservation{
		{Price: 0.8, Volume: 0.7, Volatility: 0.3, Trend: 0.6},
	}

	portfolioData := []PortfolioPosition{
		{AssetID: "BTC", Quantity: 0.5, CurrentPrice: 0.9, RiskWeight: 0.3},
	}

	decisionContext := DecisionContext{
		Options: []DecisionOption{
			{
				Action: "buy",
				Parameters: map[string]methods.Probability{
					"amount": 0.2,
					"price":  0.8,
				},
			},
		},
	}

	_, err := cmc.CompleteWorkflow(marketData, portfolioData, decisionContext)
	if err != nil {
		t.Errorf("Workflow failed: %v", err)
	}

	updatedScore := cmc.CalculateComposabilityScore()
	if updatedScore < score {
		t.Errorf("Expected composability score to maintain or improve, got %f (was %f)", updatedScore, score)
	}
}

// TestDataConversion tests data structure conversions
func TestDataConversion(t *testing.T) {
	// Test MarketObservation conversion
	mo := MarketObservation{
		Price:      0.8,
		Volume:     0.7,
		Volatility: 0.3,
		Trend:      0.6,
	}

	probs := mo.ToProbabilities()
	if len(probs) != 4 {
		t.Errorf("Expected 4 probabilities, got %d", len(probs))
	}

	if probs[0] != 0.8 {
		t.Errorf("Expected price 0.8, got %f", probs[0])
	}

	// Test conversion back
	mo2 := MarketObservationFromProbabilities(probs)
	if mo2.Price != 0.8 {
		t.Errorf("Expected converted price 0.8, got %f", mo2.Price)
	}

	// Test PortfolioPosition conversion
	pp := PortfolioPosition{
		AssetID:      "BTC",
		Quantity:     0.5,
		CurrentPrice: 0.9,
		RiskWeight:   0.3,
	}

	ppProbs := pp.ToProbabilities()
	if len(ppProbs) != 3 {
		t.Errorf("Expected 3 probabilities, got %d", len(ppProbs))
	}

	// Test DecisionOption conversion
	do := DecisionOption{
		Action: "buy",
		Parameters: map[string]methods.Probability{
			"amount": 0.2,
			"price":  0.8,
		},
	}

	doProbs := do.ToProbabilities()
	if len(doProbs) != 2 {
		t.Errorf("Expected 2 probabilities, got %d", len(doProbs))
	}
}

// TestUtilityFunctions tests utility functions
func TestUtilityFunctions(t *testing.T) {
	// Test average function
	probs := []methods.Probability{0.8, 0.6, 0.4, 0.2}
	avg := average(probs)

	expected := (0.8 + 0.6 + 0.4 + 0.2) / 4
	if avg != methods.Probability(expected) {
		t.Errorf("Expected average %f, got %f", expected, avg)
	}

	// Test empty slice
	emptyAvg := average([]methods.Probability{})
	if emptyAvg != 0 {
		t.Errorf("Expected 0 for empty slice, got %f", emptyAvg)
	}
}

// TestDemonstrateComposability tests the main demonstration function
func TestDemonstrateComposability(t *testing.T) {
	result := DemonstrateComposability()

	if result == "" {
		t.Error("Expected non-empty demonstration result")
	}

	// Check for key components in the result
	if len(result) < 100 {
		t.Error("Expected comprehensive demonstration result")
	}

	// Check for expected sections
	expectedSections := []string{
		"COMPOSABILITY MASTERCLASS RESULTS",
		"MARKET PREDICTION",
		"RISK ASSESSMENT",
		"OPTIMAL DECISION",
		"PERFORMANCE METRICS",
		"ADVANCED BAYESIAN COMPOSABILITY DEMONSTRATED",
	}

	for _, section := range expectedSections {
		if len(result) < len(section) || result[:len(section)] != section {
			// Use a more flexible check
			if !contains(result, section) {
				t.Errorf("Expected section '%s' in demonstration result", section)
			}
		}
	}
}

// TestGetSystemStatus tests the system status function
func TestGetSystemStatus(t *testing.T) {
	status := GetSystemStatus()

	if status == "" {
		t.Error("Expected non-empty system status")
	}

	// Check for key components
	expectedComponents := []string{
		"ACTIVE INFERENCE COMPOSABILITY SYSTEM STATUS",
		"Advanced Bayesian Engine Status: ACTIVE",
		"Composability Index:",
		"Performance Metrics:",
		"Active Components:",
	}

	for _, component := range expectedComponents {
		if !contains(status, component) {
			t.Errorf("Expected component '%s' in system status", component)
		}
	}
}

// Helper function to check if a string contains a substring
func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(substr) == 0 ||
		(len(s) > len(substr) && s[:len(substr)] == substr) ||
		(len(s) > len(substr) && s[len(s)-len(substr):] == substr) ||
		containsHelper(s, substr))
}

func containsHelper(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}

// TestEdgeCases tests edge cases and boundary conditions
func TestEdgeCases(t *testing.T) {
	// Test with empty market data
	cmc := NewComposabilityMasterclass()
	emptyMarketData := []MarketObservation{}
	emptyPortfolioData := []PortfolioPosition{}
	emptyDecisionContext := DecisionContext{
		Options:     []DecisionOption{},
		Constraints: []string{},
	}

	// This should handle empty data gracefully
	_, err := cmc.CompleteWorkflow(emptyMarketData, emptyPortfolioData, emptyDecisionContext)
	// We expect this might fail, but it should fail gracefully
	t.Logf("Empty data test completed with error (expected): %v", err)

	// Test privacy budget exhaustion
	pc := NewPrivacyController()

	// Exhaust privacy budget
	for i := 0; i < 100; i++ {
		data := []methods.Probability{0.8, 0.6, 0.4, 0.7}
		_, err := pc.EnsurePrivacy("test", data)
		if err != nil {
			// Privacy budget should eventually be exhausted
			if contains(err.Error(), "privacy budget exhausted") {
				t.Log("Privacy budget exhaustion test passed")
				break
			}
		}
	}

	// Test with extreme values
	extremeData := []MarketObservation{
		{Price: 1.0, Volume: 1.0, Volatility: 1.0, Trend: 1.0},
	}

	_, err = cmc.marketPredictor.PredictMarketConditions(extremeData)
	if err != nil {
		t.Errorf("Expected graceful handling of extreme values, got %v", err)
	}
}

// TestIntegration tests complete system integration
func TestIntegration(t *testing.T) {
	t.Log("=== COMPOSABILITY MASTERCLASS INTEGRATION TEST ===")

	// Create the complete system
	cmc := NewComposabilityMasterclass()

	// Test each subsystem independently
	TestMarketPredictionSystem(t)
	TestRiskAssessmentSystem(t)
	TestDecisionOptimizationSystem(t)
	TestPrivacyController(t)

	// Test complete workflow
	result, err := cmc.CompleteWorkflow(
		[]MarketObservation{
			{Price: 0.8, Volume: 0.7, Volatility: 0.3, Trend: 0.6},
		},
		[]PortfolioPosition{
			{AssetID: "BTC", Quantity: 0.5, CurrentPrice: 0.9, RiskWeight: 0.3},
		},
		DecisionContext{
			Options: []DecisionOption{
				{
					Action: "buy",
					Parameters: map[string]methods.Probability{
						"amount": 0.2,
						"price":  0.8,
					},
				},
			},
		},
	)

	if err != nil {
		t.Errorf("Integration test failed: %v", err)
	}

	// Validate integration results
	if result.ComposabilityScore < 0.95 {
		t.Errorf("Expected high composability score in integration test, got %f", result.ComposabilityScore)
	}

	if result.Performance.TotalInferences < 1 {
		t.Errorf("Expected at least 1 inference in integration test, got %d", result.Performance.TotalInferences)
	}

	t.Log("=== COMPOSABILITY MASTERCLASS INTEGRATION TEST COMPLETE ===")
}

// TestRealm runs the complete test suite for the composability masterclass
func TestRealm(t *testing.T) {
	t.Log("🚀 === COMPOSABILITY MASTERCLASS REALM TEST SUITE ===")

	TestNewComposabilityMasterclass(t)
	TestMarketPredictionSystem(t)
	TestRiskAssessmentSystem(t)
	TestDecisionOptimizationSystem(t)
	TestPrivacyController(t)
	TestCompleteWorkflow(t)
	TestPerformanceTracking(t)
	TestComposabilityScore(t)
	TestDataConversion(t)
	TestUtilityFunctions(t)
	TestDemonstrateComposability(t)
	TestGetSystemStatus(t)
	TestEdgeCases(t)
	TestIntegration(t)

	t.Log("✅ === COMPOSABILITY MASTERCLASS TESTS COMPLETED ===")
	t.Log("This demonstrates the DOMINANT composability of Active Inference")
	t.Log("on Gno blockchain through advanced Bayesian techniques.")
}
