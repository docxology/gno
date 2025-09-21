// Package probability provides fundamental probabilistic data structures and methods
// for Bayesian inference, active inference, and cognitive modeling on Gno blockchain.
//
// This package implements deterministic probabilistic computations suitable for
// on-chain applications, following the Free Energy Principle and Active Inference
// frameworks. All operations are designed to be gas-efficient and deterministic.
package probability

import (
	"math"
	"gno.land/p/nt/ufmt"
)

// Probability represents a probability value between 0 and 1
type Probability float64

// Validate checks if the probability is within valid range [0, 1]
func (p Probability) Validate() error {
	if p < 0 || p > 1 {
		return ufmt.Errorf("probability must be between 0 and 1, got %f", float64(p))
	}
	return nil
}

// String returns a string representation of the probability
func (p Probability) String() string {
	return ufmt.Sprintf("%.6f", float64(p))
}

// LogProbability represents a log probability value (natural log)
type LogProbability float64

// ToProbability converts log probability back to regular probability
func (lp LogProbability) ToProbability() Probability {
	return Probability(math.Exp(float64(lp)))
}

// Add performs log-space addition: log(exp(a) + exp(b))
func (lp LogProbability) Add(other LogProbability) LogProbability {
	a, b := float64(lp), float64(other)
	if a > b {
		return LogProbability(a + math.Log(1+math.Exp(b-a)))
	}
	return LogProbability(b + math.Log(1+math.Exp(a-b)))
}

// Multiply performs log-space multiplication: a + b
func (lp LogProbability) Multiply(other LogProbability) LogProbability {
	return LogProbability(float64(lp) + float64(other))
}

// Distribution represents a probability distribution over discrete outcomes
type Distribution struct {
	Outcomes []string      // Names of possible outcomes
	Probs    []Probability // Corresponding probabilities (must sum to 1)
}

// NewDistribution creates a new probability distribution
func NewDistribution(outcomes []string, probs []Probability) (*Distribution, error) {
	if len(outcomes) != len(probs) {
		return nil, ufmt.Errorf("outcomes and probabilities must have same length")
	}

	// Validate probabilities
	sum := Probability(0)
	for _, p := range probs {
		if err := p.Validate(); err != nil {
			return nil, err
		}
		sum += p
	}

	// Check if probabilities sum to approximately 1
	if math.Abs(float64(sum-1.0)) > 1e-6 {
		return nil, ufmt.Errorf("probabilities must sum to 1, got %f", float64(sum))
	}

	return &Distribution{
		Outcomes: outcomes,
		Probs:    probs,
	}, nil
}

// Normalize ensures the distribution sums to 1
func (d *Distribution) Normalize() {
	sum := Probability(0)
	for _, p := range d.Probs {
		sum += p
	}

	if sum == 0 {
		// Uniform distribution if all probabilities are 0
		uniformProb := Probability(1.0 / float64(len(d.Probs)))
		for i := range d.Probs {
			d.Probs[i] = uniformProb
		}
		return
	}

	// Normalize
	for i := range d.Probs {
		d.Probs[i] = d.Probs[i] / sum
	}
}

// GetProbability returns the probability of a specific outcome
func (d *Distribution) GetProbability(outcome string) Probability {
	for i, o := range d.Outcomes {
		if o == outcome {
			return d.Probs[i]
		}
	}
	return 0
}

// Sample returns a randomly sampled outcome based on the distribution
// Uses deterministic entropy from blockchain state
func (d *Distribution) Sample(entropySource func() uint32) string {
	if len(d.Outcomes) == 0 {
		return ""
	}

	// Generate random value between 0 and 1
	random := float64(entropySource()%1000000) / 1000000.0
	cumulative := 0.0

	for i, prob := range d.Probs {
		cumulative += float64(prob)
		if random <= cumulative {
			return d.Outcomes[i]
		}
	}

	// Fallback to last outcome (should not happen with proper normalization)
	return d.Outcomes[len(d.Outcomes)-1]
}

// String returns a string representation of the distribution
func (d *Distribution) String() string {
	result := "Distribution{\n"
	for i, outcome := range d.Outcomes {
		result += ufmt.Sprintf("  %s: %s\n", outcome, d.Probs[i].String())
	}
	result += "}"
	return result
}

// ConditionalDistribution represents P(X|Y) - probability of X given Y
type ConditionalDistribution struct {
	GivenOutcomes []string         // Outcomes of the conditioning variable
	Distributions []*Distribution  // P(X|given_outcome[i])
}

// NewConditionalDistribution creates a new conditional distribution
func NewConditionalDistribution(givenOutcomes []string, distributions []*Distribution) (*ConditionalDistribution, error) {
	if len(givenOutcomes) != len(distributions) {
		return nil, ufmt.Errorf("given outcomes and distributions must have same length")
	}

	return &ConditionalDistribution{
		GivenOutcomes: givenOutcomes,
		Distributions: distributions,
	}, nil
}

// GetConditional returns P(X|Y=y)
func (cd *ConditionalDistribution) GetConditional(given string) *Distribution {
	for i, outcome := range cd.GivenOutcomes {
		if outcome == given {
			return cd.Distributions[i]
		}
	}
	return nil
}

// JointDistribution represents a joint probability distribution P(X,Y)
type JointDistribution struct {
	XOutcomes []string
	YOutcomes []string
	Probs     [][]Probability // Probs[x][y] = P(X=x, Y=y)
}

