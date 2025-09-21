// Package advanced_probability_test provides comprehensive tests for advanced probabilistic methods
package advanced_probability

import (
	"math"
	"testing"
	"gno.land/p/active_inference/methods"
)

func TestGaussianDistribution(t *testing.T) {
	// Test basic Gaussian
	g := NewGaussian(0.5, 0.25)

	if g.Mean != 0.5 {
		t.Errorf("Expected mean 0.5, got %f", g.Mean)
	}

	if g.Variance != 0.25 {
		t.Errorf("Expected variance 0.25, got %f", g.Variance)
	}

	// Test PDF at mean (should be maximum)
	pdfAtMean := g.PDF(0.5)
	pdfAtDeviation := g.PDF(0.75) // 1 SD away

	if pdfAtMean <= pdfAtDeviation {
		t.Error("PDF should be higher at mean than at 1 SD away")
	}

	// Test CDF properties
	cdfAtMean := g.CDF(0.5)
	cdfAtHigh := g.CDF(1.0)

	if cdfAtMean < 0.4 || cdfAtMean > 0.6 {
		t.Errorf("CDF at mean should be around 0.5, got %f", cdfAtMean)
	}

	if cdfAtHigh <= cdfAtMean {
		t.Error("CDF should increase as x increases")
	}

	// Test entropy
	entropy := g.Entropy()
	expectedEntropy := 0.5 * methods.Probability(math.Log(2*math.Pi*math.E*0.25))

	if math.Abs(float64(entropy-expectedEntropy)) > 0.01 {
		t.Errorf("Entropy calculation incorrect: expected %f, got %f", expectedEntropy, entropy)
	}
}

func TestBetaDistribution(t *testing.T) {
	// Test symmetric beta
	b := NewBeta(2, 2) // Symmetric beta

	if b.Mean() != 0.5 {
		t.Errorf("Expected mean 0.5 for Beta(2,2), got %f", b.Mean())
	}

	if b.Variance() <= 0 {
		t.Error("Variance should be positive")
	}

	// Test PDF at different points
	pdfAt05 := b.PDF(0.5)
	pdfAt02 := b.PDF(0.2)
	pdfAt08 := b.PDF(0.8)

	// For Beta(2,2), PDF should be highest at 0.5
	if pdfAt05 < pdfAt02 || pdfAt05 < pdfAt08 {
		t.Error("PDF should be highest at 0.5 for Beta(2,2)")
	}

	// Test PDF at boundaries (should be 0)
	pdfAt0 := b.PDF(0)
	pdfAt1 := b.PDF(1)

	if pdfAt0 != 0 || pdfAt1 != 0 {
		t.Error("PDF should be 0 at boundaries for Beta distribution")
	}

	// Test updating
	bUpdated := b.Update(1, 0) // Add one success
	if bUpdated.Alpha != 3 || bUpdated.Beta != 2 {
		t.Error("Beta update not working correctly")
	}

	// Test that mean increases after success
	if bUpdated.Mean() <= b.Mean() {
		t.Error("Mean should increase after success")
	}
}

func TestDirichletDistribution(t *testing.T) {
	// Test uniform Dirichlet
	alpha := []methods.Probability{1, 1, 1}
	d := NewDirichlet(alpha)

	mean := d.Mean()
	expectedMean := []methods.Probability{1.0/3, 1.0/3, 1.0/3}

	for i := range mean {
		if math.Abs(float64(mean[i]-expectedMean[i])) > 0.01 {
			t.Errorf("Dirichlet mean incorrect at index %d: expected %f, got %f", i, expectedMean[i], mean[i])
		}
	}

	// Test PDF
	x := []methods.Probability{0.3, 0.4, 0.3}
	pdf := d.PDF(x)

	if pdf <= 0 {
		t.Error("PDF should be positive for valid probability distribution")
	}

	// Test PDF with invalid input (doesn't sum to 1)
	xInvalid := []methods.Probability{0.5, 0.3, 0.3}
	pdfInvalid := d.PDF(xInvalid)

	if pdfInvalid != 0 {
		t.Error("PDF should be 0 for invalid probability distribution")
	}

	// Test updating
	counts := []methods.Probability{2, 1, 1}
	dUpdated := d.Update(counts)

	if len(dUpdated.Alpha) != len(alpha) {
		t.Error("Updated Dirichlet should have same number of parameters")
	}

	// Check that alpha values increased
	for i := range dUpdated.Alpha {
		if dUpdated.Alpha[i] <= d.Alpha[i] {
			t.Errorf("Alpha[%d] should have increased: %f -> %f", i, d.Alpha[i], dUpdated.Alpha[i])
		}
	}
}

