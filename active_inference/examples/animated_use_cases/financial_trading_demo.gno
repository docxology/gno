// Package financial_trading_demo demonstrates an animated Active Inference system
// for financial trading and risk management
package financial_trading_demo

import (
	"gno.land/p/active_inference/methods/active_inference_core"
	"gno.land/p/active_inference/methods/reinforcement_learning"
	"gno.land/p/active_inference/methods/visualization"
	"gno.land/p/active_inference/methods"
)

// FinancialTradingDemo showcases intelligent trading agents
type FinancialTradingDemo struct {
	*visualization.AnimationEngine
	tradingAgent    *active_inference_core.ActiveInferenceAgent
	rlAgent        *reinforcement_learning.QLearningAgent
	marketHistory   []MarketState
	tradingDecisions []TradingDecision
	portfolio       Portfolio
}

// MarketState represents market conditions at a point in time
type MarketState struct {
	Price         methods.Probability // Normalized price (0-1)
	Volume        methods.Probability // Normalized volume (0-1)
	Volatility    methods.Probability // Market volatility (0-1)
	Sentiment     methods.Probability // Market sentiment (-1 to 1, normalized 0-1)
	TimeStep      int
}

// TradingDecision represents a trading action
type TradingDecision struct {
	Action       string // "buy", "sell", "hold"
	Quantity     methods.Probability
	Confidence   methods.Probability
	ExpectedReturn methods.Probability
	TimeStep     int
}

// Portfolio represents trading portfolio state
type Portfolio struct {
	Cash         methods.Probability
	Assets       methods.Probability
	TotalValue   methods.Probability
	RiskLevel    methods.Probability
}

// NewFinancialTradingDemo creates a new financial trading demonstration
func NewFinancialTradingDemo() *FinancialTradingDemo {
	demo := &FinancialTradingDemo{
		AnimationEngine: visualization.NewAnimationEngine(),
		marketHistory:   make([]MarketState, 0),
		tradingDecisions: make([]TradingDecision, 0),
		portfolio: Portfolio{
			Cash:       1.0, // Start with normalized cash
			Assets:     0.0,
			TotalValue: 1.0,
			RiskLevel:  0.5,
		},
	}

	// Initialize trading agents
	demo.initializeAgents()

	return demo
}

// initializeAgents sets up the cognitive and reinforcement learning agents
func (ftd *FinancialTradingDemo) initializeAgents() {
	// Initialize Active Inference agent for market perception and planning
	ftd.tradingAgent = active_inference_core.NewActiveInferenceAgent()

	// Initialize Q-learning agent for action selection
	actions := []string{"buy", "sell", "hold", "reduce_risk", "increase_risk"}
	ftd.rlAgent = reinforcement_learning.NewQLearningAgent(actions)
}

// SimulateMarketDay simulates one day of market activity
func (ftd *FinancialTradingDemo) SimulateMarketDay(marketState MarketState) {
	ftd.marketHistory = append(ftd.marketHistory, marketState)

	// Agent perceives market conditions
	observation := []methods.Probability{
		marketState.Price,
		marketState.Volume,
		marketState.Volatility,
		marketState.Sentiment,
	}

	err := ftd.tradingAgent.Perceive(observation)
	if err != nil {
		println("Perception error:", err.Error())
		return
	}

	// Agent plans trading strategy
	policies, err := ftd.tradingAgent.Plan()
	if err != nil {
		println("Planning error:", err.Error())
		return
	}

	// Use RL agent to select best action based on current state
	stateKey := ftd.createStateKey(marketState)
	bestAction := ftd.rlAgent.GetBestAction(stateKey)

	// Execute trading decision
	decision := ftd.makeTradingDecision(bestAction, marketState)
	ftd.tradingDecisions = append(ftd.tradingDecisions, decision)

	// Update portfolio based on decision
	ftd.updatePortfolio(decision, marketState)

	// Execute action in Active Inference agent
	actionIndex := ftd.actionToIndex(bestAction)
	err = ftd.tradingAgent.Act(actionIndex)
	if err != nil {
		println("Action execution error:", err.Error())
		return
	}

	// Calculate reward and learn
	reward := ftd.calculateReward(decision, marketState)
	err = ftd.tradingAgent.Learn(reward)
	if err != nil {
		println("Learning error:", err.Error())
		return
	}

	// Update RL agent
	ftd.rlAgent.UpdateQValue(stateKey, bestAction, reward)
}

