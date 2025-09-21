// Package cognitive_visualization provides visualization methods for cognitive models
// and active inference results on the Gno blockchain.
//
// This package generates text-based visualizations, JSON representations, and
// structured data formats suitable for blockchain storage and analysis.
package cognitive_visualization

import (
	"math"
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
)

// Simple string repeat function (Gno doesn't have strings.Repeat)
func repeatString(s string, count int) string {
	result := ""
	for i := 0; i < count; i++ {
		result += s
	}
	return result
}

// VisualizationEngine manages different visualization formats
type VisualizationEngine struct {
	OutputFormat string // "text", "json", "ascii"
	MaxWidth     int
	MaxHeight    int
}

// NewVisualizationEngine creates a new visualization engine
func NewVisualizationEngine() *VisualizationEngine {
	return &VisualizationEngine{
		OutputFormat: "text",
		MaxWidth:     80,
		MaxHeight:    25,
	}
}

// ProbabilityDistributionVisualizer visualizes probability distributions
type ProbabilityDistributionVisualizer struct {
	*VisualizationEngine
}

// NewProbabilityDistributionVisualizer creates a new distribution visualizer
func NewProbabilityDistributionVisualizer() *ProbabilityDistributionVisualizer {
	return &ProbabilityDistributionVisualizer{
		VisualizationEngine: NewVisualizationEngine(),
	}
}

// VisualizeCategorical creates a text visualization of a categorical distribution
func (pdv *ProbabilityDistributionVisualizer) VisualizeCategorical(
	probs []methods.Probability,
	labels []string) string {

	if len(probs) != len(labels) {
		return "Error: Probability and label arrays must have same length"
	}

	result := "Categorical Distribution\n"
	result += "======================\n\n"

	maxProb := methods.Probability(0)
	for _, prob := range probs {
		if prob > maxProb {
			maxProb = prob
		}
	}

	for i, prob := range probs {
		label := labels[i]
		percentage := prob * 100
		barLength := int((prob / maxProb) * methods.Probability(pdv.MaxWidth-20))

		result += ufmt.Sprintf("%-12s: %5.1f%% ", label, percentage)

		// Create ASCII bar
		for j := 0; j < barLength; j++ {
			result += "█"
		}
		result += "\n"
	}

	result += "\nStatistics:\n"
	result += ufmt.Sprintf("  Mean: %.3f\n", calculateMean(probs))
	result += ufmt.Sprintf("  Variance: %.3f\n", calculateVariance(probs))
	result += ufmt.Sprintf("  Entropy: %.3f\n", calculateEntropy(probs))

	return result
}

// VisualizeGaussian creates a text visualization of a Gaussian distribution
func (pdv *ProbabilityDistributionVisualizer) VisualizeGaussian(
	mean, stdDev methods.Probability,
	xMin, xMax methods.Probability,
	numPoints int) string {

	result := "Gaussian Distribution\n"
	result += "====================\n"
	result += ufmt.Sprintf("Mean: %.3f, StdDev: %.3f\n\n", mean, stdDev)

	// Generate points for visualization
	step := (xMax - xMin) / methods.Probability(numPoints-1)
	points := make([]methods.Probability, numPoints)
	pdfValues := make([]methods.Probability, numPoints)

	maxPDF := methods.Probability(0)
	for i := 0; i < numPoints; i++ {
		x := xMin + methods.Probability(i)*step
		points[i] = x

		// Calculate PDF: (1/(σ√(2π))) * exp(-0.5*((x-μ)/σ)²)
		diff := x - mean
		exponent := -0.5 * diff * diff / (stdDev * stdDev)
		pdf := methods.Probability(1.0 / (float64(stdDev) * 2.506628)) * methods.Probability(math.Exp(float64(exponent)))
		pdfValues[i] = pdf

		if pdf > maxPDF {
			maxPDF = pdf
		}
	}

	// Create ASCII plot
	height := 10
	for h := height; h >= 0; h-- {
		yLevel := maxPDF * methods.Probability(h) / methods.Probability(height)

		result += ufmt.Sprintf("%6.3f │", yLevel)

		for _, pdf := range pdfValues {
			if pdf >= yLevel {
				result += "█"
			} else {
				result += " "
			}
		}
		result += "\n"
	}

	// X-axis
	result += "       └" + repeatString("─", numPoints) + "\n"
	result += "        "
	for i := 0; i < numPoints; i += numPoints/4 {
		result += ufmt.Sprintf("%.1f", points[i])
		if i+numPoints/4 < numPoints {
			result += repeatString(" ", numPoints/4-3)
		}
	}

	return result
}

// NetworkVisualizer visualizes Bayesian networks and inference results
type NetworkVisualizer struct {
	*VisualizationEngine
}

// NewNetworkVisualizer creates a new network visualizer
func NewNetworkVisualizer() *NetworkVisualizer {
	return &NetworkVisualizer{
		VisualizationEngine: NewVisualizationEngine(),
	}
}

