// Package financial_trading provides a deployable financial trading agent realm
// for the Gno blockchain. This realm implements risk-aware automated trading
// using Active Inference methods for market analysis and decision-making.
package financial_trading

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
    "std"
    "gno.land/p/nt/ufmt"
    "math"
)

// =============================================================================
// GLOBAL STATE - PERSISTED ACROSS TRANSACTIONS
// =============================================================================

// Core trading agent instance
var tradingAgent *active_inference_core.ActiveInferenceAgent

// Access control
var owner string
var authorizedTraders []string

// Trading history and analytics
var tradeHistory []TradeRecord
var positionHistory []PositionRecord
var marketDataHistory []MarketDataRecord

// Performance metrics
var totalTrades int64
var successfulTrades int64
var totalProfitLoss methods.Probability
var riskMetrics RiskMetrics

// Market state
var currentMarketState MarketState
var portfolioValue methods.Probability

// =============================================================================
// DATA STRUCTURES
// =============================================================================

// TradeRecord tracks individual trades
type TradeRecord struct {
    Timestamp     int64
    Symbol        string
    Action        string  // "BUY", "SELL", "HOLD"
    Quantity      methods.Probability
    Price         methods.Probability
    TotalValue    methods.Probability
    Confidence    methods.Probability
    RiskLevel     methods.Probability
    GasUsed       uint64
}

// PositionRecord tracks portfolio positions
type PositionRecord struct {
    Timestamp     int64
    Symbol        string
    Quantity      methods.Probability
    AveragePrice  methods.Probability
    CurrentPrice  methods.Probability
    UnrealizedPnL methods.Probability
    Allocation    methods.Probability
}

// MarketDataRecord tracks market data observations
type MarketDataRecord struct {
    Timestamp   int64
    Price       methods.Probability
    Volume      methods.Probability
    Volatility  methods.Probability
    Sentiment   methods.Probability
    Trend       methods.Probability
}

// RiskMetrics tracks risk management metrics
type RiskMetrics struct {
    MaxDrawdown       methods.Probability
    SharpeRatio       methods.Probability
    Volatility        methods.Probability
    VaR95             methods.Probability // Value at Risk 95%
    MaxPositionSize   methods.Probability
    DiversificationRatio methods.Probability
}

// MarketState represents current market conditions
type MarketState struct {
    Trend       methods.Probability // Bullish (1.0) to Bearish (0.0)
    Volatility  methods.Probability // Market volatility level
    Sentiment   methods.Probability // Market sentiment (positive to negative)
    Confidence  methods.Probability // Agent confidence in market state
}

// =============================================================================
// REALM INITIALIZATION
// =============================================================================

// init is called when the realm is deployed to the blockchain
func init() {
    // Initialize trading agent
    tradingAgent = active_inference_core.NewActiveInferenceAgent()

    // Initialize access control
    owner = ""
    authorizedTraders = make([]string, 0)

    // Initialize history arrays
    tradeHistory = make([]TradeRecord, 0)
    positionHistory = make([]PositionRecord, 0)
    marketDataHistory = make([]MarketDataRecord, 0)

    // Initialize metrics
    totalTrades = 0
    successfulTrades = 0
    totalProfitLoss = 0
    portfolioValue = 1000.0 // Starting portfolio value

    // Initialize risk metrics
    riskMetrics = RiskMetrics{
        MaxDrawdown: 0,
        SharpeRatio: 0,
        Volatility: 0.2,
        VaR95: 0.05,
        MaxPositionSize: 0.25, // Max 25% of portfolio per position
        DiversificationRatio: 0.7,
    }

    // Initialize market state
    currentMarketState = MarketState{
        Trend: 0.5,      // Neutral trend
        Volatility: 0.2, // Moderate volatility
        Sentiment: 0.5,  // Neutral sentiment
        Confidence: 0.6, // Moderate confidence
    }

    ufmt.Printf("Financial trading agent realm initialized\n")
}

// =============================================================================
// ACCESS CONTROL METHODS
// =============================================================================