// createStateKey creates a discrete state representation for RL
func (ftd *FinancialTradingDemo) createStateKey(state MarketState) string {
	// Discretize continuous values into states
	priceState := "low"
	if state.Price > 0.6 {
		priceState = "high"
	} else if state.Price > 0.4 {
		priceState = "medium"
	}

	volatilityState := "low"
	if state.Volatility > 0.6 {
		volatilityState = "high"
	} else if state.Volatility > 0.4 {
		volatilityState = "medium"
	}

	sentimentState := "negative"
	if state.Sentiment > 0.6 {
		sentimentState = "positive"
	} else if state.Sentiment > 0.4 {
		sentimentState = "neutral"
	}

	return priceState + "_" + volatilityState + "_" + sentimentState
}

// makeTradingDecision creates a trading decision based on action
func (ftd *FinancialTradingDemo) makeTradingDecision(action string, marketState MarketState) TradingDecision {
	decision := TradingDecision{
		Action:   action,
		TimeStep: len(ftd.marketHistory),
	}

	switch action {
	case "buy":
		decision.Quantity = 0.2 // Buy 20% of available cash
		decision.ExpectedReturn = marketState.Sentiment * 0.8
		decision.Confidence = marketState.Volatility * 0.5 + 0.5
	case "sell":
		decision.Quantity = 0.3 // Sell 30% of assets
		decision.ExpectedReturn = (1 - marketState.Sentiment) * 0.6
		decision.Confidence = marketState.Volatility * 0.7 + 0.3
	case "hold":
		decision.Quantity = 0.0
		decision.ExpectedReturn = 0.5
		decision.Confidence = 0.8
	case "reduce_risk":
		decision.Quantity = -0.1 // Small sell to reduce risk
		decision.ExpectedReturn = 0.4
		decision.Confidence = 0.9
	case "increase_risk":
		decision.Quantity = 0.1 // Small buy to increase risk
		decision.ExpectedReturn = marketState.Sentiment * 0.6
		decision.Confidence = marketState.Volatility * 0.4 + 0.6
	}

	return decision
}

// updatePortfolio updates portfolio based on trading decision
func (ftd *FinancialTradingDemo) updatePortfolio(decision TradingDecision, marketState MarketState) {
	switch decision.Action {
	case "buy":
		// Buy assets with available cash
		buyAmount := ftd.portfolio.Cash * decision.Quantity
		if buyAmount > 0 {
			ftd.portfolio.Cash -= buyAmount
			ftd.portfolio.Assets += buyAmount / marketState.Price
		}
	case "sell":
		// Sell assets
		sellAmount := ftd.portfolio.Assets * decision.Quantity
		if sellAmount > 0 {
			ftd.portfolio.Assets -= sellAmount
			ftd.portfolio.Cash += sellAmount * marketState.Price
		}
	case "reduce_risk":
		// Small sell to reduce position
		sellAmount := ftd.portfolio.Assets * 0.1
		if sellAmount > 0 {
			ftd.portfolio.Assets -= sellAmount
			ftd.portfolio.Cash += sellAmount * marketState.Price
		}
	case "increase_risk":
		// Small buy to increase position
		buyAmount := ftd.portfolio.Cash * 0.1
		if buyAmount > 0 {
			ftd.portfolio.Cash -= buyAmount
			ftd.portfolio.Assets += buyAmount / marketState.Price
		}
	}

	// Update total value and risk
	ftd.portfolio.TotalValue = ftd.portfolio.Cash + (ftd.portfolio.Assets * marketState.Price)

	// Adjust risk level based on market conditions and portfolio
	marketRisk := marketState.Volatility
	positionRisk := ftd.portfolio.Assets / (ftd.portfolio.Assets + ftd.portfolio.Cash + 0.001) // Avoid division by zero
	ftd.portfolio.RiskLevel = (marketRisk + positionRisk) / 2
}

// calculateReward computes reward for the trading decision
func (ftd *FinancialTradingDemo) calculateReward(decision TradingDecision, marketState MarketState) methods.Probability {
	// Reward based on portfolio performance and decision quality
	portfolioChange := ftd.portfolio.TotalValue - 1.0 // Change from initial value

	// Risk-adjusted reward
	riskPenalty := ftd.portfolio.RiskLevel * 0.2
	expectedReward := decision.ExpectedReturn * decision.Confidence

	totalReward := portfolioChange*0.7 + expectedReward*0.3 - riskPenalty

	// Normalize to 0-1 range
	if totalReward < 0 {
		totalReward = 0
	} else if totalReward > 1 {
		totalReward = 1
	}

	return methods.Probability(totalReward)
}