// VisualizeInferenceResults shows the results of Bayesian inference
func (nv *NetworkVisualizer) VisualizeInferenceResults(
	query map[string]string,
	evidence map[string]string,
	results map[string]methods.Probability) string {

	result := "Bayesian Inference Results\n"
	result += "=========================\n\n"

	result += "Query Variables:\n"
	for varName := range query {
		result += ufmt.Sprintf("  %s\n", varName)
	}

	result += "\nEvidence:\n"
	for varName, value := range evidence {
		result += ufmt.Sprintf("  %s = %s\n", varName, value)
	}

	result += "\nResults:\n"
	result += "Variable   │ Value    │ Probability\n"
	result += "───────────┼──────────┼────────────\n"

	for varName := range query {
		maxProb := methods.Probability(0)
		bestValue := ""

		for value, prob := range results {
			if prob > maxProb {
				maxProb = prob
				bestValue = value
			}
		}

		result += ufmt.Sprintf("%-10s │ %-8s │ %7.3f\n", varName, bestValue, maxProb)
	}

	// Show full probability distribution
	result += "\nFull Probability Distribution:\n"
	for value, prob := range results {
		percentage := prob * 100
		barLength := int(prob * methods.Probability(30))

		result += ufmt.Sprintf("%-8s: %5.1f%% ", value, percentage)
		for i := 0; i < barLength; i++ {
			result += "█"
		}
		result += "\n"
	}

	return result
}

// CognitiveModelVisualizer visualizes cognitive model states and processes
type CognitiveModelVisualizer struct {
	*VisualizationEngine
}

// NewCognitiveModelVisualizer creates a new cognitive model visualizer
func NewCognitiveModelVisualizer() *CognitiveModelVisualizer {
	return &CognitiveModelVisualizer{
		VisualizationEngine: NewVisualizationEngine(),
	}
}

// VisualizeWorkingMemory shows the current state of working memory
func (cmv *CognitiveModelVisualizer) VisualizeWorkingMemory(
	contents [][]methods.Probability,
	capacity int) string {

	result := "Working Memory State\n"
	result += "===================\n"
	result += ufmt.Sprintf("Capacity: %d/%d\n\n", len(contents), capacity)

	if len(contents) == 0 {
		result += "Working memory is empty\n"
		return result
	}

	result += "Memory Contents:\n"
	for i, memory := range contents {
		result += ufmt.Sprintf("  [%d]: ", i)
		for j, val := range memory {
			if j > 0 {
				result += ", "
			}
			result += ufmt.Sprintf("%.3f", val)
		}
		result += "\n"
	}

	// Show memory statistics
	result += "\nStatistics:\n"
	totalItems := len(contents)
	if totalItems > 0 {
		avgStrength := methods.Probability(0)
		for _, memory := range contents {
			for _, val := range memory {
				avgStrength += val
			}
		}
		avgStrength /= methods.Probability(totalItems * len(contents[0]))

		result += ufmt.Sprintf("  Average memory strength: %.3f\n", avgStrength)
		result += ufmt.Sprintf("  Memory utilization: %.1f%%\n", float64(totalItems)/float64(capacity)*100)
	}

	return result
}

// VisualizeAttentionWeights shows attention allocation across different stimuli
func (cmv *CognitiveModelVisualizer) VisualizeAttentionWeights(
	weights []methods.Probability,
	stimuliLabels []string) string {

	result := "Attention Weights\n"
	result += "=================\n\n"

	if len(weights) != len(stimuliLabels) {
		result += "Error: Weights and labels must have same length\n"
		return result
	}

	totalAttention := methods.Probability(0)
	for _, weight := range weights {
		totalAttention += weight
	}

	result += "Stimulus         │ Weight    │ Percentage\n"
	result += "─────────────────┼───────────┼───────────\n"

	for i, weight := range weights {
		label := stimuliLabels[i]
		percentage := methods.Probability(0)
		if totalAttention > 0 {
			percentage = (weight / totalAttention) * 100
		}

		result += ufmt.Sprintf("%-16s │ %7.3f   │ %6.1f%%\n", label, weight, percentage)
	}

	result += "─────────────────┼───────────┼───────────\n"
	result += ufmt.Sprintf("Total            │ %7.3f   │ 100.0%%\n", totalAttention)

	// Show attention distribution
	result += "\nAttention Distribution:\n"
	maxWeight := methods.Probability(0)
	for _, weight := range weights {
		if weight > maxWeight {
			maxWeight = weight
		}
	}

	for i, weight := range weights {
		label := stimuliLabels[i]
		barLength := int((weight / maxWeight) * methods.Probability(40))

		result += ufmt.Sprintf("%-16s │ ", label)
		for j := 0; j < barLength; j++ {
			result += "█"
		}
		result += ufmt.Sprintf(" %.3f\n", weight)
	}

	return result
}

