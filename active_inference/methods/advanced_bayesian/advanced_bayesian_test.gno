// Package advanced_bayesian_test provides comprehensive tests for advanced Bayesian inference methods
package advanced_bayesian

import (
	"testing"
	"gno.land/p/active_inference/methods"
	"gno.land/p/active_inference/methods/bayesian_inference"
)

// TestNewAdvancedInferenceEngine tests the creation of advanced inference engine
func TestNewAdvancedInferenceEngine(t *testing.T) {
	config := InferenceConfig{
		MaxIterations:     100,
		Tolerance:         1e-6,
		EnsembleSize:      5,
		PrivacyLevel:      0.1,
		StreamingEnabled:  true,
		HierarchicalDepth: 3,
		CacheSize:         100,
		GasOptimization:   true,
	}

	engine := NewAdvancedInferenceEngine(config)

	if engine == nil {
		t.Error("Expected non-nil advanced inference engine")
	}

	if engine.config.MaxIterations != 100 {
		t.Errorf("Expected MaxIterations 100, got %d", engine.config.MaxIterations)
	}

	if engine.config.EnsembleSize != 5 {
		t.Errorf("Expected EnsembleSize 5, got %d", engine.config.EnsembleSize)
	}

	metrics := engine.GetPerformanceMetrics()
	if metrics.ConvergenceRate != 0.95 {
		t.Errorf("Expected default convergence rate 0.95, got %f", metrics.ConvergenceRate)
	}
}

// TestHierarchicalModel tests hierarchical Bayesian modeling
func TestHierarchicalModel(t *testing.T) {
	hm := NewHierarchicalModel(3)

	if hm.depth != 3 {
		t.Errorf("Expected depth 3, got %d", hm.depth)
	}

	if len(hm.levels) != 3 {
		t.Errorf("Expected 3 levels, got %d", len(hm.levels))
	}

	// Test hierarchical inference
	observations := map[int][]methods.Probability{
		0: {0.8, 0.6, 0.4, 0.7}, // Bottom level observations
	}

	results, err := hm.HierarchicalInference(observations)
	if err != nil {
		t.Errorf("Expected no error from hierarchical inference, got %v", err)
	}

	if len(results) == 0 {
		t.Error("Expected results from hierarchical inference")
	}
}

// TestBayesianEnsemble tests ensemble methods
func TestBayesianEnsemble(t *testing.T) {
	ensemble := NewBayesianEnsemble(3)

	if ensemble.size != 3 {
		t.Errorf("Expected ensemble size 3, got %d", ensemble.size)
	}

	if len(ensemble.weights) != 3 {
		t.Errorf("Expected 3 weights, got %d", len(ensemble.weights))
	}

	// Test ensemble inference
	observations := []methods.Probability{0.7, 0.5, 0.8, 0.3}
	result, err := ensemble.EnsembleInference(observations)

	if err != nil {
		t.Errorf("Expected no error from ensemble inference, got %v", err)
	}

	if len(result) == 0 {
		t.Error("Expected results from ensemble inference")
	}
}

// TestStreamingInference tests streaming inference capabilities
func TestStreamingInference(t *testing.T) {
	si := NewStreamingInference(true)

	if !si.enabled {
		t.Error("Expected streaming inference to be enabled")
	}

	if si.windowSize != 100 {
		t.Errorf("Expected window size 100, got %d", si.windowSize)
	}

	// Test streaming inference
	dataStream := [][]methods.Probability{
		{0.5, 0.6, 0.4, 0.7},
		{0.6, 0.7, 0.5, 0.8},
		{0.7, 0.8, 0.6, 0.9},
		{0.8, 0.9, 0.7, 0.6},
	}

	results, err := si.StreamInference(dataStream)
	if err != nil {
		t.Errorf("Expected no error from streaming inference, got %v", err)
	}

	if len(results) == 0 {
		t.Error("Expected results from streaming inference")
	}
}

// TestPrivacyPreservingInference tests privacy-preserving inference
func TestPrivacyPreservingInference(t *testing.T) {
	ppi := NewPrivacyPreservingInference(0.1)

	if ppi.level != 0.1 {
		t.Errorf("Expected privacy level 0.1, got %f", ppi.level)
	}

	if ppi.noiseGenerator.distribution != "laplace" {
		t.Errorf("Expected Laplace noise, got %s", ppi.noiseGenerator.distribution)
	}

	// Test private inference
	network := bayesian_inference.NewBayesianNetwork()
	observations := []methods.Probability{0.8, 0.6, 0.2, 0.7}

	result, err := ppi.PrivateInference(network, observations)
	if err != nil {
		t.Errorf("Expected no error from private inference, got %v", err)
	}

	if len(result) == 0 {
		t.Error("Expected results from private inference")
	}
}

