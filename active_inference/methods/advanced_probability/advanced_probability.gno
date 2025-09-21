// Package advanced_probability provides advanced probabilistic methods
// for active inference, including additional distributions, statistical tests,
// and mathematical utilities optimized for blockchain execution.
package advanced_probability

import (
	"math"
	"gno.land/p/active_inference/methods"
)

// Gaussian (Normal) Distribution
type Gaussian struct {
	Mean     methods.Probability
	Variance methods.Probability
}

func NewGaussian(mean, variance methods.Probability) *Gaussian {
	if variance <= 0 {
		panic("variance must be positive")
	}
	return &Gaussian{
		Mean:     mean,
		Variance: variance,
	}
}

func (g *Gaussian) Sample() methods.Probability {
	// Deterministic sampling for blockchain compatibility
	// In practice, this would use a deterministic PRNG
	return g.Mean // Simplified for demonstration
}

func (g *Gaussian) PDF(x methods.Probability) methods.Probability {
	diff := x - g.Mean
	exponent := -0.5 * diff * diff / g.Variance
	coefficient := 1.0 / methods.Probability(math.Sqrt(2*math.Pi*float64(g.Variance)))
	return coefficient * methods.Probability(math.Exp(float64(exponent)))
}

func (g *Gaussian) CDF(x methods.Probability) methods.Probability {
	// Simplified CDF approximation
	z := (x - g.Mean) / methods.Probability(math.Sqrt(float64(g.Variance)))
	// Using approximation of error function
	return 0.5 * (1 + methods.Probability(math.Tanh(float64(z)*0.886226899)))
}

func (g *Gaussian) Entropy() methods.Probability {
	return 0.5 * methods.Probability(math.Log(2*math.Pi*math.E*float64(g.Variance)))
}

// Beta Distribution (useful for belief updating)
type Beta struct {
	Alpha methods.Probability // successes + 1
	Beta  methods.Probability // failures + 1
}

func NewBeta(alpha, beta methods.Probability) *Beta {
	if alpha <= 0 || beta <= 0 {
		panic("alpha and beta must be positive")
	}
	return &Beta{Alpha: alpha, Beta: beta}
}

func (b *Beta) PDF(x methods.Probability) methods.Probability {
	if x <= 0 || x >= 1 {
		return 0
	}

	// Beta PDF: x^(α-1) * (1-x)^(β-1) / B(α,β)
	// Using log space for numerical stability
	logNum := (b.Alpha-1)*methods.Probability(math.Log(float64(x))) +
	          (b.Beta-1)*methods.Probability(math.Log(float64(1-x)))
	logDenom := LogBeta(b.Alpha, b.Beta)

	return methods.Probability(math.Exp(float64(logNum - logDenom)))
}

func (b *Beta) Mean() methods.Probability {
	return b.Alpha / (b.Alpha + b.Beta)
}

func (b *Beta) Variance() methods.Probability {
	total := b.Alpha + b.Beta
	return (b.Alpha * b.Beta) / (total * total * (total + 1))
}

func (b *Beta) Update(successes, failures methods.Probability) *Beta {
	return NewBeta(b.Alpha+successes, b.Beta+failures)
}

// LogBeta function for Beta distribution
func LogBeta(alpha, beta methods.Probability) methods.Probability {
	// Using approximation: ln(B(α,β)) ≈ ln(Γ(α)) + ln(Γ(β)) - ln(Γ(α+β))
	// Simplified implementation
	return methods.Probability(math.Lgamma(float64(alpha)) +
	                           math.Lgamma(float64(beta)) -
	                           math.Lgamma(float64(alpha+beta)))
}

// Dirichlet Distribution (for multinomial beliefs)
type Dirichlet struct {
	Alpha []methods.Probability // concentration parameters
}

func NewDirichlet(alpha []methods.Probability) *Dirichlet {
	for _, a := range alpha {
		if a <= 0 {
			panic("all alpha parameters must be positive")
		}
	}
	return &Dirichlet{Alpha: alpha}
}