// VisualizeBeliefUpdate shows how beliefs change over time
func (cmv *CognitiveModelVisualizer) VisualizeBeliefUpdate(
	oldBeliefs, newBeliefs []methods.Probability,
	beliefLabels []string) string {

	result := "Belief Update Visualization\n"
	result += "==========================\n\n"

	if len(oldBeliefs) != len(newBeliefs) || len(newBeliefs) != len(beliefLabels) {
		result += "Error: All arrays must have same length\n"
		return result
	}

	result += "Belief          │ Old      │ New      │ Change\n"
	result += "────────────────┼──────────┼──────────┼────────\n"

	totalChange := methods.Probability(0)
	for i := range oldBeliefs {
		label := beliefLabels[i]
		old := oldBeliefs[i]
		new := newBeliefs[i]
		change := new - old
		totalChange += change

		changeSymbol := ""
		if change > 0 {
			changeSymbol = "↗"
		} else if change < 0 {
			changeSymbol = "↘"
		} else {
			changeSymbol = "→"
		}

		result += ufmt.Sprintf("%-15s │ %7.3f │ %7.3f │ %6.3f %s\n",
			label, old, new, change, changeSymbol)
	}

	result += "────────────────┼──────────┼──────────┼────────\n"
	result += ufmt.Sprintf("Total Change    │          │          │ %6.3f\n", totalChange)

	// Show convergence information
	converged := true
	for i := range oldBeliefs {
		if abs(newBeliefs[i]-oldBeliefs[i]) > 0.01 {
			converged = false
			break
		}
	}

	if converged {
		result += "\n✓ Beliefs have converged\n"
	} else {
		result += "\n⟳ Beliefs are still updating\n"
	}

	return result
}

// VisualizeDecisionProcess shows the decision-making process
func (cmv *CognitiveModelVisualizer) VisualizeDecisionProcess(
	options []string,
	expectedFreeEnergies []methods.Probability,
	selectedOption int) string {

	result := "Decision Process Visualization\n"
	result += "==============================\n\n"

	if len(options) != len(expectedFreeEnergies) {
		result += "Error: Options and free energies must have same length\n"
		return result
	}

	result += "Decision Options:\n"
	minEFE := expectedFreeEnergies[0]
	maxEFE := expectedFreeEnergies[0]

	for _, efe := range expectedFreeEnergies {
		if efe < minEFE {
			minEFE = efe
		}
		if efe > maxEFE {
			maxEFE = efe
		}
	}

	for i, option := range options {
		efe := expectedFreeEnergies[i]
		isSelected := ""
		if i == selectedOption {
			isSelected = " ← SELECTED"
		}

		// Create EFE bar (lower EFE is better)
		efeRange := maxEFE - minEFE
		if efeRange > 0 {
			normalizedEFE := (efe - minEFE) / efeRange
			barLength := int((1 - normalizedEFE) * methods.Probability(30)) // Invert so lower EFE has longer bar
			result += ufmt.Sprintf("%-20s │ EFE: %7.3f │ ", option, efe)
			for j := 0; j < barLength; j++ {
				result += "█"
			}
			result += isSelected + "\n"
		} else {
			result += ufmt.Sprintf("%-20s │ EFE: %7.3f%s\n", option, efe, isSelected)
		}
	}

	result += "\nDecision Criteria:\n"
	result += ufmt.Sprintf("  Selected Option: %s\n", options[selectedOption])
	result += ufmt.Sprintf("  Expected Free Energy: %.3f\n", expectedFreeEnergies[selectedOption])

	// Show ranking
	result += "\nOption Ranking (by EFE):\n"
	type optionScore struct {
		index int
		score methods.Probability
	}

	scores := make([]optionScore, len(options))
	for i, efe := range expectedFreeEnergies {
		scores[i] = optionScore{i, efe}
	}

	// Sort by EFE (lower is better)
	for i := 0; i < len(scores)-1; i++ {
		for j := i + 1; j < len(scores); j++ {
			if scores[j].score < scores[i].score {
				scores[i], scores[j] = scores[j], scores[i]
			}
		}
	}

	for rank, score := range scores {
		rankIndicator := ""
		if rank == 0 {
			rankIndicator = " 🥇"
		} else if rank == 1 {
			rankIndicator = " 🥈"
		} else if rank == 2 {
			rankIndicator = " 🥉"
		}

		result += ufmt.Sprintf("  %d. %s (EFE: %.3f)%s\n",
			rank+1, options[score.index], score.score, rankIndicator)
	}

	return result
}

// TimeSeriesVisualizer shows how variables change over time
type TimeSeriesVisualizer struct {
	*VisualizationEngine
}

// NewTimeSeriesVisualizer creates a new time series visualizer
func NewTimeSeriesVisualizer() *TimeSeriesVisualizer {
	return &TimeSeriesVisualizer{
		VisualizationEngine: NewVisualizationEngine(),
	}
}

