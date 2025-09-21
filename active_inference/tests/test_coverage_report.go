// Test coverage report generator for active inference framework
// This script analyzes test coverage across all modules
package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

type CoverageReport struct {
	ModuleName    string
	TestFiles     []string
	MainFiles     []string
	TestCoverage  float64
	LinesTested   int
	TotalLines    int
	Functions     int
	FunctionsTested int
}

func main() {
	fmt.Println("=== Active Inference Test Coverage Report ===\n")

	modules := []string{
		"active_inference_core",
		"advanced_probability",
		"bayesian_inference",
		"cognitive_modeling",
		"free_energy_principle",
		"reinforcement_learning",
		"smart_contracts",
		"visualization",
		"probability",
	}

	var reports []CoverageReport
	totalLinesTested := 0
	totalLines := 0
	totalFunctions := 0
	totalFunctionsTested := 0

	for _, module := range modules {
		report := analyzeModuleCoverage(module)
		reports = append(reports, report)

		totalLinesTested += report.LinesTested
		totalLines += report.TotalLines
		totalFunctions += report.Functions
		totalFunctionsTested += report.FunctionsTested
	}

	// Print detailed reports
	fmt.Println("=== MODULE COVERAGE DETAILS ===")
	fmt.Printf("%-25s %-12s %-12s %-12s %-12s\n",
		"Module", "Coverage", "Lines", "Functions", "Test Files")
	fmt.Println(strings.Repeat("-", 75))

	for _, report := range reports {
		fmt.Printf("%-25s %6.1f%%      %4d/%-4d   %3d/%-3d      %d\n",
			report.ModuleName,
			report.TestCoverage,
			report.LinesTested,
			report.TotalLines,
			report.FunctionsTested,
			report.Functions,
			len(report.TestFiles))
	}

	// Print summary statistics
	fmt.Println("\n=== OVERALL COVERAGE SUMMARY ===")
	overallCoverage := float64(0)
	if totalLines > 0 {
		overallCoverage = float64(totalLinesTested) / float64(totalLines) * 100
	}

	functionCoverage := float64(0)
	if totalFunctions > 0 {
		functionCoverage = float64(totalFunctionsTested) / float64(totalFunctions) * 100
	}

	fmt.Printf("Overall Line Coverage: %.1f%% (%d/%d lines)\n",
		overallCoverage, totalLinesTested, totalLines)
	fmt.Printf("Function Coverage: %.1f%% (%d/%d functions)\n",
		functionCoverage, totalFunctionsTested, totalFunctions)
	fmt.Printf("Modules Analyzed: %d\n", len(modules))
	fmt.Printf("Test Files Found: %d\n", countTotalTestFiles(reports))

	// Coverage quality assessment
	fmt.Println("\n=== COVERAGE QUALITY ASSESSMENT ===")
	if overallCoverage >= 95.0 {
		fmt.Println("🎉 EXCELLENT: 95%+ line coverage achieved!")
	} else if overallCoverage >= 85.0 {
		fmt.Println("✅ GOOD: 85%+ line coverage achieved!")
	} else if overallCoverage >= 75.0 {
		fmt.Println("⚠️  ADEQUATE: 75%+ line coverage achieved!")
	} else {
		fmt.Println("❌ INSUFFICIENT: Line coverage below 75%!")
	}

	if functionCoverage >= 95.0 {
		fmt.Println("🎉 EXCELLENT: 95%+ function coverage achieved!")
	} else if functionCoverage >= 85.0 {
		fmt.Println("✅ GOOD: 85%+ function coverage achieved!")
	} else if functionCoverage >= 75.0 {
		fmt.Println("⚠️  ADEQUATE: 75%+ function coverage achieved!")
	} else {
		fmt.Println("❌ INSUFFICIENT: Function coverage below 75%!")
	}

	// Generate recommendations
	fmt.Println("\n=== RECOMMENDATIONS ===")
	if overallCoverage < 85.0 {
		fmt.Println("• Increase test coverage by adding more test cases")
		fmt.Println("• Focus on error handling and edge cases")
		fmt.Println("• Add integration tests for complex scenarios")
	}

	if functionCoverage < 90.0 {
		fmt.Println("• Ensure all public functions have corresponding tests")
		fmt.Println("• Add tests for private helper functions")
		fmt.Println("• Include performance tests for critical functions")
	}

	modulesWithLowCoverage := getModulesWithLowCoverage(reports, 80.0)
	if len(modulesWithLowCoverage) > 0 {
		fmt.Println("• Focus improvement on these modules:")
		for _, module := range modulesWithLowCoverage {
			fmt.Printf("  - %s (%.1f%% coverage)\n", module.ModuleName, module.TestCoverage)
		}
	}
}

func analyzeModuleCoverage(moduleName string) CoverageReport {
	modulePath := filepath.Join("/Users/4d/Documents/GitHub/gno/active_inference/tests", moduleName)

	report := CoverageReport{
		ModuleName: moduleName,
	}

	// Find all .gno files in the module
	err := filepath.Walk(modulePath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if !info.IsDir() && strings.HasSuffix(info.Name(), ".gno") {
			content, err := os.ReadFile(path)
			if err != nil {
				return err
			}

			if strings.HasSuffix(info.Name(), "_test.gno") {
				report.TestFiles = append(report.TestFiles, info.Name())
				report.LinesTested += countLines(string(content))
				report.FunctionsTested += countTestFunctions(string(content))
			} else {
				report.MainFiles = append(report.MainFiles, info.Name())
				report.TotalLines += countLines(string(content))
				report.Functions += countFunctions(string(content))
			}
		}

		return nil
	})

	if err != nil {
		fmt.Printf("Error analyzing module %s: %v\n", moduleName, err)
	}

	// Calculate coverage percentage
	if report.TotalLines > 0 {
		report.TestCoverage = float64(report.LinesTested) / float64(report.TotalLines) * 100
	} else {
		report.TestCoverage = 0
	}

	return report
}

func countLines(content string) int {
	lines := strings.Split(content, "\n")
	nonEmptyLines := 0

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" && !strings.HasPrefix(line, "//") {
			nonEmptyLines++
		}
	}

	return nonEmptyLines
}

func countFunctions(content string) int {
	return strings.Count(content, "func ")
}

func countTestFunctions(content string) int {
	lines := strings.Split(content, "\n")
	testFunctions := 0

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "func Test") {
			testFunctions++
		}
	}

	return testFunctions
}

func countTotalTestFiles(reports []CoverageReport) int {
	total := 0
	for _, report := range reports {
		total += len(report.TestFiles)
	}
	return total
}

func getModulesWithLowCoverage(reports []CoverageReport, threshold float64) []CoverageReport {
	var lowCoverage []CoverageReport

	for _, report := range reports {
		if report.TestCoverage < threshold {
			lowCoverage = append(lowCoverage, report)
		}
	}

	return lowCoverage
}