// actionToIndex converts action string to index for Active Inference
func (ftd *FinancialTradingDemo) actionToIndex(action string) int {
	switch action {
	case "buy":
		return 0
	case "sell":
		return 1
	case "hold":
		return 2
	case "reduce_risk":
		return 3
	case "increase_risk":
		return 4
	default:
		return 2 // default to hold
	}
}

// AnimateTradingPerformance creates an animation of trading performance over time
func (ftd *FinancialTradingDemo) AnimateTradingPerformance() []string {
	frames := make([]string, 0)

	if len(ftd.marketHistory) == 0 {
		return frames
	}

	// Create frames for each trading day
	for i := 0; i < len(ftd.marketHistory); i++ {
		marketState := ftd.marketHistory[i]

		var decision TradingDecision
		if i < len(ftd.tradingDecisions) {
			decision = ftd.tradingDecisions[i]
		}

		frame := ftd.createTradingFrame(marketState, decision, i)
		frames = append(frames, frame)
	}

	return frames
}

// createTradingFrame creates a single frame of the trading animation
func (ftd *FinancialTradingDemo) createTradingFrame(marketState MarketState, decision TradingDecision, frameIndex int) string {
	result := "📈 AI Financial Trading Agent - Day " + string(frameIndex+1) + "\n"
	result += "═══════════════════════════════════════════════\n\n"

	// Market conditions
	result += "🌍 Market Conditions:\n"
	result += "   Price:      " + ftd.createProgressBar(marketState.Price, 20) + " " + string(int(marketState.Price*100)) + "%\n"
	result += "   Volume:     " + ftd.createProgressBar(marketState.Volume, 20) + " " + string(int(marketState.Volume*100)) + "%\n"
	result += "   Volatility: " + ftd.createProgressBar(marketState.Volatility, 20) + " " + string(int(marketState.Volatility*100)) + "%\n"
	result += "   Sentiment:  " + ftd.createProgressBar(marketState.Sentiment, 20) + " " + string(int(marketState.Sentiment*100)) + "%\n"

	result += "\n🤖 AI Trading Decision:\n"
	if decision.Action != "" {
		result += "   Action:     " + decision.Action + "\n"
		result += "   Quantity:   " + string(int(decision.Quantity*100)) + "%\n"
		result += "   Confidence: " + ftd.createProgressBar(decision.Confidence, 15) + " " + string(int(decision.Confidence*100)) + "%\n"
		result += "   Exp. Return: " + string(int(decision.ExpectedReturn*100)) + "%\n"
	} else {
		result += "   Action:     Analyzing market...\n"
		result += "   Quantity:   --\n"
		result += "   Confidence: --\n"
		result += "   Exp. Return: --\n"
	}

	result += "\n💼 Portfolio Status:\n"
	result += "   Cash:       $" + string(int(ftd.portfolio.Cash*1000)) + "\n"
	result += "   Assets:     " + string(int(ftd.portfolio.Assets*100)) + " units\n"
	result += "   Total Value: $" + string(int(ftd.portfolio.TotalValue*1000)) + "\n"
	result += "   Risk Level: " + ftd.createProgressBar(ftd.portfolio.RiskLevel, 15) + " " + string(int(ftd.portfolio.RiskLevel*100)) + "%\n"

	// Performance indicator
	if ftd.portfolio.TotalValue > 1.05 {
		result += "\n📊 Performance: 🟢 PROFITABLE (+" + string(int((ftd.portfolio.TotalValue-1.0)*100)) + "%)\n"
	} else if ftd.portfolio.TotalValue < 0.95 {
		result += "\n📊 Performance: 🔴 LOSS (+" + string(int((ftd.portfolio.TotalValue-1.0)*100)) + "%)\n"
	} else {
		result += "\n📊 Performance: 🟡 NEUTRAL (+" + string(int((ftd.portfolio.TotalValue-1.0)*100)) + "%)\n"
	}

	result += "\n🧠 AI Insights:\n"

	// Provide trading insights based on market conditions
	if marketState.Volatility > 0.7 {
		result += "   ⚠️  High market volatility detected\n"
	}
	if marketState.Sentiment > 0.7 {
		result += "   📈 Bullish market sentiment\n"
	} else if marketState.Sentiment < 0.3 {
		result += "   📉 Bearish market sentiment\n"
	}
	if ftd.portfolio.RiskLevel > 0.8 {
		result += "   🚨 High portfolio risk - consider risk reduction\n"
	}

	return result
}