// VisualizeBeliefEvolution shows how beliefs evolve over multiple time steps
func (tsv *TimeSeriesVisualizer) VisualizeBeliefEvolution(
	beliefHistory [][]methods.Probability,
	timeLabels []string,
	beliefLabels []string) string {

	result := "Belief Evolution Over Time\n"
	result += "==========================\n\n"

	if len(beliefHistory) == 0 {
		result += "No belief history available\n"
		return result
	}

	numBeliefs := len(beliefHistory[0])
	if len(beliefLabels) != numBeliefs {
		result += "Error: Belief labels must match number of beliefs\n"
		return result
	}

	// Show time series for each belief
	for beliefIdx, label := range beliefLabels {
		result += ufmt.Sprintf("\n%s Evolution:\n", label)
		result += "Time     │ Value\n"
		result += "─────────┼───────\n"

		for timeIdx, beliefs := range beliefHistory {
			if beliefIdx < len(beliefs) {
				timeLabel := ""
				if timeIdx < len(timeLabels) {
					timeLabel = timeLabels[timeIdx]
				} else {
					timeLabel = ufmt.Sprintf("t=%d", timeIdx)
				}

				result += ufmt.Sprintf("%-8s │ %5.3f\n", timeLabel, beliefs[beliefIdx])
			}
		}

		// Show trend
		if len(beliefHistory) >= 2 {
			first := beliefHistory[0][beliefIdx]
			last := beliefHistory[len(beliefHistory)-1][beliefIdx]
			trend := last - first

			trendDirection := "→"
			if trend > 0.01 {
				trendDirection = "↗"
			} else if trend < -0.01 {
				trendDirection = "↘"
			}

			result += ufmt.Sprintf("Trend: %s (%.3f change)\n", trendDirection, trend)
		}
	}

	// Show overall belief dynamics
	result += "\nOverall Belief Dynamics:\n"
	result += "Time     │ "
	for _, label := range beliefLabels {
		result += ufmt.Sprintf("%-8s ", label[:min(8, len(label))])
	}
	result += "\n─────────┼─"
	result += strings.Repeat("─────────", len(beliefLabels))
	result += "\n"

	for timeIdx, beliefs := range beliefHistory {
		timeLabel := ""
		if timeIdx < len(timeLabels) {
			timeLabel = timeLabels[timeIdx]
		} else {
			timeLabel = ufmt.Sprintf("t=%d", timeIdx)
		}

		result += ufmt.Sprintf("%-8s │ ", timeLabel)
		for _, belief := range beliefs {
			result += ufmt.Sprintf("%7.3f ", belief)
		}
		result += "\n"
	}

	return result
}

// JSONVisualizer creates JSON representations for external analysis
type JSONVisualizer struct {
	*VisualizationEngine
}

// NewJSONVisualizer creates a new JSON visualizer
func NewJSONVisualizer() *JSONVisualizer {
	return &JSONVisualizer{
		VisualizationEngine: NewVisualizationEngine(),
	}
}

// CreateBeliefStateJSON creates a JSON representation of belief states
func (jv *JSONVisualizer) CreateBeliefStateJSON(
	beliefs []methods.Probability,
	beliefLabels []string) string {

	if len(beliefs) != len(beliefLabels) {
		return `{"error": "Beliefs and labels must have same length"}`
	}

	result := `{
  "belief_state": {
    "timestamp": "current",
    "beliefs": {`

	for i, belief := range beliefs {
		result += ufmt.Sprintf(`
      "%s": %.6f`, beliefLabels[i], belief)
		if i < len(beliefs)-1 {
			result += ","
		}
	}

	result += `
    },
    "statistics": {
      "mean": ` + ufmt.Sprintf("%.6f", calculateMean(beliefs)) + `,
      "variance": ` + ufmt.Sprintf("%.6f", calculateVariance(beliefs)) + `,
      "entropy": ` + ufmt.Sprintf("%.6f", calculateEntropy(beliefs)) + `
    }
  }
}`

	return result
}

// Helper functions
func calculateMean(values []methods.Probability) methods.Probability {
	if len(values) == 0 {
		return 0
	}

	sum := methods.Probability(0)
	for _, val := range values {
		sum += val
	}

	return sum / methods.Probability(len(values))
}

func calculateVariance(values []methods.Probability) methods.Probability {
	if len(values) <= 1 {
		return 0
	}

	mean := calculateMean(values)
	sumSquares := methods.Probability(0)

	for _, val := range values {
		diff := val - mean
		sumSquares += diff * diff
	}

	return sumSquares / methods.Probability(len(values)-1)
}

func calculateEntropy(values []methods.Probability) methods.Probability {
	entropy := methods.Probability(0)

	for _, val := range values {
		if val > 0 {
			entropy -= val * methods.Probability(math.Log(float64(val)))
		}
	}

	return entropy
}