// Deploy initializes the trading agent for a specific owner
func Deploy(caller string, tradingOwner string) string {
    if owner != "" {
        return "Trading agent already deployed"
    }

    if !std.IsValidAddress(tradingOwner) {
        return "Invalid owner address"
    }

    owner = tradingOwner

    // Emit deployment event
    std.Emit("TradingAgentDeployed", map[string]interface{}{
        "owner": tradingOwner,
        "timestamp": std.BlockTime(),
        "agentType": "FinancialTradingAgent",
        "initialPortfolio": portfolioValue,
    })

    return "Financial trading agent deployed successfully"
}

// IsAuthorized checks if the caller is authorized to perform trading actions
func IsAuthorized(caller string) bool {
    return caller == owner
}

// AddAuthorizedTrader adds a trader to the authorized list
func AddAuthorizedTrader(caller string, trader string) string {
    if !IsAuthorized(caller) {
        return "Access denied: only owner can authorize traders"
    }

    // Check if already authorized
    for _, authorized := range authorizedTraders {
        if authorized == trader {
            return "Trader already authorized"
        }
    }

    authorizedTraders = append(authorizedTraders, trader)

    std.Emit("TraderAuthorized", map[string]interface{}{
        "trader": trader,
        "authorizedBy": caller,
        "timestamp": std.BlockTime(),
    })

    return "Trader authorized successfully"
}

// =============================================================================
// MARKET DATA PROCESSING
// =============================================================================

// ProcessMarketData processes market data and makes trading decisions
func ProcessMarketData(caller string, marketData []methods.Probability) string {
    if !IsAuthorized(caller) {
        return "Access denied: not authorized to trade"
    }

    // Validate market data length (price, volume, volatility, sentiment)
    if len(marketData) != 4 {
        return "Invalid market data: expected 4 values (price, volume, volatility, sentiment)"
    }

    // Record market data
    marketRecord := MarketDataRecord{
        Timestamp:  std.BlockTime(),
        Price:      marketData[0],
        Volume:     marketData[1],
        Volatility: marketData[2],
        Sentiment:  marketData[3],
        Trend:      calculateTrend(marketData),
    }
    marketDataHistory = append(marketDataHistory, marketRecord)

    // Update market state
    updateMarketState(marketData)

    // Process with trading agent
    err := tradingAgent.Perceive(marketData)
    if err != nil {
        return "Error processing market data: " + err.Error()
    }

    // Generate trading decision
    policies, err := tradingAgent.Plan()
    if err != nil {
        return "Error generating trading plan: " + err.Error()
    }

    // Execute trading decision
    tradingAction := analyzeTradingSignal(policies)
    result := executeTrade(caller, tradingAction, marketData)

    return result
}

// calculateTrend computes market trend from recent data
func calculateTrend(marketData []methods.Probability) methods.Probability {
    if len(marketDataHistory) < 2 {
        return 0.5 // Neutral trend
    }

    // Simple trend calculation based on price momentum
    currentPrice := marketData[0]
    prevPrice := marketDataHistory[len(marketDataHistory)-1].Price

    if currentPrice > prevPrice {
        return methods.Probability(math.Min(1.0, float64(currentPrice-prevPrice)*10))
    } else {
        return methods.Probability(math.Max(0.0, float64(prevPrice-currentPrice)*10))
    }
}

// updateMarketState updates the current market state based on new data
func updateMarketState(marketData []methods.Probability) {
    // Update trend
    currentMarketState.Trend = (currentMarketState.Trend*0.7 + calculateTrend(marketData)*0.3)

    // Update volatility (exponential moving average)
    currentMarketState.Volatility = (currentMarketState.Volatility*0.8 + marketData[2]*0.2)

    // Update sentiment
    currentMarketState.Sentiment = (currentMarketState.Sentiment*0.7 + marketData[3]*0.3)

    // Update confidence based on data consistency
    confidenceChange := methods.Probability(0.1) // Default confidence increase
    if len(marketDataHistory) > 1 {
        prevData := marketDataHistory[len(marketDataHistory)-1]
        consistency := methods.Probability(1.0)
        if math.Abs(float64(marketData[0]-prevData.Price)) > 0.1 {
            consistency -= 0.3
        }
        confidenceChange = consistency * 0.05
    }

    currentMarketState.Confidence = methods.Probability(math.Min(1.0, math.Max(0.3, float64(currentMarketState.Confidence+confidenceChange))))
}