func (d *Dirichlet) PDF(x []methods.Probability) methods.Probability {
	if len(x) != len(d.Alpha) {
		return 0
	}

	// Check if x is a valid probability distribution
	sum := methods.Probability(0)
	for _, val := range x {
		if val < 0 {
			return 0
		}
		sum += val
	}
	if math.Abs(float64(sum-1.0)) > 1e-6 {
		return 0
	}

	// Dirichlet PDF: [Γ(Σα) / ΠΓ(α_i)] * Π(x_i^(α_i-1))
	logNum := LogBeta(sumAlpha(d.Alpha), 0) // This is a simplification
	for i, alpha := range d.Alpha {
		logNum += (alpha - 1) * methods.Probability(math.Log(float64(x[i])))
	}

	return methods.Probability(math.Exp(float64(logNum)))
}

func (d *Dirichlet) Mean() []methods.Probability {
	sum := sumAlpha(d.Alpha)
	mean := make([]methods.Probability, len(d.Alpha))
	for i, alpha := range d.Alpha {
		mean[i] = alpha / sum
	}
	return mean
}

func (d *Dirichlet) Update(counts []methods.Probability) *Dirichlet {
	if len(counts) != len(d.Alpha) {
		panic("counts length must match alpha length")
	}

	newAlpha := make([]methods.Probability, len(d.Alpha))
	for i := range d.Alpha {
		newAlpha[i] = d.Alpha[i] + counts[i]
	}

	return NewDirichlet(newAlpha)
}

// Helper function to sum alpha parameters
func sumAlpha(alpha []methods.Probability) methods.Probability {
	sum := methods.Probability(0)
	for _, a := range alpha {
		sum += a
	}
	return sum
}

// Markov Chain for temporal modeling
type MarkovChain struct {
	States       []string
	TransitionMatrix [][]methods.Probability
	CurrentState int
}

func NewMarkovChain(states []string, transitions [][]methods.Probability) *MarkovChain {
	if len(transitions) != len(states) {
		panic("transition matrix must match number of states")
	}

	for i, row := range transitions {
		if len(row) != len(states) {
			panic("transition matrix must be square")
		}
		// Normalize each row
		sum := methods.Probability(0)
		for _, val := range row {
			sum += val
		}
		if sum > 0 {
			for j := range row {
				row[j] = row[j] / sum
			}
		}
		transitions[i] = row
	}

	return &MarkovChain{
		States:           states,
		TransitionMatrix: transitions,
		CurrentState:     0, // Start at first state
	}
}

func (mc *MarkovChain) Transition() {
	// Deterministic transition for blockchain compatibility
	// In practice, this would use probabilistic sampling
	maxProb := methods.Probability(0)
	nextState := 0

	for j, prob := range mc.TransitionMatrix[mc.CurrentState] {
		if prob > maxProb {
			maxProb = prob
			nextState = j
		}
	}

	mc.CurrentState = nextState
}

func (mc *MarkovChain) GetState() string {
	return mc.States[mc.CurrentState]
}

func (mc *MarkovChain) GetTransitionProb(from, to int) methods.Probability {
	if from < 0 || from >= len(mc.States) || to < 0 || to >= len(mc.States) {
		return 0
	}
	return mc.TransitionMatrix[from][to]
}

// Hidden Markov Model (HMM)
type HiddenMarkovModel struct {
	States       []string
	Observations []string
	TransitionMatrix [][]methods.Probability
	EmissionMatrix   [][]methods.Probability
	InitialProb      []methods.Probability
	CurrentState     int
}

func NewHiddenMarkovModel(states, observations []string,
	transitions, emissions [][]methods.Probability,
	initial []methods.Probability) *HiddenMarkovModel {

	return &HiddenMarkovModel{
		States:           states,
		Observations:     observations,
		TransitionMatrix: transitions,
		EmissionMatrix:   emissions,
		InitialProb:      initial,
		CurrentState:     0,
	}
}

func (hmm *HiddenMarkovModel) EmitObservation() string {
	// Get emission probabilities for current state
	emissionProbs := hmm.EmissionMatrix[hmm.CurrentState]

	// Find most likely observation (deterministic for blockchain)
	maxProb := methods.Probability(0)
	bestObs := 0

	for i, prob := range emissionProbs {
		if prob > maxProb {
			maxProb = prob
			bestObs = i
		}
	}

	return hmm.Observations[bestObs]
}

func (hmm *HiddenMarkovModel) Transition() {
	// Transition to next state
	transitionProbs := hmm.TransitionMatrix[hmm.CurrentState]

	maxProb := methods.Probability(0)
	nextState := 0

	for i, prob := range transitionProbs {
		if prob > maxProb {
			maxProb = prob
			nextState = i
		}
	}

	hmm.CurrentState = nextState
}