// createProgressBar creates a visual progress bar
func (ftd *FinancialTradingDemo) createProgressBar(value methods.Probability, width int) string {
	filled := int(float64(width) * float64(value))
	bar := ""
	for i := 0; i < filled; i++ {
		bar += "█"
	}
	for i := filled; i < width; i++ {
		bar += "░"
	}
	return bar
}

// RunFinancialTradingDemo demonstrates the financial trading system
func RunFinancialTradingDemo() {
	println("📈 Starting AI Financial Trading Demo")

	demo := NewFinancialTradingDemo()

	// Simulate market conditions over 10 trading days
	marketScenarios := []MarketState{
		// Day 1: Bullish start
		{Price: 0.6, Volume: 0.7, Volatility: 0.3, Sentiment: 0.8, TimeStep: 1},
		// Day 2: Continued growth
		{Price: 0.7, Volume: 0.8, Volatility: 0.2, Sentiment: 0.9, TimeStep: 2},
		// Day 3: High volatility event
		{Price: 0.5, Volume: 0.9, Volatility: 0.8, Sentiment: 0.3, TimeStep: 3},
		// Day 4: Recovery
		{Price: 0.6, Volume: 0.6, Volatility: 0.5, Sentiment: 0.6, TimeStep: 4},
		// Day 5: Consolidation
		{Price: 0.6, Volume: 0.4, Volatility: 0.2, Sentiment: 0.7, TimeStep: 5},
		// Day 6: Bearish turn
		{Price: 0.4, Volume: 0.7, Volatility: 0.6, Sentiment: 0.2, TimeStep: 6},
		// Day 7: Continued decline
		{Price: 0.3, Volume: 0.8, Volatility: 0.7, Sentiment: 0.1, TimeStep: 7},
		// Day 8: Bottom formation
		{Price: 0.3, Volume: 0.5, Volatility: 0.4, Sentiment: 0.4, TimeStep: 8},
		// Day 9: Reversal signal
		{Price: 0.4, Volume: 0.6, Volatility: 0.3, Sentiment: 0.6, TimeStep: 9},
		// Day 10: Recovery phase
		{Price: 0.5, Volume: 0.7, Volatility: 0.4, Sentiment: 0.7, TimeStep: 10},
	}

	// Simulate trading days
	for _, marketState := range marketScenarios {
		demo.SimulateMarketDay(marketState)
	}

	// Generate animation
	frames := demo.AnimateTradingPerformance()

	println("🎬 Generated", len(frames), "trading performance frames")

	// Display key frames
	keyDays := []int{0, 2, 6, 9} // Show diverse market conditions
	for _, dayIndex := range keyDays {
		if dayIndex < len(frames) {
			println("\n--- Trading Day", dayIndex+1, "---")
			println(frames[dayIndex])
		}
	}

	// Final portfolio summary
	finalValue := demo.portfolio.TotalValue
	initialValue := methods.Probability(1.0)
	returnPct := (finalValue - initialValue) / initialValue * 100

	println("\n🏁 Final Portfolio Summary:")
	println("Initial Value: $1000")
	println("Final Value:   $" + string(int(finalValue*1000)))
	println("Return:        " + string(int(returnPct)) + "%")
	println("Risk Level:    " + string(int(demo.portfolio.RiskLevel*100)) + "%")
	println("Total Trades:  " + string(len(demo.tradingDecisions)))

	// Performance analysis
	if returnPct > 5 {
		println("🎉 Excellent performance! AI trading agent profitable.")
	} else if returnPct > -5 {
		println("🤔 Neutral performance. AI avoided major losses.")
	} else {
		println("📉 Challenging market conditions. AI minimized losses.")
	}

	println("\n✅ Financial Trading Demo Complete!")
	println("This demonstrates how AI can:")
	println("• Adapt to changing market conditions")
	println("• Balance risk and reward in trading decisions")
	println("• Learn from experience to improve performance")
	println("• Make confident decisions under uncertainty")
}

// Main execution
func main() {
	RunFinancialTradingDemo()
}
