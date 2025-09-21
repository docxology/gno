// Package probability_test provides comprehensive tests for probabilistic methods
package probability

import (
	"math"
	"testing"
	"gno.land/p/nt/testutils"
)

// Mock entropy source for deterministic testing
func mockEntropySource() func() uint32 {
	counter := uint32(0)
	return func() uint32 {
		counter = (counter + 1) * 1664525 + 1013904223 // Simple LCG
		return counter
	}
}

func TestProbabilityValidate(t *testing.T) {
	// Valid probabilities
	validProbs := []Probability{0.0, 0.5, 1.0}
	for _, p := range validProbs {
		if err := p.Validate(); err != nil {
			t.Errorf("Expected valid probability %f to pass validation, got error: %v", float64(p), err)
		}
	}

	// Invalid probabilities
	invalidProbs := []Probability{-0.1, 1.1, 2.0}
	for _, p := range invalidProbs {
		if err := p.Validate(); err == nil {
			t.Errorf("Expected invalid probability %f to fail validation", float64(p))
		}
	}
}

func TestProbabilityString(t *testing.T) {
	p := Probability(0.123456)
	expected := "0.123456"
	if p.String() != expected {
		t.Errorf("Expected %s, got %s", expected, p.String())
	}
}

func TestLogProbabilityToProbability(t *testing.T) {
	// Test log(0.5) ≈ -0.693147
	lp := LogProbability(math.Log(0.5))
	p := lp.ToProbability()
	expected := Probability(0.5)

	if math.Abs(float64(p-expected)) > 1e-6 {
		t.Errorf("Expected %f, got %f", expected, p)
	}
}

func TestLogProbabilityAdd(t *testing.T) {
	// Test log(exp(a) + exp(b)) where a = log(0.3), b = log(0.4)
	// Expected result: log(0.3 + 0.4) = log(0.7)
	a := LogProbability(math.Log(0.3))
	b := LogProbability(math.Log(0.4))
	result := a.Add(b)
	expected := LogProbability(math.Log(0.7))

	if math.Abs(float64(result-expected)) > 1e-6 {
		t.Errorf("Expected %f, got %f", expected, result)
	}
}

func TestLogProbabilityMultiply(t *testing.T) {
	// Test log multiplication: log(a) + log(b) = log(a*b)
	a := LogProbability(math.Log(0.3))
	b := LogProbability(math.Log(0.4))
	result := a.Multiply(b)
	expected := LogProbability(math.Log(0.12))

	if math.Abs(float64(result-expected)) > 1e-6 {
		t.Errorf("Expected %f, got %f", expected, result)
	}
}

func TestNewDistribution(t *testing.T) {
	// Valid distribution
	outcomes := []string{"A", "B", "C"}
	probs := []Probability{0.2, 0.3, 0.5}
	dist, err := NewDistribution(outcomes, probs)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	if dist == nil {
		t.Error("Expected non-nil distribution")
	}

	// Mismatched lengths
	_, err = NewDistribution([]string{"A", "B"}, []Probability{0.5, 0.3, 0.2})
	if err == nil {
		t.Error("Expected error for mismatched lengths")
	}

	// Invalid probabilities
	_, err = NewDistribution([]string{"A", "B"}, []Probability{0.5, 1.5})
	if err == nil {
		t.Error("Expected error for invalid probabilities")
	}

	// Probabilities don't sum to 1
	_, err = NewDistribution([]string{"A", "B"}, []Probability{0.3, 0.3})
	if err == nil {
		t.Error("Expected error for probabilities not summing to 1")
	}
}

func TestDistributionNormalize(t *testing.T) {
	outcomes := []string{"A", "B", "C"}
	probs := []Probability{1.0, 2.0, 3.0} // Sum = 6.0
	dist := &Distribution{Outcomes: outcomes, Probs: probs}

	dist.Normalize()

	expectedProbs := []Probability{1.0/6.0, 2.0/6.0, 3.0/6.0}
	for i, expected := range expectedProbs {
		if math.Abs(float64(dist.Probs[i]-expected)) > 1e-6 {
			t.Errorf("Expected %f, got %f", expected, dist.Probs[i])
		}
	}
}

func TestDistributionGetProbability(t *testing.T) {
	outcomes := []string{"A", "B", "C"}
	probs := []Probability{0.2, 0.3, 0.5}
	dist := &Distribution{Outcomes: outcomes, Probs: probs}

	// Existing outcome
	if dist.GetProbability("B") != 0.3 {
		t.Error("Expected probability 0.3 for outcome B")
	}

	// Non-existing outcome
	if dist.GetProbability("D") != 0 {
		t.Error("Expected probability 0 for non-existing outcome")
	}
}