// analyzeTradingSignal analyzes trading policies and determines action
func analyzeTradingSignal(policies []active_inference_core.Policy) string {
    if len(policies) == 0 {
        return "HOLD"
    }

    // Analyze first policy for trading signal
    policy := policies[0]
    if len(policy.Actions) == 0 {
        return "HOLD"
    }

    // Simple decision based on policy confidence and market state
    buySignal := policy.Actions[0] > 0.6 && currentMarketState.Trend > 0.6
    sellSignal := policy.Actions[0] < 0.4 && currentMarketState.Trend < 0.4

    if buySignal {
        return "BUY"
    } else if sellSignal {
        return "SELL"
    }

    return "HOLD"
}

// executeTrade executes a trading decision
func executeTrade(caller string, action string, marketData []methods.Probability) string {
    if action == "HOLD" {
        return "No trading action required - market conditions stable"
    }

    // Calculate trade parameters
    price := marketData[0]
    maxPositionSize := portfolioValue * riskMetrics.MaxPositionSize
    tradeValue := maxPositionSize * methods.Probability(0.5) // Use 50% of max position

    quantity := tradeValue / price

    // Create trade record
    trade := TradeRecord{
        Timestamp:  std.BlockTime(),
        Symbol:     "GNO", // Trading GNO tokens
        Action:     action,
        Quantity:   quantity,
        Price:      price,
        TotalValue: tradeValue,
        Confidence: currentMarketState.Confidence,
        RiskLevel:  calculateRiskLevel(action),
        GasUsed:    std.GasUsed(),
    }

    tradeHistory = append(tradeHistory, trade)

    // Update position
    updatePosition(trade)

    // Update performance metrics
    updatePerformanceMetrics(trade)

    // Update agent learning
    reward := calculateTradeReward(trade)
    err := tradingAgent.Learn(reward)
    if err != nil {
        return "Trade executed but learning error: " + err.Error()
    }

    // Emit trade event
    std.Emit("TradeExecuted", map[string]interface{}{
        "action": action,
        "quantity": quantity,
        "price": price,
        "value": tradeValue,
        "confidence": currentMarketState.Confidence,
        "timestamp": std.BlockTime(),
    })

    return ufmt.Sprintf("Trade executed: %s %.3f GNO at price %.3f (value: %.3f)",
        action, quantity, price, tradeValue)
}

// calculateRiskLevel calculates risk level for a trade
func calculateRiskLevel(action string) methods.Probability {
    baseRisk := currentMarketState.Volatility * 0.5

    // Adjust risk based on action and market conditions
    if action == "BUY" && currentMarketState.Trend < 0.3 {
        baseRisk += 0.2 // Higher risk for buying in bear market
    } else if action == "SELL" && currentMarketState.Trend > 0.7 {
        baseRisk += 0.2 // Higher risk for selling in bull market
    }

    return methods.Probability(math.Min(1.0, float64(baseRisk)))
}