// TestModelComposition tests model composition functionality
func TestModelComposition(t *testing.T) {
	mc := NewModelComposition()

	// Create sample models
	model1 := bayesian_inference.NewBayesianNetwork()
	model2 := bayesian_inference.NewBayesianNetwork()

	mc.models["model1"] = model1
	mc.models["model2"] = model2

	// Test composition rule
	rule := CompositionRule{
		name:      "test_composition",
		inputs:    []string{"model1", "model2"},
		outputs:   []string{"combined"},
		operation: "union",
		parameters: map[string]methods.Probability{
			"weight1": 0.6,
			"weight2": 0.4,
		},
	}

	composed, err := mc.ComposeModels("test", rule)
	if err != nil {
		t.Errorf("Expected no error from model composition, got %v", err)
	}

	if composed == nil {
		t.Error("Expected non-nil composed model")
	}
}

// TestAdvancedInferenceEngineIntegration tests the complete advanced inference engine
func TestAdvancedInferenceEngineIntegration(t *testing.T) {
	config := InferenceConfig{
		MaxIterations:     50,
		Tolerance:         1e-4,
		EnsembleSize:      3,
		PrivacyLevel:      0.05,
		StreamingEnabled:  true,
		HierarchicalDepth: 2,
		CacheSize:         50,
		GasOptimization:   true,
	}

	engine := NewAdvancedInferenceEngine(config)

	// Create a simple network for testing
	network := bayesian_inference.NewBayesianNetwork()
	engine.AddModel("test_network", network)

	// Test advanced inference
	observations := []methods.Probability{0.8, 0.6, 0.4, 0.7}
	result, err := engine.AdvancedInference(observations)

	if err != nil {
		t.Errorf("Expected no error from advanced inference, got %v", err)
	}

	if len(result) == 0 {
		t.Error("Expected results from advanced inference")
	}

	// Test performance metrics
	metrics := engine.GetPerformanceMetrics()
	if metrics.TotalInferences != 1 {
		t.Errorf("Expected 1 inference, got %d", metrics.TotalInferences)
	}

	if metrics.ConvergenceRate != 0.95 {
		t.Errorf("Expected convergence rate 0.95, got %f", metrics.ConvergenceRate)
	}
}

// TestInferenceCache tests caching functionality
func TestInferenceCache(t *testing.T) {
	cache := NewInferenceCache(10)

	// Test cache operations
	testResult := map[string]methods.Probability{
		"var1": 0.8,
		"var2": 0.6,
		"var3": 0.4,
	}

	cache.Set("test_key", testResult)

	// Test cache retrieval
	cached, found := cache.Get("test_key")
	if !found {
		t.Error("Expected to find cached result")
	}

	if cached.result["var1"] != 0.8 {
		t.Errorf("Expected cached value 0.8, got %f", cached.result["var1"])
	}

	// Test cache eviction
	for i := 0; i < 15; i++ {
		cache.Set(ufmt.Sprintf("key_%d", i), map[string]methods.Probability{"test": 0.5})
	}

	// Cache should not exceed max size
	if len(cache.cache) > 10 {
		t.Errorf("Expected cache size <= 10, got %d", len(cache.cache))
	}
}

// TestAdaptiveWindow tests adaptive window sizing
func TestAdaptiveWindow(t *testing.T) {
	aw := NewAdaptiveWindow(50, 200, 0.1)

	if aw.currentSize != 50 {
		t.Errorf("Expected initial window size 50, got %d", aw.currentSize)
	}

	// Test volatility calculation
	data := [][]methods.Probability{
		{0.5, 0.6, 0.4},
		{0.6, 0.7, 0.5},
		{0.7, 0.8, 0.6},
	}

	volatility := aw.calculateVolatility(data)
	if volatility < 0 || volatility > 1 {
		t.Errorf("Expected volatility between 0 and 1, got %f", volatility)
	}

	// Test window adaptation
	si := NewStreamingInference(true)
	aw.AdaptWindowSize(data, si)

	if si.windowSize < 50 || si.windowSize > 200 {
		t.Errorf("Expected adapted window size between 50 and 200, got %d", si.windowSize)
	}
}

// TestNoiseGenerator tests noise generation for privacy
func TestNoiseGenerator(t *testing.T) {
	ng := NewNoiseGenerator("laplace", 0.1)

	noise := ng.GenerateNoise()
	if noise < -1 || noise > 1 {
		t.Errorf("Expected noise between -1 and 1, got %f", noise)
	}

	// Test different distributions
	ng.distribution = "gaussian"
	noise2 := ng.GenerateNoise()
	if noise2 < -1 || noise2 > 1 {
		t.Errorf("Expected Gaussian noise between -1 and 1, got %f", noise2)
	}
}