func TestDistributionSample(t *testing.T) {
	outcomes := []string{"A", "B", "C"}
	probs := []Probability{0.5, 0.3, 0.2}
	dist := &Distribution{Outcomes: outcomes, Probs: probs}

	entropySource := mockEntropySource()

	// Sample multiple times to test distribution
	samples := make(map[string]int)
	for i := 0; i < 1000; i++ {
		sample := dist.Sample(entropySource)
		samples[sample]++
	}

	// Check that all outcomes are sampled
	for _, outcome := range outcomes {
		if samples[outcome] == 0 {
			t.Errorf("Outcome %s was never sampled", outcome)
		}
	}

	// Check that most samples are from highest probability outcome
	if samples["A"] < samples["B"] || samples["A"] < samples["C"] {
		t.Error("Expected outcome A to have most samples")
	}
}

func TestNewConditionalDistribution(t *testing.T) {
	givenOutcomes := []string{"X", "Y"}
	distributions := []*Distribution{
		{Outcomes: []string{"A", "B"}, Probs: []Probability{0.6, 0.4}},
		{Outcomes: []string{"A", "B"}, Probs: []Probability{0.3, 0.7}},
	}

	condDist, err := NewConditionalDistribution(givenOutcomes, distributions)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	if condDist == nil {
		t.Error("Expected non-nil conditional distribution")
	}

	// Mismatched lengths
	_, err = NewConditionalDistribution([]string{"X"}, distributions)
	if err == nil {
		t.Error("Expected error for mismatched lengths")
	}
}

func TestConditionalDistributionGetConditional(t *testing.T) {
	givenOutcomes := []string{"X", "Y"}
	distributions := []*Distribution{
		{Outcomes: []string{"A", "B"}, Probs: []Probability{0.6, 0.4}},
		{Outcomes: []string{"A", "B"}, Probs: []Probability{0.3, 0.7}},
	}
	condDist, _ := NewConditionalDistribution(givenOutcomes, distributions)

	// Existing given outcome
	dist := condDist.GetConditional("X")
	if dist == nil {
		t.Error("Expected non-nil distribution for existing outcome")
	}
	if dist.GetProbability("A") != 0.6 {
		t.Error("Expected probability 0.6 for A given X")
	}

	// Non-existing given outcome
	dist = condDist.GetConditional("Z")
	if dist != nil {
		t.Error("Expected nil distribution for non-existing outcome")
	}
}

func TestNewJointDistribution(t *testing.T) {
	xOutcomes := []string{"X1", "X2"}
	yOutcomes := []string{"Y1", "Y2", "Y3"}
	probs := [][]Probability{
		{0.1, 0.2, 0.1}, // P(X1,Y1), P(X1,Y2), P(X1,Y3)
		{0.2, 0.1, 0.3}, // P(X2,Y1), P(X2,Y2), P(X2,Y3)
	}

	jointDist, err := NewJointDistribution(xOutcomes, yOutcomes, probs)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	if jointDist == nil {
		t.Error("Expected non-nil joint distribution")
	}

	// Invalid matrix dimensions
	_, err = NewJointDistribution([]string{"X1"}, yOutcomes, probs)
	if err == nil {
		t.Error("Expected error for invalid matrix dimensions")
	}

	// Invalid probabilities
	invalidProbs := [][]Probability{
		{0.1, 0.2, 1.5},
		{0.2, 0.1, 0.3},
	}
	_, err = NewJointDistribution(xOutcomes, yOutcomes, invalidProbs)
	if err == nil {
		t.Error("Expected error for invalid probabilities")
	}

	// Probabilities don't sum to 1
	invalidProbs = [][]Probability{
		{0.1, 0.2, 0.1},
		{0.2, 0.1, 0.1}, // Sum = 0.8
	}
	_, err = NewJointDistribution(xOutcomes, yOutcomes, invalidProbs)
	if err == nil {
		t.Error("Expected error for probabilities not summing to 1")
	}
}

func TestJointDistributionMarginalX(t *testing.T) {
	xOutcomes := []string{"X1", "X2"}
	yOutcomes := []string{"Y1", "Y2"}
	probs := [][]Probability{
		{0.2, 0.3}, // P(X1,Y1)=0.2, P(X1,Y2)=0.3
		{0.1, 0.4}, // P(X2,Y1)=0.1, P(X2,Y2)=0.4
	}
	jointDist, _ := NewJointDistribution(xOutcomes, yOutcomes, probs)

	marginalX := jointDist.MarginalX()

	// P(X1) = P(X1,Y1) + P(X1,Y2) = 0.2 + 0.3 = 0.5
	// P(X2) = P(X2,Y1) + P(X2,Y2) = 0.1 + 0.4 = 0.4
	expectedProbs := []Probability{0.5, 0.4}

	for i, expected := range expectedProbs {
		if marginalX.Probs[i] != expected {
			t.Errorf("Expected marginal P(X%d) = %f, got %f", i+1, expected, marginalX.Probs[i])
		}
	}
}