// updatePosition updates portfolio position after trade
func updatePosition(trade TradeRecord) {
    // Find existing position or create new one
    positionIndex := -1
    for i, pos := range positionHistory {
        if pos.Symbol == trade.Symbol {
            positionIndex = i
            break
        }
    }

    if positionIndex == -1 {
        // Create new position
        newPosition := PositionRecord{
            Timestamp:    std.BlockTime(),
            Symbol:       trade.Symbol,
            Quantity:     0,
            AveragePrice: 0,
            CurrentPrice: trade.Price,
            UnrealizedPnL: 0,
            Allocation:   0,
        }
        positionHistory = append(positionHistory, newPosition)
        positionIndex = len(positionHistory) - 1
    }

    position := &positionHistory[positionIndex]

    if trade.Action == "BUY" {
        // Update average price
        totalValue := position.Quantity*position.AveragePrice + trade.Quantity*trade.Price
        position.Quantity += trade.Quantity
        position.AveragePrice = totalValue / position.Quantity
    } else if trade.Action == "SELL" {
        position.Quantity -= trade.Quantity
        if position.Quantity <= 0 {
            // Remove position if fully sold
            positionHistory = append(positionHistory[:positionIndex], positionHistory[positionIndex+1:]...)
            return
        }
    }

    position.CurrentPrice = trade.Price
    position.Timestamp = std.BlockTime()

    // Calculate unrealized P&L
    position.UnrealizedPnL = (trade.Price - position.AveragePrice) * position.Quantity

    // Update allocation
    position.Allocation = (position.Quantity * trade.Price) / portfolioValue
}

// updatePerformanceMetrics updates trading performance metrics
func updatePerformanceMetrics(trade TradeRecord) {
    totalTrades++

    // Update P&L
    if trade.Action == "BUY" {
        totalProfitLoss -= trade.TotalValue
    } else if trade.Action == "SELL" {
        totalProfitLoss += trade.TotalValue
    }

    // Track successful trades (simplified)
    if trade.Confidence > 0.6 {
        successfulTrades++
    }

    // Update risk metrics
    updateRiskMetrics(trade)
}

// updateRiskMetrics updates risk management metrics
func updateRiskMetrics(trade TradeRecord) {
    // Update volatility estimate
    riskMetrics.Volatility = (riskMetrics.Volatility*0.9 + trade.RiskLevel*0.1)

    // Update max drawdown (simplified)
    currentValue := portfolioValue + totalProfitLoss
    if currentValue < portfolioValue {
        drawdown := (portfolioValue - currentValue) / portfolioValue
        if drawdown > riskMetrics.MaxDrawdown {
            riskMetrics.MaxDrawdown = drawdown
        }
    }

    // Update Sharpe ratio (simplified)
    if totalTrades > 0 {
        winRate := methods.Probability(successfulTrades) / methods.Probability(totalTrades)
        riskMetrics.SharpeRatio = (winRate - 0.5) / riskMetrics.Volatility
    }
}

// calculateTradeReward calculates reward for agent learning
func calculateTradeReward(trade TradeRecord) methods.Probability {
    // Simplified reward calculation
    baseReward := methods.Probability(0.0)

    if trade.Action == "BUY" && currentMarketState.Trend > 0.6 {
        baseReward += 0.1 // Positive reward for buying in bull market
    } else if trade.Action == "SELL" && currentMarketState.Trend < 0.4 {
        baseReward += 0.1 // Positive reward for selling in bear market
    }

    // Risk-adjusted reward
    riskAdjustment := methods.Probability(1.0) - trade.RiskLevel
    return baseReward * riskAdjustment
}

// =============================================================================
// QUERY METHODS
// =============================================================================

// GetTradingStatus returns current trading agent status
func GetTradingStatus(caller string) string {
    if !IsAuthorized(caller) {
        return "Access denied"
    }

    return ufmt.Sprintf(`Financial Trading Agent Status:
Owner: %s
Portfolio Value: %.2f
Total Trades: %d
Successful Trades: %d
Success Rate: %.1f%%
Total P&L: %.2f
Current Market State:
  Trend: %.3f
  Volatility: %.3f
  Sentiment: %.3f
  Confidence: %.3f
Risk Metrics:
  Max Drawdown: %.3f
  Sharpe Ratio: %.3f
  VaR 95%%: %.3f
Block Height: %d`,
        owner, portfolioValue, totalTrades, successfulTrades,
        float64(successfulTrades)/float64(totalTrades)*100, totalProfitLoss,
        currentMarketState.Trend, currentMarketState.Volatility,
        currentMarketState.Sentiment, currentMarketState.Confidence,
        riskMetrics.MaxDrawdown, riskMetrics.SharpeRatio, riskMetrics.VaR95,
        std.BlockHeight())
}