// NewJointDistribution creates a new joint distribution
func NewJointDistribution(xOutcomes, yOutcomes []string, probs [][]Probability) (*JointDistribution, error) {
	if len(probs) != len(xOutcomes) {
		return nil, ufmt.Errorf("probability matrix rows must match X outcomes length")
	}

	for i, row := range probs {
		if len(row) != len(yOutcomes) {
			return nil, ufmt.Errorf("probability matrix row %d length must match Y outcomes length", i)
		}
	}

	// Validate probabilities
	sum := Probability(0)
	for _, row := range probs {
		for _, p := range row {
			if err := p.Validate(); err != nil {
				return nil, err
			}
			sum += p
		}
	}

	if math.Abs(float64(sum-1.0)) > 1e-6 {
		return nil, ufmt.Errorf("probabilities must sum to 1, got %f", float64(sum))
	}

	return &JointDistribution{
		XOutcomes: xOutcomes,
		YOutcomes: yOutcomes,
		Probs:     probs,
	}, nil
}

// MarginalX computes the marginal distribution P(X)
func (jd *JointDistribution) MarginalX() *Distribution {
	marginalProbs := make([]Probability, len(jd.XOutcomes))

	for i := range jd.XOutcomes {
		sum := Probability(0)
		for j := range jd.YOutcomes {
			sum += jd.Probs[i][j]
		}
		marginalProbs[i] = sum
	}

	return &Distribution{
		Outcomes: jd.XOutcomes,
		Probs:    marginalProbs,
	}
}

// MarginalY computes the marginal distribution P(Y)
func (jd *JointDistribution) MarginalY() *Distribution {
	marginalProbs := make([]Probability, len(jd.YOutcomes))

	for j := range jd.YOutcomes {
		sum := Probability(0)
		for i := range jd.XOutcomes {
			sum += jd.Probs[i][j]
		}
		marginalProbs[j] = sum
	}

	return &Distribution{
		Outcomes: jd.YOutcomes,
		Probs:    marginalProbs,
	}
}

// ConditionalXY computes P(X|Y) from the joint distribution
func (jd *JointDistribution) ConditionalXY() *ConditionalDistribution {
	distributions := make([]*Distribution, len(jd.YOutcomes))
	givenOutcomes := make([]string, len(jd.YOutcomes))

	for j, yOutcome := range jd.YOutcomes {
		givenOutcomes[j] = yOutcome

		// Get P(Y=y)
		py := Probability(0)
		for i := range jd.XOutcomes {
			py += jd.Probs[i][j]
		}

		// Compute conditional probabilities P(X|Y=y)
		condProbs := make([]Probability, len(jd.XOutcomes))
		if py > 0 {
			for i := range jd.XOutcomes {
				condProbs[i] = jd.Probs[i][j] / py
			}
		}

		distributions[j] = &Distribution{
			Outcomes: jd.XOutcomes,
			Probs:    condProbs,
		}
	}

	return &ConditionalDistribution{
		GivenOutcomes: givenOutcomes,
		Distributions: distributions,
	}
}

// ConditionalYX computes P(Y|X) from the joint distribution
func (jd *JointDistribution) ConditionalYX() *ConditionalDistribution {
	distributions := make([]*Distribution, len(jd.XOutcomes))
	givenOutcomes := make([]string, len(jd.XOutcomes))

	for i, xOutcome := range jd.XOutcomes {
		givenOutcomes[i] = xOutcome

		// Get P(X=x)
		px := Probability(0)
		for j := range jd.YOutcomes {
			px += jd.Probs[i][j]
		}

		// Compute conditional probabilities P(Y|X=x)
		condProbs := make([]Probability, len(jd.YOutcomes))
		if px > 0 {
			for j := range jd.YOutcomes {
				condProbs[j] = jd.Probs[i][j] / px
			}
		}

		distributions[i] = &Distribution{
			Outcomes: jd.YOutcomes,
			Probs:    condProbs,
		}
	}

	return &ConditionalDistribution{
		GivenOutcomes: givenOutcomes,
		Distributions: distributions,
	}
}

// Simple test runner for basic functionality
func runBasicTests() {
	println("=== Running Basic Probability Tests ===")

	// Test basic probability operations
	testBasicProbabilityOps()

	println("=== Basic Tests Complete ===")
}

func testBasicProbabilityOps() {
	println("Testing basic probability operations...")

	// Test probability creation and basic operations
	p1 := Probability(0.3)
	p2 := Probability(0.4)

	// Test addition
	sum := p1 + p2
	if sum == 0.7 {
		println("PASS: Probability addition works")
	} else {
		println("FAIL: Probability addition incorrect, got", sum, "expected 0.7")
	}

	// Test multiplication
	product := p1 * p2
	if product == 0.12 {
		println("PASS: Probability multiplication works")
	} else {
		println("FAIL: Probability multiplication incorrect, got", product, "expected 0.12")
	}

	// Test comparison
	if p1 < p2 {
		println("PASS: Probability comparison works")
	} else {
		println("FAIL: Probability comparison incorrect")
	}

	// Test conversion to float64
	f1 := float64(p1)
	if f1 == 0.3 {
		println("PASS: Probability to float64 conversion works")
	} else {
		println("FAIL: Probability to float64 conversion incorrect")
	}

	// Test distribution creation
	println("Testing distribution creation...")
	outcomes := []string{"A", "B", "C"}
	probs := []Probability{0.2, 0.3, 0.5}
	dist, err := NewDistribution(outcomes, probs)

	if err != nil {
		println("FAIL: Distribution creation failed:", err.Error())
	} else if dist != nil {
		println("PASS: Distribution created successfully")

		// Test probability access
		if dist.GetProbability("B") == 0.3 {
			println("PASS: dist.GetProbability(\"B\") = 0.3")
		} else {
			println("FAIL: dist.GetProbability(\"B\") incorrect, got", dist.GetProbability("B"))
		}
	} else {
		println("FAIL: NewDistribution returned nil")
	}
}

// Main test execution
func main() {
	runBasicTests()
}