func TestJointDistributionMarginalY(t *testing.T) {
	xOutcomes := []string{"X1", "X2"}
	yOutcomes := []string{"Y1", "Y2"}
	probs := [][]Probability{
		{0.2, 0.3}, // P(X1,Y1)=0.2, P(X1,Y2)=0.3
		{0.1, 0.4}, // P(X2,Y1)=0.1, P(X2,Y2)=0.4
	}
	jointDist, _ := NewJointDistribution(xOutcomes, yOutcomes, probs)

	marginalY := jointDist.MarginalY()

	// P(Y1) = P(X1,Y1) + P(X2,Y1) = 0.2 + 0.1 = 0.3
	// P(Y2) = P(X1,Y2) + P(X2,Y2) = 0.3 + 0.4 = 0.7
	expectedProbs := []Probability{0.3, 0.7}

	for i, expected := range expectedProbs {
		if marginalY.Probs[i] != expected {
			t.Errorf("Expected marginal P(Y%d) = %f, got %f", i+1, expected, marginalY.Probs[i])
		}
	}
}

func TestJointDistributionConditionalXY(t *testing.T) {
	xOutcomes := []string{"X1", "X2"}
	yOutcomes := []string{"Y1", "Y2"}
	probs := [][]Probability{
		{0.2, 0.3}, // P(X1,Y1)=0.2, P(X1,Y2)=0.3
		{0.1, 0.4}, // P(X2,Y1)=0.1, P(X2,Y2)=0.4
	}
	jointDist, _ := NewJointDistribution(xOutcomes, yOutcomes, probs)

	conditionalXY := jointDist.ConditionalXY()

	// P(X|Y1) = [P(X1|Y1), P(X2|Y1)] = [0.2/0.3, 0.1/0.3] = [2/3, 1/3]
	// P(X|Y2) = [P(X1|Y2), P(X2|Y2)] = [0.3/0.7, 0.4/0.7] = [3/7, 4/7]

	distY1 := conditionalXY.GetConditional("Y1")
	if distY1 != nil {
		expectedP1 := Probability(2.0 / 3.0)
		expectedP2 := Probability(1.0 / 3.0)
		if math.Abs(float64(distY1.Probs[0]-expectedP1)) > 1e-6 ||
		   math.Abs(float64(distY1.Probs[1]-expectedP2)) > 1e-6 {
			t.Error("Incorrect conditional probabilities for Y1")
		}
	}

	distY2 := conditionalXY.GetConditional("Y2")
	if distY2 != nil {
		expectedP1 := Probability(3.0 / 7.0)
		expectedP2 := Probability(4.0 / 7.0)
		if math.Abs(float64(distY2.Probs[0]-expectedP1)) > 1e-6 ||
		   math.Abs(float64(distY2.Probs[1]-expectedP2)) > 1e-6 {
			t.Error("Incorrect conditional probabilities for Y2")
		}
	}
}

func TestJointDistributionConditionalYX(t *testing.T) {
	xOutcomes := []string{"X1", "X2"}
	yOutcomes := []string{"Y1", "Y2"}
	probs := [][]Probability{
		{0.2, 0.3}, // P(X1,Y1)=0.2, P(X1,Y2)=0.3
		{0.1, 0.4}, // P(X2,Y1)=0.1, P(X2,Y2)=0.4
	}
	jointDist, _ := NewJointDistribution(xOutcomes, yOutcomes, probs)

	conditionalYX := jointDist.ConditionalYX()

	// P(Y|X1) = [P(Y1|X1), P(Y2|X1)] = [0.2/0.5, 0.3/0.5] = [0.4, 0.6]
	// P(Y|X2) = [P(Y1|X2), P(Y2|X2)] = [0.1/0.5, 0.4/0.5] = [0.2, 0.8]

	distX1 := conditionalYX.GetConditional("X1")
	if distX1 != nil {
		expectedP1 := Probability(0.4)
		expectedP2 := Probability(0.6)
		if math.Abs(float64(distX1.Probs[0]-expectedP1)) > 1e-6 ||
		   math.Abs(float64(distX1.Probs[1]-expectedP2)) > 1e-6 {
			t.Error("Incorrect conditional probabilities for X1")
		}
	}

	distX2 := conditionalYX.GetConditional("X2")
	if distX2 != nil {
		expectedP1 := Probability(0.2)
		expectedP2 := Probability(0.8)
		if math.Abs(float64(distX2.Probs[0]-expectedP1)) > 1e-6 ||
		   math.Abs(float64(distX2.Probs[1]-expectedP2)) > 1e-6 {
			t.Error("Incorrect conditional probabilities for X2")
		}
	}
}

// Test edge cases
func TestEmptyDistribution(t *testing.T) {
	dist := &Distribution{Outcomes: []string{}, Probs: []Probability{}}
	sample := dist.Sample(mockEntropySource())
	if sample != "" {
		t.Errorf("Expected empty string for empty distribution, got %s", sample)
	}
}

func TestSingleOutcomeDistribution(t *testing.T) {
	outcomes := []string{"A"}
	probs := []Probability{1.0}
	dist, _ := NewDistribution(outcomes, probs)

	entropySource := mockEntropySource()
	for i := 0; i < 10; i++ {
		sample := dist.Sample(entropySource)
		if sample != "A" {
			t.Errorf("Expected 'A' for single outcome distribution, got %s", sample)
		}
	}
}