// GetTradeHistory returns recent trading history
func GetTradeHistory(caller string) string {
    if !IsAuthorized(caller) {
        return "Access denied"
    }

    if len(tradeHistory) == 0 {
        return "No trading history available"
    }

    history := "Recent Trading History:\n"
    maxHistory := 10
    if len(tradeHistory) < maxHistory {
        maxHistory = len(tradeHistory)
    }

    for i := len(tradeHistory) - maxHistory; i < len(tradeHistory); i++ {
        trade := tradeHistory[i]
        history += ufmt.Sprintf("Trade %d: %s %.3f @ %.3f (Conf: %.2f, Risk: %.2f)\n",
            i+1, trade.Action, trade.Quantity, trade.Price, trade.Confidence, trade.RiskLevel)
    }

    return history
}

// GetPositionSummary returns current portfolio positions
func GetPositionSummary(caller string) string {
    if !IsAuthorized(caller) {
        return "Access denied"
    }

    if len(positionHistory) == 0 {
        return "No positions in portfolio"
    }

    summary := "Current Portfolio Positions:\n"
    for _, position := range positionHistory {
        summary += ufmt.Sprintf("%s: %.3f shares @ avg %.3f (P&L: %.2f, Alloc: %.1f%%)\n",
            position.Symbol, position.Quantity, position.AveragePrice,
            position.UnrealizedPnL, position.Allocation*100)
    }

    return summary
}

// GetMarketAnalysis returns current market analysis
func GetMarketAnalysis(caller string) string {
    if !IsAuthorized(caller) {
        return "Access denied"
    }

    return ufmt.Sprintf(`Market Analysis:
Current State:
  Trend: %.3f (%s)
  Volatility: %.3f (%s)
  Sentiment: %.3f (%s)
  Agent Confidence: %.3f
Recent Data Points: %d
Risk Assessment: %.3f
Trading Signal: %s`,
        currentMarketState.Trend,
        getTrendDescription(currentMarketState.Trend),
        currentMarketState.Volatility,
        getVolatilityDescription(currentMarketState.Volatility),
        currentMarketState.Sentiment,
        getSentimentDescription(currentMarketState.Sentiment),
        currentMarketState.Confidence,
        len(marketDataHistory),
        riskMetrics.VaR95,
        getTradingSignal())
}

// Helper functions for descriptions
func getTrendDescription(trend methods.Probability) string {
    if trend > 0.7 {
        return "Strongly Bullish"
    } else if trend > 0.5 {
        return "Bullish"
    } else if trend > 0.3 {
        return "Bearish"
    } else {
        return "Strongly Bearish"
    }
}

func getVolatilityDescription(vol methods.Probability) string {
    if vol < 0.1 {
        return "Very Low"
    } else if vol < 0.2 {
        return "Low"
    } else if vol < 0.3 {
        return "Moderate"
    } else {
        return "High"
    }
}

func getSentimentDescription(sentiment methods.Probability) string {
    if sentiment > 0.7 {
        return "Very Positive"
    } else if sentiment > 0.5 {
        return "Positive"
    } else if sentiment > 0.3 {
        return "Negative"
    } else {
        return "Very Negative"
    }
}

func getTradingSignal() string {
    buySignal := currentMarketState.Trend > 0.6 && currentMarketState.Confidence > 0.6
    sellSignal := currentMarketState.Trend < 0.4 && currentMarketState.Confidence > 0.6

    if buySignal {
        return "BUY"
    } else if sellSignal {
        return "SELL"
    } else {
        return "HOLD"
    }
}

// =============================================================================
// RENDER METHOD FOR REALM QUERIES
// =============================================================================

// Render provides string representation for queries
func Render(path string) string {
    switch path {
    case "":
        return GetTradingStatus("")
    case "status":
        return GetTradingStatus("")
    case "trades":
        return GetTradeHistory("")
    case "positions":
        return GetPositionSummary("")
    case "market":
        return GetMarketAnalysis("")
    default:
        return "Unknown path: " + path
    }
}
