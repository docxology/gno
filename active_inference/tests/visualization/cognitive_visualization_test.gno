// Package cognitive_visualization_test provides comprehensive tests for cognitive visualization methods
package cognitive_visualization

import (
	"testing"
	"gno.land/p/active_inference/methods"
)

// TestNewProbabilityDistributionVisualizer tests creation of probability distribution visualizer
func TestNewProbabilityDistributionVisualizer(t *testing.T) {
	visualizer := NewProbabilityDistributionVisualizer()

	if visualizer == nil {
		t.Error("Expected non-nil probability distribution visualizer")
	}
}

// TestVisualizeCategorical tests categorical distribution visualization
func TestVisualizeCategorical(t *testing.T) {
	visualizer := NewProbabilityDistributionVisualizer()

	probs := []methods.Probability{0.2, 0.3, 0.5}
	labels := []string{"A", "B", "C"}

	result := visualizer.VisualizeCategorical(probs, labels)

	if len(result) == 0 {
		t.Error("Expected non-empty visualization result")
	}

	// Check that all labels appear in the result
	for _, label := range labels {
		found := false
		for _, line := range result {
			if len(line) > len(label) && line[:len(label)] == label {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Expected to find label '%s' in visualization", label)
		}
	}
}

// TestVisualizeDistribution tests general distribution visualization
func TestVisualizeDistribution(t *testing.T) {
	visualizer := NewProbabilityDistributionVisualizer()

	// Test with different probability distributions
	distributions := [][]methods.Probability{
		{0.1, 0.9},           // Binary
		{0.2, 0.3, 0.5},     // Ternary
		{0.1, 0.2, 0.3, 0.4}, // Quaternary
	}

	for i, dist := range distributions {
		result := visualizer.VisualizeDistribution(dist, ufmt.Sprintf("Test%d", i))

		if len(result) == 0 {
			t.Errorf("Expected non-empty visualization for distribution %d", i)
		}

		// Check that title appears
		found := false
		for _, line := range result {
			if len(line) >= len("Test") && line[:4] == "Test" {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Expected to find title in visualization for distribution %d", i)
		}
	}
}

// TestNewCognitiveModelVisualizer tests creation of cognitive model visualizer
func TestNewCognitiveModelVisualizer(t *testing.T) {
	visualizer := NewCognitiveModelVisualizer()

	if visualizer == nil {
		t.Error("Expected non-nil cognitive model visualizer")
	}
}

// TestNewNetworkVisualizer tests creation of network visualizer
func TestNewNetworkVisualizer(t *testing.T) {
	visualizer := NewNetworkVisualizer()

	if visualizer == nil {
		t.Error("Expected non-nil network visualizer")
	}
}

// TestVisualizeBeliefs tests belief state visualization
func TestVisualizeBeliefs(t *testing.T) {
	visualizer := NewCognitiveModelVisualizer()

	beliefs := []methods.Probability{0.8, 0.6, 0.4, 0.2}
	labels := []string{"Goal1", "Goal2", "Goal3", "Goal4"}

	result := visualizer.VisualizeBeliefs(beliefs, labels)

	if len(result) == 0 {
		t.Error("Expected non-empty belief visualization")
	}

	// Check that belief values appear in visualization
	for _, belief := range beliefs {
		found := false
		for _, line := range result {
			if len(line) >= 3 && line[:3] == ufmt.Sprintf("%.1f", belief) {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Expected to find belief value %.1f in visualization", belief)
		}
	}
}

// TestVisualizeAttention tests attention visualization
func TestVisualizeAttention(t *testing.T) {
	visualizer := NewCognitiveModelVisualizer()

	attentionWeights := []methods.Probability{0.9, 0.1, 0.8, 0.2}
	features := []string{"Color", "Shape", "Size", "Motion"}

	result := visualizer.VisualizeAttention(attentionWeights, features)

	if len(result) == 0 {
		t.Error("Expected non-empty attention visualization")
	}

	// Check that features appear in visualization
	for _, feature := range features {
		found := false
		for _, line := range result {
			if len(line) >= len(feature) && line[:len(feature)] == feature {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Expected to find feature '%s' in attention visualization", feature)
		}
	}
}

// TestVisualizeNetwork tests network structure visualization
func TestVisualizeNetwork(t *testing.T) {
	visualizer := NewNetworkVisualizer()

	// Simple network: A -> B -> C
	nodes := []string{"A", "B", "C"}
	edges := map[string][]string{
		"A": {"B"},
		"B": {"C"},
		"C": {},
	}

	result := visualizer.VisualizeNetwork(nodes, edges)

	if len(result) == 0 {
		t.Error("Expected non-empty network visualization")
	}

	// Check that nodes appear in visualization
	for _, node := range nodes {
		found := false
		for _, line := range result {
			if len(line) >= len(node) && line[:len(node)] == node {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Expected to find node '%s' in network visualization", node)
		}
	}
}

// TestVisualizeTimeSeries tests time series visualization
func TestVisualizeTimeSeries(t *testing.T) {
	visualizer := NewCognitiveModelVisualizer()

	// Time series data
	values := []methods.Probability{0.1, 0.3, 0.7, 0.9, 0.6, 0.4, 0.2, 0.8}
	labels := []string{"t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7"}

	result := visualizer.VisualizeTimeSeries(values, labels, "Test Series")

	if len(result) == 0 {
		t.Error("Expected non-empty time series visualization")
	}

	// Check that series title appears
	found := false
	for _, line := range result {
		if len(line) >= len("Test Series") && line[:10] == "Test Series" {
			found = true
			break
		}
	}
	if !found {
		t.Error("Expected to find series title in time series visualization")
	}
}

// TestVisualizeProbabilitySurface tests probability surface visualization
func TestVisualizeProbabilitySurface(t *testing.T) {
	visualizer := NewProbabilityDistributionVisualizer()

	// 2D probability surface
	surface := [][]methods.Probability{
		{0.1, 0.2, 0.3},
		{0.4, 0.5, 0.6},
		{0.7, 0.8, 0.9},
	}

	result := visualizer.VisualizeProbabilitySurface(surface, "Test Surface")

	if len(result) == 0 {
		t.Error("Expected non-empty probability surface visualization")
	}

	// Check that surface title appears
	found := false
	for _, line := range result {
		if len(line) >= len("Test Surface") && line[:12] == "Test Surface" {
			found = true
			break
		}
	}
	if !found {
		t.Error("Expected to find surface title in probability surface visualization")
	}
}

// TestVisualizeBayesianNetwork tests Bayesian network visualization
func TestVisualizeBayesianNetwork(t *testing.T) {
	visualizer := NewNetworkVisualizer()

	// Simple Bayesian network structure
	nodes := []string{"Flu", "Fever", "Cough", "Cold"}
	edges := map[string][]string{
		"Flu":     {"Fever", "Cough", "Cold"},
		"Fever":   {},
		"Cough":   {},
		"Cold":    {},
	}

	result := visualizer.VisualizeBayesianNetwork(nodes, edges)

	if len(result) == 0 {
		t.Error("Expected non-empty Bayesian network visualization")
	}

	// Check that all nodes appear
	for _, node := range nodes {
		found := false
		for _, line := range result {
			if len(line) >= len(node) && line[:len(node)] == node {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Expected to find node '%s' in Bayesian network visualization", node)
		}
	}
}

// TestVisualizeCognitiveState tests complete cognitive state visualization
func TestVisualizeCognitiveState(t *testing.T) {
	visualizer := NewCognitiveModelVisualizer()

	// Complete cognitive state
	beliefs := []methods.Probability{0.8, 0.6, 0.4, 0.7}
	attention := []methods.Probability{0.9, 0.1, 0.8, 0.2}
	goals := []methods.Probability{1.0, 0.0, 0.5, 0.8}

	labels := []string{"Feature1", "Feature2", "Feature3", "Feature4"}

	result := visualizer.VisualizeCognitiveState(beliefs, attention, goals, labels)

	if len(result) == 0 {
		t.Error("Expected non-empty cognitive state visualization")
	}

	// Should contain multiple sections
	sectionCount := 0
	for _, line := range result {
		if len(line) > 0 && line[0] == '=' {
			sectionCount++
		}
	}

	if sectionCount < 2 {
		t.Error("Expected multiple sections in cognitive state visualization")
	}
}

// TestVisualizeDecisionProcess tests decision process visualization
func TestVisualizeDecisionProcess(t *testing.T) {
	visualizer := NewCognitiveModelVisualizer()

	// Decision options and their utilities
	options := []string{"Option A", "Option B", "Option C"}
	utilities := []methods.Probability{0.8, 0.6, 0.4}
	confidences := []methods.Probability{0.9, 0.8, 0.7}

	result := visualizer.VisualizeDecisionProcess(options, utilities, confidences)

	if len(result) == 0 {
		t.Error("Expected non-empty decision process visualization")
	}

	// Check that options appear
	for _, option := range options {
		found := false
		for _, line := range result {
			if len(line) >= len(option) && line[:len(option)] == option {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Expected to find option '%s' in decision process visualization", option)
		}
	}
}

// TestVisualizeActiveInferenceAgent tests active inference agent visualization
func TestVisualizeActiveInferenceAgent(t *testing.T) {
	visualizer := NewCognitiveModelVisualizer()

	// Mock active inference agent data
	agentBeliefs := []methods.Probability{0.7, 0.3, 0.8, 0.2}
	freeEnergy := methods.Probability(0.15)
	policies := [][]methods.Probability{
		{0.9, 0.1, 0.8, 0.2},
		{0.6, 0.4, 0.5, 0.5},
		{0.3, 0.7, 0.2, 0.8},
	}

	result := visualizer.VisualizeActiveInferenceAgent(agentBeliefs, freeEnergy, policies)

	if len(result) == 0 {
		t.Error("Expected non-empty active inference agent visualization")
	}

	// Should show free energy value
	freeEnergyFound := false
	for _, line := range result {
		if len(line) >= 3 && line[:3] == "0.1" { // Approximate free energy
			freeEnergyFound = true
			break
		}
	}
	if !freeEnergyFound {
		t.Error("Expected to find free energy value in agent visualization")
	}
}

// TestErrorHandling tests visualization error handling
func TestErrorHandling(t *testing.T) {
	visualizer := NewProbabilityDistributionVisualizer()

	// Test with empty inputs
	result := visualizer.VisualizeCategorical([]methods.Probability{}, []string{})
	if len(result) == 0 {
		t.Error("Expected some output even for empty inputs")
	}

	// Test with mismatched lengths
	result = visualizer.VisualizeCategorical([]methods.Probability{0.5}, []string{"A", "B"})
	if len(result) == 0 {
		t.Error("Expected some output even for mismatched inputs")
	}
}

// TestVisualizationPerformance tests that visualizations complete in reasonable time
func TestVisualizationPerformance(t *testing.T) {
	visualizer := NewProbabilityDistributionVisualizer()

	// Large distribution for performance test
	largeDist := make([]methods.Probability, 100)
	largeLabels := make([]string, 100)

	for i := range largeDist {
		largeDist[i] = methods.Probability(float64(i) / 100.0)
		largeLabels[i] = ufmt.Sprintf("Item%d", i)
	}

	result := visualizer.VisualizeCategorical(largeDist, largeLabels)

	if len(result) == 0 {
		t.Error("Expected non-empty result for large distribution")
	}

	// Should handle large inputs gracefully
	if len(result) < 10 {
		t.Error("Expected substantial output for large distribution visualization")
	}
}