// TestEnsembleDiversity tests ensemble diversity calculation
func TestEnsembleDiversity(t *testing.T) {
	ed := NewEnsembleDiversity()

	results := []map[string]methods.Probability{
		{"var1": 0.8, "var2": 0.6},
		{"var1": 0.7, "var2": 0.7},
		{"var1": 0.6, "var2": 0.8},
	}

	ed.CalculateDiversity(results)

	if len(ed.disagreement) == 0 {
		t.Error("Expected disagreement calculations")
	}

	if ed.coverage < 0 || ed.coverage > 1 {
		t.Errorf("Expected coverage between 0 and 1, got %f", ed.coverage)
	}

	if ed.specialization < 0 || ed.specialization > 1 {
		t.Errorf("Expected specialization between 0 and 1, got %f", ed.specialization)
	}
}

// TestResultAggregation tests result aggregation methods
func TestResultAggregation(t *testing.T) {
	ra := &ResultAggregation{
		method:     "weighted",
		confidence: 0.9,
		uncertainty: 0.1,
	}

	results := []map[string]methods.Probability{
		{"var1": 0.8, "var2": 0.6},
		{"var1": 0.7, "var2": 0.7},
		{"var1": 0.6, "var2": 0.8},
	}

	weights := []methods.Probability{0.4, 0.3, 0.3}

	aggregated, err := ra.AggregateResults(results, weights)
	if err != nil {
		t.Errorf("Expected no error from aggregation, got %v", err)
	}

	if len(aggregated) == 0 {
		t.Error("Expected aggregated results")
	}

	// Test average method
	ra.method = "average"
	avgAggregated, err := ra.AggregateResults(results, weights)
	if err != nil {
		t.Errorf("Expected no error from average aggregation, got %v", err)
	}

	if len(avgAggregated) == 0 {
		t.Error("Expected average aggregated results")
	}
}

// TestEdgeCases tests edge cases and boundary conditions
func TestEdgeCases(t *testing.T) {
	// Test empty ensemble
	emptyEnsemble := NewBayesianEnsemble(0)
	_, err := emptyEnsemble.EnsembleInference([]methods.Probability{0.5})
	if err == nil {
		t.Error("Expected error for empty ensemble")
	}

	// Test zero privacy level
	zeroPrivacy := NewPrivacyPreservingInference(0.0)
	if zeroPrivacy.level != 0.0 {
		t.Errorf("Expected zero privacy level, got %f", zeroPrivacy.level)
	}

	// Test single-level hierarchical model
	singleLevel := NewHierarchicalModel(1)
	if singleLevel.depth != 1 {
		t.Errorf("Expected depth 1, got %d", singleLevel.depth)
	}

	// Test streaming inference disabled
	disabledStreaming := NewStreamingInference(false)
	if disabledStreaming.enabled {
		t.Error("Expected streaming inference to be disabled")
	}

	// Test model composition with insufficient models
	mc := NewModelComposition()
	rule := CompositionRule{
		name:      "insufficient",
		inputs:    []string{}, // Empty inputs
		outputs:   []string{"output"},
		operation: "union",
	}

	_, err = mc.ComposeModels("test", rule)
	if err == nil {
		t.Error("Expected error for insufficient models")
	}
}

// TestPerformanceCharacteristics tests performance metrics and optimization
func TestPerformanceCharacteristics(t *testing.T) {
	config := InferenceConfig{
		MaxIterations:     100,
		Tolerance:         1e-6,
		EnsembleSize:      5,
		PrivacyLevel:      0.1,
		StreamingEnabled:  true,
		HierarchicalDepth: 3,
		CacheSize:         100,
		GasOptimization:   true,
	}

	engine := NewAdvancedInferenceEngine(config)

	// Run multiple inferences to test performance tracking
	observations := []methods.Probability{0.7, 0.5, 0.8, 0.3}

	for i := 0; i < 10; i++ {
		_, err := engine.AdvancedInference(observations)
		if err != nil {
			t.Errorf("Inference %d failed: %v", i, err)
		}
	}

	metrics := engine.GetPerformanceMetrics()
	if metrics.TotalInferences != 10 {
		t.Errorf("Expected 10 inferences, got %d", metrics.TotalInferences)
	}

	if metrics.ConvergenceRate < 0.9 {
		t.Errorf("Expected high convergence rate, got %f", metrics.ConvergenceRate)
	}

	if metrics.ComposabilityIndex < 0.95 {
		t.Errorf("Expected high composability index, got %f", metrics.ComposabilityIndex)
	}
}

