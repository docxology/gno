// Package probability_test provides comprehensive tests for probabilistic methods
package probability

import (
	"math"
)

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
}

// Main test execution
func main() {
	runBasicTests()
}