func TestMarkovChain(t *testing.T) {
	states := []string{"Sunny", "Cloudy", "Rainy"}
	transitions := [][]methods.Probability{
		{0.8, 0.1, 0.1}, // Sunny -> Sunny, Cloudy, Rainy
		{0.4, 0.4, 0.2}, // Cloudy -> Sunny, Cloudy, Rainy
		{0.2, 0.3, 0.5}, // Rainy -> Sunny, Cloudy, Rainy
	}

	mc := NewMarkovChain(states, transitions)

	// Test initial state
	if mc.GetState() != "Sunny" {
		t.Errorf("Expected initial state 'Sunny', got '%s'", mc.GetState())
	}

	// Test transition probabilities
	if mc.GetTransitionProb(0, 0) != 0.8 {
		t.Error("Transition probability Sunny->Sunny should be 0.8")
	}

	if mc.GetTransitionProb(0, 2) != 0.1 {
		t.Error("Transition probability Sunny->Rainy should be 0.1")
	}

	// Test transition
	mc.Transition()
	// Should transition to most likely state from Sunny (Sunny with prob 0.8)
	if mc.GetState() != "Sunny" {
		t.Errorf("Expected transition to 'Sunny', got '%s'", mc.GetState())
	}

	// Test invalid transition probabilities
	if mc.GetTransitionProb(-1, 0) != 0 {
		t.Error("Invalid transition should return 0")
	}

	if mc.GetTransitionProb(0, 3) != 0 {
		t.Error("Invalid transition should return 0")
	}
}

func TestHiddenMarkovModel(t *testing.T) {
	states := []string{"Healthy", "Sick"}
	observations := []string{"Normal", "Abnormal"}

	transitions := [][]methods.Probability{
		{0.9, 0.1}, // Healthy -> Healthy, Sick
		{0.2, 0.8}, // Sick -> Healthy, Sick
	}

	emissions := [][]methods.Probability{
		{0.8, 0.2}, // Healthy -> Normal, Abnormal
		{0.3, 0.7}, // Sick -> Normal, Abnormal
	}

	initial := []methods.Probability{0.6, 0.4}

	hmm := NewHiddenMarkovModel(states, observations, transitions, emissions, initial)

	// Test initial state
	if hmm.GetState() != "Healthy" {
		t.Errorf("Expected initial state 'Healthy', got '%s'", hmm.GetState())
	}

	// Test emission
	observation := hmm.EmitObservation()
	if observation != "Normal" {
		t.Errorf("Expected most likely observation 'Normal', got '%s'", observation)
	}

	// Test transition
	hmm.Transition()
	// Should stay in Healthy state (most likely transition)
	if hmm.GetState() != "Healthy" {
		t.Errorf("Expected transition to 'Healthy', got '%s'", hmm.GetState())
	}
}

func TestStatisticalTests(t *testing.T) {
	st := NewStatisticalTest()

	// Test Chi-Square
	observed := [][]int{
		{10, 5},
		{8, 7},
	}
	expected := [][]float64{
		{9, 6},
		{9, 6},
	}

	pValue := st.ChiSquareTest(observed, expected)

	if pValue < 0 || pValue > 1 {
		t.Errorf("P-value should be between 0 and 1, got %f", pValue)
	}

	// Test T-test
	sample1 := []methods.Probability{1.0, 1.1, 0.9, 1.2, 0.8}
	sample2 := []methods.Probability{2.0, 2.1, 1.9, 2.2, 1.8}

	tStat, pValue := st.TTest(sample1, sample2)

	if math.IsNaN(float64(tStat)) || math.IsInf(float64(tStat), 0) {
		t.Error("T-statistic should be finite")
	}

	if pValue < 0 || pValue > 1 {
		t.Errorf("P-value should be between 0 and 1, got %f", pValue)
	}

	// Samples with different means should have significant difference
	if pValue > 0.05 {
		t.Error("Samples with different means should have significant p-value")
	}
}