func abs(x methods.Probability) methods.Probability {
	if x < 0 {
		return -x
	}
	return x
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

// =============================================================================
// ADVANCED VISUALIZATION AND ANIMATION METHODS
// =============================================================================

// AnimationEngine creates animated visualizations of cognitive processes
type AnimationEngine struct {
	*VisualizationEngine
	FrameRate   int // frames per second
	Duration    int // animation duration in frames
	CurrentFrame int
}

// NewAnimationEngine creates a new animation engine
func NewAnimationEngine() *AnimationEngine {
	return &AnimationEngine{
		VisualizationEngine: NewVisualizationEngine(),
		FrameRate:          10,
		Duration:           100,
		CurrentFrame:       0,
	}
}

// CognitiveProcessAnimator animates cognitive processes over time
type CognitiveProcessAnimator struct {
	*AnimationEngine
	processHistory [][]CognitiveState
	timeLabels     []string
}

// NewCognitiveProcessAnimator creates a new cognitive process animator
func NewCognitiveProcessAnimator() *CognitiveProcessAnimator {
	return &CognitiveProcessAnimator{
		AnimationEngine: NewAnimationEngine(),
		processHistory:  make([][]CognitiveState, 0),
		timeLabels:      make([]string, 0),
	}
}

// CognitiveState represents a snapshot of cognitive state at a point in time
type CognitiveState struct {
	Beliefs         []methods.Probability
	Attention       []methods.Probability
	FreeEnergy      methods.Probability
	PredictionError []methods.Probability
	TimeStep        int
}

// AddCognitiveState adds a cognitive state to the animation sequence
func (cpa *CognitiveProcessAnimator) AddCognitiveState(state CognitiveState, timeLabel string) {
	cpa.processHistory = append(cpa.processHistory, []CognitiveState{state})
	cpa.timeLabels = append(cpa.timeLabels, timeLabel)
}

// AnimateBeliefEvolution creates an animation of belief evolution over time
func (cpa *CognitiveProcessAnimator) AnimateBeliefEvolution() []string {
	frames := make([]string, 0)

	if len(cpa.processHistory) == 0 {
		return frames
	}

	// Create frames for each time step
	for i, states := range cpa.processHistory {
		if len(states) == 0 {
			continue
		}

		state := states[0] // Use first state in each time step

		// Create belief evolution visualization
		frame := cpa.createBeliefEvolutionFrame(state, cpa.timeLabels[i], i)
		frames = append(frames, frame)
	}

	return frames
}

// createBeliefEvolutionFrame creates a single frame of belief evolution
func (cpa *CognitiveProcessAnimator) createBeliefEvolutionFrame(state CognitiveState, timeLabel string, frameIndex int) string {
	result := ufmt.Sprintf("🎯 Belief Evolution - Frame %d/%d\n", frameIndex+1, len(cpa.processHistory))
	result += ufmt.Sprintf("⏰ Time: %s\n", timeLabel)
	result += ufmt.Sprintf("⚡ Free Energy: %.3f\n\n", state.FreeEnergy)

	// Visualize beliefs as a bar chart
	result += "Beliefs:\n"
	maxBarWidth := 40

	for i, belief := range state.Beliefs {
		barWidth := int(float64(maxBarWidth) * float64(belief))
		bar := repeatString("█", barWidth)
		padding := repeatString("░", maxBarWidth-barWidth)

		result += ufmt.Sprintf("B%d: %s%s %.3f\n", i+1, bar, padding, belief)
	}

	// Visualize attention weights
	if len(state.Attention) > 0 {
		result += "\nAttention:\n"
		for i, attention := range state.Attention {
			if i < len(state.Beliefs) {
				attentionBar := repeatString("●", int(float64(maxBarWidth)*float64(attention)))
				result += ufmt.Sprintf("A%d: %s %.3f\n", i+1, attentionBar, attention)
			}
		}
	}

	// Visualize prediction errors
	if len(state.PredictionError) > 0 {
		result += "\nPrediction Errors:\n"
		for i, error := range state.PredictionError {
			errorBar := repeatString("!", int(absFloat(float64(error))*float64(maxBarWidth)))
			if error < 0 {
				errorBar = repeatString("↓", int(absFloat(float64(error))*float64(maxBarWidth)))
			}
			result += ufmt.Sprintf("E%d: %s %.3f\n", i+1, errorBar, error)
		}
	}

	return result
}

// AnimateDecisionProcess creates an animation of the decision-making process
func (cpa *CognitiveProcessAnimator) AnimateDecisionProcess(options []string, utilities [][]methods.Probability) []string {
	frames := make([]string, 0)

	if len(options) == 0 || len(utilities) == 0 {
		return frames
	}

	// Create frames showing decision evolution
	numFrames := cpa.Duration
	for frame := 0; frame < numFrames; frame++ {
		progress := float64(frame) / float64(numFrames-1)

		frame := cpa.createDecisionFrame(options, utilities, progress, frame)
		frames = append(frames, frame)
	}

	return frames
}

// createDecisionFrame creates a single frame of the decision process
func (cpa *CognitiveProcessAnimator) createDecisionFrame(options []string, utilities [][]methods.Probability, progress float64, frameIndex int) string {
	result := ufmt.Sprintf("🤔 Decision Process - Frame %d/%d (%.1f%%)\n\n",
		frameIndex+1, cpa.Duration, progress*100)

	// Interpolate utilities over time
	currentUtilities := make([]methods.Probability, len(options))
	for i := range currentUtilities {
		if i < len(utilities) && len(utilities[i]) > 0 {
			// Simple interpolation between utility values
			startUtility := utilities[i][0]
			endUtility := utilities[i][len(utilities[i])-1]
			currentUtilities[i] = startUtility + methods.Probability(progress)*methods.Probability(endUtility-startUtility)
		}
	}

	// Find best option
	bestIndex := 0
	bestUtility := currentUtilities[0]
	for i, utility := range currentUtilities {
		if utility > bestUtility {
			bestUtility = utility
			bestIndex = i
		}
	}

	// Visualize options as a decision landscape
	maxBarWidth := 30
	result += "Decision Landscape:\n"

	for i, option := range options {
		if i >= len(currentUtilities) {
			continue
		}

		utility := currentUtilities[i]
		barWidth := int(float64(maxBarWidth) * float64(utility))

		if i == bestIndex {
			bar := repeatString("★", barWidth)
			result += ufmt.Sprintf("🏆 %-15s: %s %.3f\n", option, bar, utility)
		} else {
			bar := repeatString("□", barWidth)
			result += ufmt.Sprintf("   %-15s: %s %.3f\n", option, bar, utility)
		}
	}

	result += "\n💡 Current Best: " + options[bestIndex]
	result += ufmt.Sprintf(" (Utility: %.3f)", bestUtility)

	return result
}

// =============================================================================
// BLOCKCHAIN CONCEPT VISUALIZATIONS
// =============================================================================

// BlockchainVisualizer creates visualizations of blockchain concepts
type BlockchainVisualizer struct {
	*VisualizationEngine
}

// NewBlockchainVisualizer creates a new blockchain visualizer
func NewBlockchainVisualizer() *BlockchainVisualizer {
	return &BlockchainVisualizer{
		VisualizationEngine: NewVisualizationEngine(),
	}
}

// VisualizeTransactionFlow creates an animated visualization of transaction flow
func (bv *BlockchainVisualizer) VisualizeTransactionFlow(transactions []Transaction) []string {
	frames := make([]string, 0)

	if len(transactions) == 0 {
		return frames
	}

	// Create frames showing transaction propagation
	numFrames := 20
	for frame := 0; frame < numFrames; frame++ {
		progress := float64(frame) / float64(numFrames-1)

		frame := bv.createTransactionFlowFrame(transactions, progress, frame)
		frames = append(frames, frame)
	}

	return frames
}

// Transaction represents a blockchain transaction
type Transaction struct {
	ID          string
	From        string
	To          string
	Amount      float64
	GasPrice    uint64
	GasLimit    uint64
	Status      string // "pending", "confirmed", "failed"
	BlockHeight uint64
}

// createTransactionFlowFrame creates a single frame of transaction flow
func (bv *BlockchainVisualizer) createTransactionFlowFrame(transactions []Transaction, progress float64, frameIndex int) string {
	result := ufmt.Sprintf("⛓️ Transaction Flow - Frame %d\n\n", frameIndex+1)

	// Simulate network nodes
	nodes := []string{"Node A", "Node B", "Node C", "Node D", "Validator"}

	result += "Network Topology:\n"
	for i, node := range nodes {
		connections := ""
		for j := 0; j < len(nodes); j++ {
			if i != j {
				if progress > 0.5 {
					connections += "━━━"
				} else {
					connections += "---"
				}
			}
		}
		result += ufmt.Sprintf("%s %s\n", node, connections[:min(20, len(connections))])
	}

	result += "\n📦 Active Transactions:\n"

	for i, tx := range transactions {
		if i >= 5 { // Limit display
			break
		}

		// Simulate transaction progress
		txProgress := (progress + float64(i)*0.2) - float64(int(progress + float64(i)*0.2))

		status := "⏳ Pending"
		if txProgress > 0.5 {
			status = "✅ Confirmed"
		} else if txProgress > 0.8 {
			status = "❌ Failed"
		}

		progressBar := repeatString("█", int(txProgress*20))
		progressBar += repeatString("░", 20-len(progressBar))

		result += ufmt.Sprintf("TX-%s: %s → %s (%.2f GNO) [%s]\n",
			tx.ID, tx.From, tx.To, tx.Amount, status)
		result += ufmt.Sprintf("Progress: %s %.1f%%\n", progressBar, txProgress*100)
	}

	return result
}

// VisualizeConsensusMechanism creates an animation of consensus formation
func (bv *BlockchainVisualizer) VisualizeConsensusMechanism(nodes []ConsensusNode) []string {
	frames := make([]string, 0)

	if len(nodes) == 0 {
		return frames
	}

	// Create frames showing consensus evolution
	numFrames := 30
	for frame := 0; frame < numFrames; frame++ {
		progress := float64(frame) / float64(numFrames-1)

		frame := bv.createConsensusFrame(nodes, progress, frame)
		frames = append(frames, frame)
	}

	return frames
}

// ConsensusNode represents a node in the consensus network
type ConsensusNode struct {
	ID       string
	State    string // "proposing", "voting", "confirmed"
	Votes    int
	Stake    uint64
	IsLeader bool
}

// createConsensusFrame creates a single frame of consensus formation
func (bv *BlockchainVisualizer) createConsensusFrame(nodes []ConsensusNode, progress float64, frameIndex int) string {
	result := ufmt.Sprintf("🔄 Consensus Formation - Frame %d\n\n", frameIndex+1)

	// Calculate consensus progress
	totalVotes := 0
	requiredVotes := len(nodes)*2/3 + 1

	for i := range nodes {
		// Simulate voting progress
		if progress > float64(i)/float64(len(nodes)) {
			if progress > 0.3 {
				nodes[i].State = "voting"
				nodes[i].Votes = int(progress * 10)
			}
			if progress > 0.7 {
				nodes[i].State = "confirmed"
				nodes[i].Votes = int(progress * 15)
			}
			totalVotes += nodes[i].Votes
		}
	}

	// Check if consensus reached
	consensusReached := totalVotes >= requiredVotes

	result += "Consensus Status:\n"
	if consensusReached {
		result += "✅ CONSENSUS REACHED\n"
	} else {
		result += ufmt.Sprintf("⏳ Forming Consensus (%d/%d votes)\n", totalVotes, requiredVotes)
	}

	result += "\n🏛️ Validator Nodes:\n"

	for _, node := range nodes {
		stateIcon := "⏳"
		if node.State == "voting" {
			stateIcon = "🗳️"
		} else if node.State == "confirmed" {
			stateIcon = "✅"
		}

		leaderIcon := ""
		if node.IsLeader {
			leaderIcon = "👑"
		}

		voteBar := repeatString("█", node.Votes)
		voteBar += repeatString("░", 15-len(voteBar))

		result += ufmt.Sprintf("%s %s %s: %s (%d votes)\n",
			stateIcon, leaderIcon, node.ID, voteBar, node.Votes)
	}

	return result
}

// =============================================================================
// COGNITIVE MODEL ANIMATIONS
// =============================================================================

// CognitiveModelAnimator creates animations of cognitive model evolution
type CognitiveModelAnimator struct {
	*AnimationEngine
	modelStates []ModelState
}

// NewCognitiveModelAnimator creates a new cognitive model animator
func NewCognitiveModelAnimator() *CognitiveModelAnimator {
	return &CognitiveModelAnimator{
		AnimationEngine: NewAnimationEngine(),
		modelStates:     make([]ModelState, 0),
	}
}

// ModelState represents the state of a cognitive model at a point in time
type ModelState struct {
	WorkingMemory   []MemoryItem
	LongTermMemory  []MemoryItem
	AttentionFocus  []methods.Probability
	GoalActivation  []methods.Probability
	LearningProgress methods.Probability
	TimeStep        int
}

// MemoryItem represents an item in memory
type MemoryItem struct {
	Content   []methods.Probability
	Strength  methods.Probability
	Age       int
	AccessCount int
}

// AddModelState adds a model state to the animation
func (cma *CognitiveModelAnimator) AddModelState(state ModelState) {
	cma.modelStates = append(cma.modelStates, state)
}

// AnimateMemoryEvolution creates an animation of memory system evolution
func (cma *CognitiveModelAnimator) AnimateMemoryEvolution() []string {
	frames := make([]string, 0)

	if len(cma.modelStates) == 0 {
		return frames
	}

	// Create frames for each model state
	for i, state := range cma.modelStates {
		frame := cma.createMemoryFrame(state, i)
		frames = append(frames, frame)
	}

	return frames
}

// createMemoryFrame creates a single frame of memory evolution
func (cma *CognitiveModelAnimator) createMemoryFrame(state ModelState, frameIndex int) string {
	result := ufmt.Sprintf("🧠 Memory Evolution - Time Step %d\n\n", state.TimeStep)

	// Visualize working memory
	result += "Working Memory:\n"
	for i, item := range state.WorkingMemory {
		if i >= 5 { // Limit display
			break
		}

		strengthBar := repeatString("●", int(float64(10)*float64(item.Strength)))
		contentSummary := ufmt.Sprintf("[%.2f,%.2f,%.2f]",
			item.Content[0], item.Content[1], item.Content[2])

		result += ufmt.Sprintf("  Item %d: %s %s (age: %d, access: %d)\n",
			i+1, strengthBar, contentSummary, item.Age, item.AccessCount)
	}

	// Visualize long-term memory
	result += "\nLong-term Memory:\n"
	for i, item := range state.LongTermMemory {
		if i >= 3 { // Limit display
			break
		}

		strengthBar := repeatString("■", int(float64(8)*float64(item.Strength)))
		result += ufmt.Sprintf("  Memory %d: %s (strength: %.2f)\n",
			i+1, strengthBar, item.Strength)
	}

	// Visualize attention focus
	if len(state.AttentionFocus) > 0 {
		result += "\nAttention Focus:\n"
		for i, focus := range state.AttentionFocus {
			focusBar := repeatString("👁️", int(float64(5)*float64(focus)))
			result += ufmt.Sprintf("  Focus %d: %s %.2f\n", i+1, focusBar, focus)
		}
	}

	// Visualize learning progress
	progressBar := repeatString("📚", int(float64(20)*float64(state.LearningProgress)))
	progressBar += repeatString("📖", 20-len(progressBar))

	result += ufmt.Sprintf("\n📈 Learning Progress: %s %.1f%%\n",
		progressBar, state.LearningProgress*100)

	return result
}

// =============================================================================
// UTILITY FUNCTIONS FOR ADVANCED VISUALIZATIONS
// =============================================================================

// CreateProgressBar creates a visual progress bar
func CreateProgressBar(progress methods.Probability, width int, style string) string {
	filled := int(float64(width) * float64(progress))
	bar := ""

	switch style {
	case "blocks":
		bar = repeatString("█", filled) + repeatString("░", width-filled)
	case "circles":
		bar = repeatString("●", filled) + repeatString("○", width-filled)
	case "stars":
		bar = repeatString("★", filled) + repeatString("☆", width-filled)
	case "arrows":
		bar = repeatString("→", filled) + repeatString("-", width-filled)
	default:
		bar = repeatString("█", filled) + repeatString("░", width-filled)
	}

	return bar
}

// CreateHeatmap creates a simple heatmap visualization
func CreateHeatmap(data [][]methods.Probability, labels []string) string {
	if len(data) == 0 || len(data[0]) == 0 {
		return "No data to visualize"
	}

	result := "Heatmap:\n"

	// Symbols for different intensity levels
	symbols := []string{" ", "░", "▒", "▓", "█"}

	for i, row := range data {
		if i < len(labels) {
			result += labels[i] + ": "
		} else {
			result += ufmt.Sprintf("Row %d: ", i)
		}

		for _, value := range row {
			// Map value to symbol index
			symbolIndex := int(float64(len(symbols)-1) * float64(value))
			if symbolIndex < 0 {
				symbolIndex = 0
			}
			if symbolIndex >= len(symbols) {
				symbolIndex = len(symbols) - 1
			}

			result += symbols[symbolIndex]
		}
		result += "\n"
	}

	return result
}

// CreateTimeSeriesPlot creates a simple time series plot
func CreateTimeSeriesPlot(values []methods.Probability, timeLabels []string, title string) string {
	if len(values) == 0 {
		return "No data to plot"
	}

	result := title + "\n"
	result += repeatString("-", len(title)) + "\n"

	maxValue := methods.Probability(0)
	for _, v := range values {
		if v > maxValue {
			maxValue = v
		}
	}

	height := 10
	width := len(values)

	for y := height - 1; y >= 0; y-- {
		// Y-axis label
		yValue := maxValue * methods.Probability(y) / methods.Probability(height-1)
		result += ufmt.Sprintf("%5.2f │", yValue)

		// Plot points
		for x := 0; x < width && x < len(values); x++ {
			normalizedValue := float64(values[x]) / float64(maxValue)
			plotY := int(normalizedValue * float64(height-1))

			if plotY == y {
				result += "●"
			} else if plotY > y {
				result += "│"
			} else {
				result += " "
			}
		}
		result += "\n"
	}

	// X-axis
	result += "      └" + repeatString("─", width) + "\n"
	result += "       "

	for i := 0; i < width && i < len(timeLabels); i++ {
		if i%5 == 0 { // Label every 5th point
			label := timeLabels[i]
			if len(label) > 3 {
				label = label[:3]
			}
			result += label
			if len(label) < 3 {
				result += repeatString(" ", 3-len(label))
			}
		} else {
			result += "   "
		}
	}

	return result
}

// CreateNetworkGraph creates a simple ASCII network graph
func CreateNetworkGraph(nodes []string, edges map[string][]string) string {
	if len(nodes) == 0 {
		return "No nodes to visualize"
	}

	result := "Network Graph:\n\n"

	// Position nodes in a circle
	centerX, centerY := 20, 10
	radius := 8

	nodePositions := make(map[string][2]int)

	for i, node := range nodes {
		angle := 2 * math.Pi * float64(i) / float64(len(nodes))
		x := centerX + int(float64(radius)*math.Cos(angle))
		y := centerY + int(float64(radius)*math.Sin(angle))
		nodePositions[node] = [2]int{x, y}
	}

	// Create grid
	grid := make([][]string, centerY*2+1)
	for i := range grid {
		grid[i] = make([]string, centerX*2+1)
		for j := range grid[i] {
			grid[i][j] = " "
		}
	}

	// Draw edges
	for from, toNodes := range edges {
		fromPos, fromExists := nodePositions[from]
		if !fromExists {
			continue
		}

		for _, to := range toNodes {
			toPos, toExists := nodePositions[to]
			if !toExists {
				continue
			}

			// Draw line between nodes
			drawLine(grid, fromPos[0], fromPos[1], toPos[0], toPos[1])
		}
	}

	// Draw nodes
	for node, pos := range nodePositions {
		x, y := pos[0], pos[1]
		if y >= 0 && y < len(grid) && x >= 0 && x < len(grid[y]) {
			if len(node) > 0 {
				grid[y][x] = string(node[0])
			} else {
				grid[y][x] = "●"
			}
		}
	}

	// Convert grid to string
	for _, row := range grid {
		result += stringsJoin(row, "") + "\n"
	}

	// Add legend
	result += "\nLegend:\n"
	for i, node := range nodes {
		result += ufmt.Sprintf("%c = %s\n", node[0], node)
	}

	return result
}

// drawLine draws a line between two points on the grid
func drawLine(grid [][]string, x1, y1, x2, y2 int) {
	dx := absInt(x2 - x1)
	dy := absInt(y2 - y1)

	sx := 1
	if x1 > x2 {
		sx = -1
	}
	sy := 1
	if y1 > y2 {
		sy = -1
	}

	err := dx - dy

	for {
		if y1 >= 0 && y1 < len(grid) && x1 >= 0 && x1 < len(grid[y1]) {
			if grid[y1][x1] == " " {
				grid[y1][x1] = "·"
			}
		}

		if x1 == x2 && y1 == y2 {
			break
		}

		e2 := 2 * err
		if e2 > -dy {
			err -= dy
			x1 += sx
		}
		if e2 < dx {
			err += dx
			y1 += sy
		}
	}
}

// absFloat returns absolute value of float64
func absFloat(x float64) float64 {
	if x < 0 {
		return -x
	}
	return x
}

// abs returns absolute value of integer
func absInt(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

// strings.Join implementation for Gno
func stringsJoin(elems []string, sep string) string {
	if len(elems) == 0 {
		return ""
	}

	result := elems[0]
	for i := 1; i < len(elems); i++ {
		result += sep + elems[i]
	}
	return result
}