func (hmm *HiddenMarkovModel) GetState() string {
	return hmm.States[hmm.CurrentState]
}

// Statistical Tests
type StatisticalTest struct{}

func NewStatisticalTest() *StatisticalTest {
	return &StatisticalTest{}
}

// ChiSquare test for independence
func (st *StatisticalTest) ChiSquareTest(observed [][]int, expected [][]float64) methods.Probability {
	chiSquare := 0.0

	for i := range observed {
		for j := range observed[i] {
			if expected[i][j] > 0 {
				diff := float64(observed[i][j]) - expected[i][j]
				chiSquare += (diff * diff) / expected[i][j]
			}
		}
	}

	// Simplified p-value approximation
	// In practice, this would use chi-square distribution
	if chiSquare > 10.0 {
		return 0.001 // Very significant
	} else if chiSquare > 5.0 {
		return 0.01  // Significant
	} else if chiSquare > 2.0 {
		return 0.05  // Marginally significant
	} else {
		return 0.1   // Not significant
	}
}

// T-test for comparing means
func (st *StatisticalTest) TTest(sample1, sample2 []methods.Probability) (methods.Probability, methods.Probability) {
	n1 := len(sample1)
	n2 := len(sample2)

	if n1 == 0 || n2 == 0 {
		return 0, 1.0 // No significance
	}

	// Calculate means
	mean1 := methods.Probability(0)
	for _, val := range sample1 {
		mean1 += val
	}
	mean1 /= methods.Probability(n1)

	mean2 := methods.Probability(0)
	for _, val := range sample2 {
		mean2 += val
	}
	mean2 /= methods.Probability(n2)

	// Calculate variances
	var1 := methods.Probability(0)
	for _, val := range sample1 {
		diff := val - mean1
		var1 += diff * diff
	}
	var1 /= methods.Probability(n1 - 1)

	var2 := methods.Probability(0)
	for _, val := range sample2 {
		diff := val - mean2
		var2 += diff * diff
	}
	var2 /= methods.Probability(n2 - 1)

	// Pooled standard error
	se := methods.Probability(math.Sqrt(float64(var1/methods.Probability(n1) + var2/methods.Probability(n2))))

	if se == 0 {
		return 0, 1.0
	}

	// T-statistic
	t := (mean1 - mean2) / se

	// Simplified p-value (two-tailed)
	p := methods.Probability(2 * (1 - methods.Probability(math.Abs(float64(t))/math.Sqrt(2*math.Pi))))

	return t, p
}

// Information Theory Utilities
type InformationTheory struct{}

func NewInformationTheory() *InformationTheory {
	return &InformationTheory{}
}

// Kullback-Leibler Divergence
func (it *InformationTheory) KLDivergence(p, q []methods.Probability) methods.Probability {
	if len(p) != len(q) {
		return 0
	}

	kl := methods.Probability(0)
	for i := range p {
		if p[i] > 0 && q[i] > 0 {
			kl += p[i] * methods.Probability(math.Log(float64(p[i]/q[i])))
		}
	}

	return kl
}

// Jensen-Shannon Divergence (symmetric version of KL)
func (it *InformationTheory) JSDivergence(p, q []methods.Probability) methods.Probability {
	if len(p) != len(q) {
		return 0
	}

	// Calculate average distribution
	m := make([]methods.Probability, len(p))
	for i := range p {
		m[i] = (p[i] + q[i]) / 2
	}

	kl1 := it.KLDivergence(p, m)
	kl2 := it.KLDivergence(q, m)

	return (kl1 + kl2) / 2
}

// Mutual Information
func (it *InformationTheory) MutualInformation(joint [][]methods.Probability, marginalX, marginalY []methods.Probability) methods.Probability {
	if len(joint) == 0 || len(marginalX) == 0 || len(marginalY) == 0 {
		return 0
	}

	mi := methods.Probability(0)
	for i := range joint {
		for j := range joint[i] {
			if i < len(marginalX) && j < len(marginalY) && joint[i][j] > 0 && marginalX[i] > 0 && marginalY[j] > 0 {
				mi += joint[i][j] * methods.Probability(math.Log(float64(joint[i][j]/(marginalX[i]*marginalY[j]))))
			}
		}
	}

	return mi
}