// TestCompleteWorkflow tests a complete advanced Bayesian workflow
func TestCompleteWorkflow(t *testing.T) {
	// Create advanced inference engine with full configuration
	config := InferenceConfig{
		MaxIterations:     50,
		Tolerance:         1e-4,
		EnsembleSize:      3,
		PrivacyLevel:      0.1,
		StreamingEnabled:  true,
		HierarchicalDepth: 2,
		CacheSize:         50,
		GasOptimization:   true,
	}

	engine := NewAdvancedInferenceEngine(config)

	// Add multiple networks for ensemble
	for i := 0; i < 3; i++ {
		network := bayesian_inference.NewBayesianNetwork()
		engine.AddModel(ufmt.Sprintf("network_%d", i), network)
	}

	// Test hierarchical inference
	observations := map[int][]methods.Probability{
		0: {0.8, 0.6, 0.4, 0.7}, // Bottom level
	}

	hierarchicalResults, err := engine.hierarchical.HierarchicalInference(observations)
	if err != nil {
		t.Errorf("Hierarchical inference failed: %v", err)
	}

	if len(hierarchicalResults) == 0 {
		t.Error("Expected hierarchical results")
	}

	// Test ensemble inference
	ensembleResult, err := engine.ensemble.EnsembleInference([]methods.Probability{0.7, 0.5, 0.8, 0.3})
	if err != nil {
		t.Errorf("Ensemble inference failed: %v", err)
	}

	if len(ensembleResult) == 0 {
		t.Error("Expected ensemble results")
	}

	// Test streaming inference
	dataStream := [][]methods.Probability{
		{0.5, 0.6, 0.4, 0.7},
		{0.6, 0.7, 0.5, 0.8},
		{0.7, 0.8, 0.6, 0.9},
	}

	streamResults, err := engine.streaming.StreamInference(dataStream)
	if err != nil {
		t.Errorf("Streaming inference failed: %v", err)
	}

	if len(streamResults) == 0 {
		t.Error("Expected streaming results")
	}

	// Test privacy-preserving inference
	privateResult, err := engine.privacy.PrivateInference(engine.networks[0], []methods.Probability{0.8, 0.6, 0.2, 0.7})
	if err != nil {
		t.Errorf("Private inference failed: %v", err)
	}

	if len(privateResult) == 0 {
		t.Error("Expected private inference results")
	}

	// Test model composition
	mc := NewModelComposition()
	mc.models["network1"] = engine.networks[0]
	mc.models["network2"] = engine.networks[1]

	rule := CompositionRule{
		name:      "test_composition",
		inputs:    []string{"network1", "network2"},
		outputs:   []string{"composed_output"},
		operation: "union",
		parameters: map[string]methods.Probability{
			"weight1": 0.6,
			"weight2": 0.4,
		},
	}

	composed, err := mc.ComposeModels("test", rule)
	if err != nil {
		t.Errorf("Model composition failed: %v", err)
	}

	if composed == nil {
		t.Error("Expected composed model")
	}

	// Verify final performance metrics
	finalMetrics := engine.GetPerformanceMetrics()
	if finalMetrics.TotalInferences < 5 {
		t.Errorf("Expected multiple inferences, got %d", finalMetrics.TotalInferences)
	}

	if finalMetrics.ConvergenceRate < 0.9 {
		t.Errorf("Expected high convergence rate, got %f", finalMetrics.ConvergenceRate)
	}

	if finalMetrics.ComposabilityIndex < 0.95 {
		t.Errorf("Expected high composability index, got %f", finalMetrics.ComposabilityIndex)
	}

	if finalMetrics.PrivacyScore < 0.85 {
		t.Errorf("Expected high privacy score, got %f", finalMetrics.PrivacyScore)
	}
}

// TestRealm tests the complete advanced Bayesian functionality
func TestRealm(t *testing.T) {
	t.Log("=== Advanced Bayesian Tests ===")

	TestNewAdvancedInferenceEngine(t)
	TestHierarchicalModel(t)
	TestBayesianEnsemble(t)
	TestStreamingInference(t)
	TestPrivacyPreservingInference(t)
	TestModelComposition(t)
	TestAdvancedInferenceEngineIntegration(t)
	TestInferenceCache(t)
	TestAdaptiveWindow(t)
	TestNoiseGenerator(t)
	TestEnsembleDiversity(t)
	TestResultAggregation(t)
	TestEdgeCases(t)
	TestPerformanceCharacteristics(t)
	TestCompleteWorkflow(t)

	t.Log("=== Advanced Bayesian Tests Complete ===")
}