func TestInformationTheory(t *testing.T) {
	it := NewInformationTheory()

	// Test KL Divergence
	p := []methods.Probability{0.5, 0.5}
	q := []methods.Probability{0.6, 0.4}

	kl := it.KLDivergence(p, q)

	if kl < 0 {
		t.Error("KL divergence should be non-negative")
	}

	// KL(P||P) should be 0
	klSame := it.KLDivergence(p, p)
	if klSame != 0 {
		t.Errorf("KL divergence of identical distributions should be 0, got %f", klSame)
	}

	// Test JS Divergence (symmetric)
	js := it.JSDivergence(p, q)

	if js < 0 {
		t.Error("JS divergence should be non-negative")
	}

	if js > kl {
		t.Error("JS divergence should be less than or equal to KL divergence")
	}

	// Test Mutual Information
	joint := [][]methods.Probability{
		{0.2, 0.1},
		{0.1, 0.6},
	}
	marginalX := []methods.Probability{0.3, 0.7}
	marginalY := []methods.Probability{0.3, 0.7}

	mi := it.MutualInformation(joint, marginalX, marginalY)

	if mi < 0 {
		t.Error("Mutual information should be non-negative")
	}

	// For independent variables, MI should be 0
	jointIndep := [][]methods.Probability{
		{0.21, 0.09},
		{0.49, 0.21},
	}
	miIndep := it.MutualInformation(jointIndep, marginalX, marginalY)

	if miIndep > 0.01 { // Allow small numerical error
		t.Error("Mutual information should be 0 for independent variables")
	}
}

func TestEdgeCases(t *testing.T) {
	// Test Gaussian with zero variance (should panic)
	defer func() {
		if r := recover(); r == nil {
			t.Error("Expected panic for zero variance")
		}
	}()
	NewGaussian(0, 0)

	// Test Beta with zero parameters (should panic)
	defer func() {
		if r := recover(); r == nil {
			t.Error("Expected panic for zero alpha")
		}
	}()
	NewBeta(0, 1)

	defer func() {
		if r := recover(); r == nil {
			t.Error("Expected panic for zero beta")
		}
	}()
	NewBeta(1, 0)

	// Test Dirichlet with zero parameters (should panic)
	defer func() {
		if r := recover(); r == nil {
			t.Error("Expected panic for zero alpha in Dirichlet")
		}
	}()
	NewDirichlet([]methods.Probability{1, 0, 1})

	// Test Markov Chain with mismatched dimensions
	defer func() {
		if r := recover(); r == nil {
			t.Error("Expected panic for mismatched transition matrix")
		}
	}()
	NewMarkovChain([]string{"A", "B"}, [][]methods.Probability{{0.5, 0.5}}) // Missing row
}

func TestIntegration(t *testing.T) {
	// Test integration of multiple distributions

	// Create a Bayesian model with Gaussian priors
	prior := NewGaussian(0.5, 0.1)
	likelihood := NewBeta(2, 3)

	// Simulate some data
	observations := []methods.Probability{0.6, 0.7, 0.5, 0.8}

	// Update beta distribution based on observations
	successes := methods.Probability(0)
	for _, obs := range observations {
		if obs > 0.5 {
			successes++
		}
	}

	updatedLikelihood := likelihood.Update(successes, methods.Probability(len(observations))-successes)

	// Check that posterior mean is reasonable
	posteriorMean := updatedLikelihood.Mean()
	if posteriorMean <= likelihood.Mean() {
		t.Error("Posterior mean should be higher after positive observations")
	}

	// Test information-theoretic measures
	it := NewInformationTheory()

	priorDist := []methods.Probability{0.5, 0.5}
	posteriorDist := []methods.Probability{float64(posteriorMean), float64(1-posteriorMean)}

	kl := it.KLDivergence(priorDist, posteriorDist)
	if kl < 0 {
		t.Error("KL divergence should be non-negative")
	}

	js := it.JSDivergence(priorDist, posteriorDist)
	if js < 0 || js > 1 {
		t.Errorf("JS divergence should be between 0 and 1, got %f", js)
	}
}

func TestMarkovChainStationaryDistribution(t *testing.T) {
	// Test with a simple 2-state Markov chain
	states := []string{"State0", "State1"}
	transitions := [][]methods.Probability{
		{0.7, 0.3}, // State0 -> State0, State1
		{0.4, 0.6}, // State1 -> State0, State1
	}

	mc := NewMarkovChain(states, transitions)

	// Simulate many transitions to approach stationary distribution
	transitionCount := 100
	state0Count := 0
	state1Count := 0

	currentState := mc.CurrentState
	for i := 0; i < transitionCount; i++ {
		if currentState == 0 {
			state0Count++
		} else {
			state1Count++
		}
		mc.Transition()
		currentState = mc.CurrentState
	}

	// Check that we have some distribution
	total := state0Count + state1Count
	if total != transitionCount {
		t.Errorf("Expected %d total transitions, got %d", transitionCount, total)
	}

	// Both states should be visited
	if state0Count == 0 || state1Count == 0 {
		t.Error("Both states should be visited in stationary distribution")
	}
}
