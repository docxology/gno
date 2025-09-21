// Package financial_trading_test provides comprehensive tests for the financial trading realm
package financial_trading

import (
	"testing"
	"gno.land/p/active_inference/methods"
)

// TestDeployTradingAgent tests the deployment of the trading agent
func TestDeployTradingAgent(t *testing.T) {
	// Test initial deployment
	result := Deploy("test_caller", "test_owner")
	if result != "Financial trading agent deployed successfully" {
		t.Errorf("Expected successful deployment, got: %s", result)
	}

	// Test duplicate deployment
	result = Deploy("test_caller", "another_owner")
	if result != "Trading agent already deployed" {
		t.Errorf("Expected deployment already error, got: %s", result)
	}
}

// TestMarketDataProcessing tests market data processing functionality
func TestMarketDataProcessing(t *testing.T) {
	// Deploy trading agent first
	Deploy("test_caller", "test_owner")

	// Test valid market data processing
	marketData := []methods.Probability{0.8, 0.6, 0.2, 0.7} // price, volume, volatility, sentiment
	result := ProcessMarketData("test_owner", marketData)

	if result == "Access denied: not authorized to trade" {
		t.Error("Expected market data processing to succeed")
	}

	if result == "Invalid market data: expected 4 values (price, volume, volatility, sentiment)" {
		t.Error("Expected valid market data processing")
	}

	// Check that market data was recorded
	if len(marketDataHistory) != 1 {
		t.Errorf("Expected 1 market data record, got %d", len(marketDataHistory))
	}

	// Test invalid market data length
	invalidData := []methods.Probability{0.8, 0.6, 0.2} // Missing sentiment
	result = ProcessMarketData("test_owner", invalidData)
	if result != "Invalid market data: expected 4 values (price, volume, volatility, sentiment)" {
		t.Errorf("Expected invalid data error, got: %s", result)
	}
}

// TestAccessControl tests access control mechanisms
func TestAccessControl(t *testing.T) {
	// Deploy trading agent
	Deploy("test_caller", "test_owner")

	// Test unauthorized access
	result := ProcessMarketData("unauthorized_user", []methods.Probability{0.8, 0.6, 0.2, 0.7})
	if result != "Access denied: not authorized to trade" {
		t.Errorf("Expected access denied, got: %s", result)
	}

	// Test authorized access
	result = ProcessMarketData("test_owner", []methods.Probability{0.8, 0.6, 0.2, 0.7})
	if result == "Access denied: not authorized to trade" {
		t.Error("Expected authorized access to succeed")
	}
}

// TestAuthorizedTraderManagement tests trader authorization functionality
func TestAuthorizedTraderManagement(t *testing.T) {
	// Deploy trading agent
	Deploy("test_caller", "test_owner")

	// Test adding authorized trader
	result := AddAuthorizedTrader("test_owner", "trader1")
	if result != "Trader authorized successfully" {
		t.Errorf("Expected successful trader authorization, got: %s", result)
	}

	// Test adding duplicate trader
	result = AddAuthorizedTrader("test_owner", "trader1")
	if result != "Trader already authorized" {
		t.Errorf("Expected duplicate trader error, got: %s", result)
	}

	// Test adding another trader
	result = AddAuthorizedTrader("test_owner", "trader2")
	if result != "Trader authorized successfully" {
		t.Errorf("Expected second trader authorization, got: %s", result)
	}

	// Test unauthorized trader addition
	result = AddAuthorizedTrader("unauthorized_user", "trader3")
	if result != "Access denied: only owner can authorize traders" {
		t.Errorf("Expected access denied for unauthorized trader addition, got: %s", result)
	}
}

// TestTradingDecisions tests trading decision making
func TestTradingDecisions(t *testing.T) {
	// Deploy trading agent
	Deploy("test_caller", "test_owner")

	// Test bullish market conditions
	bullishData := []methods.Probability{0.9, 0.8, 0.15, 0.8} // High price, volume, low volatility, positive sentiment
	result := ProcessMarketData("test_owner", bullishData)

	if result == "Access denied: not authorized to trade" {
		t.Error("Expected trading decision to succeed")
	}

	// Check that trade was executed
	if totalTrades != 1 {
		t.Errorf("Expected 1 trade after bullish data, got %d", totalTrades)
	}

	// Test bearish market conditions
	bearishData := []methods.Probability{0.3, 0.4, 0.4, 0.2} // Low price, volume, high volatility, negative sentiment
	result = ProcessMarketData("test_owner", bearishData)

	if result == "Access denied: not authorized to trade" {
		t.Error("Expected trading decision to succeed")
	}

	// Check that second trade was executed
	if totalTrades != 2 {
		t.Errorf("Expected 2 trades after bearish data, got %d", totalTrades)
	}

	// Test neutral market conditions (should hold)
	neutralData := []methods.Probability{0.5, 0.5, 0.2, 0.5}
	result = ProcessMarketData("test_owner", neutralData)

	if result == "Access denied: not authorized to trade" {
		t.Error("Expected trading decision to succeed")
	}

	// Should result in hold decision
	if result != "No trading action required - market conditions stable" {
		t.Errorf("Expected hold decision for neutral market, got: %s", result)
	}
}

// TestPortfolioManagement tests portfolio position tracking
func TestPortfolioManagement(t *testing.T) {
	// Deploy trading agent
	Deploy("test_caller", "test_owner")

	// Execute buy trade
	buyData := []methods.Probability{1.0, 0.8, 0.15, 0.8}
	ProcessMarketData("test_owner", buyData)

	// Check position was created
	if len(positionHistory) != 1 {
		t.Errorf("Expected 1 position after buy trade, got %d", len(positionHistory))
	}

	// Execute sell trade
	sellData := []methods.Probability{0.9, 0.7, 0.2, 0.6}
	ProcessMarketData("test_owner", sellData)

	// Position should be updated, not removed if partial sell
	if len(positionHistory) != 1 {
		t.Errorf("Expected position to remain after partial sell, got %d positions", len(positionHistory))
	}

	// Execute full sell trade (more aggressive sell)
	strongSellData := []methods.Probability{0.2, 0.3, 0.5, 0.1}
	ProcessMarketData("test_owner", strongSellData)

	// Position should be removed if fully sold
	if len(positionHistory) != 0 {
		t.Errorf("Expected position to be removed after full sell, got %d positions", len(positionHistory))
	}
}

// TestRiskManagement tests risk management functionality
func TestRiskManagement(t *testing.T) {
	// Deploy trading agent
	Deploy("test_caller", "test_owner")

	// Execute high-risk trade
	highRiskData := []methods.Probability{0.3, 0.2, 0.8, 0.1} // Bear market, high volatility
	result := ProcessMarketData("test_owner", highRiskData)

	if result == "Access denied: not authorized to trade" {
		t.Error("Expected high-risk trade processing to succeed")
	}

	// Check that risk level was calculated
	if len(tradeHistory) > 0 {
		lastTrade := tradeHistory[len(tradeHistory)-1]
		if lastTrade.RiskLevel < 0.3 { // Should be high risk
			t.Errorf("Expected high risk level for bear market, got %.3f", lastTrade.RiskLevel)
		}
	}

	// Check that risk metrics were updated
	if riskMetrics.MaxDrawdown == 0 {
		t.Error("Expected max drawdown to be updated")
	}

	if riskMetrics.Volatility < 0.1 {
		t.Error("Expected volatility to be updated")
	}
}

// TestQueryMethods tests query functionality
func TestQueryMethods(t *testing.T) {
	// Deploy trading agent
	Deploy("test_caller", "test_owner")

	// Add some market data and trades
	ProcessMarketData("test_owner", []methods.Probability{0.8, 0.6, 0.2, 0.7})
	ProcessMarketData("test_owner", []methods.Probability{0.9, 0.7, 0.15, 0.8})

	// Test trading status query
	status := GetTradingStatus("test_owner")
	if status == "Access denied" {
		t.Error("Expected trading status access to succeed")
	}

	// Test market analysis query
	analysis := GetMarketAnalysis("test_owner")
	if analysis == "Access denied" {
		t.Error("Expected market analysis access to succeed")
	}

	// Test position summary query
	positions := GetPositionSummary("test_owner")
	if positions == "Access denied" {
		t.Error("Expected position summary access to succeed")
	}

	// Test trade history query
	history := GetTradeHistory("test_owner")
	if history == "Access denied" {
		t.Error("Expected trade history access to succeed")
	}

	// Test unauthorized query access
	statusUnauthorized := GetTradingStatus("unauthorized_user")
	if statusUnauthorized != "Access denied" {
		t.Errorf("Expected access denied for unauthorized status query, got: %s", statusUnauthorized)
	}
}

// TestPerformanceTracking tests performance metrics tracking
func TestPerformanceTracking(t *testing.T) {
	// Deploy trading agent
	Deploy("test_caller", "test_owner")

	// Execute multiple trades
	trades := [][]methods.Probability{
		{0.8, 0.6, 0.2, 0.7}, // Bullish
		{0.9, 0.8, 0.15, 0.8}, // Strong bullish
		{0.7, 0.5, 0.25, 0.6}, // Moderate
		{0.6, 0.4, 0.3, 0.5}, // Neutral
	}

	for _, data := range trades {
		ProcessMarketData("test_owner", data)
	}

	// Check performance metrics
	if totalTrades != 4 {
		t.Errorf("Expected 4 total trades, got %d", totalTrades)
	}

	// Check P&L tracking
	if totalProfitLoss == 0 {
		t.Error("Expected P&L to be tracked")
	}

	// Check success rate calculation
	if successfulTrades == 0 {
		t.Error("Expected some successful trades to be tracked")
	}

	// Check risk metrics updates
	if riskMetrics.MaxDrawdown == 0 {
		t.Error("Expected max drawdown to be calculated")
	}

	if riskMetrics.SharpeRatio == 0 {
		t.Error("Expected Sharpe ratio to be calculated")
	}
}

// TestEdgeCases tests edge cases and boundary conditions
func TestEdgeCases(t *testing.T) {
	// Test deployment without owner
	result := Deploy("test_caller", "")
	if result != "Invalid owner address" {
		t.Errorf("Expected invalid owner address error, got: %s", result)
	}

	// Test with empty market data
	Deploy("test_caller", "test_owner")
	result = ProcessMarketData("test_owner", []methods.Probability{})
	if result != "Invalid market data: expected 4 values (price, volume, volatility, sentiment)" {
		t.Errorf("Expected empty data error, got: %s", result)
	}

	// Test with extreme market conditions
	extremeData := []methods.Probability{1.0, 1.0, 0.0, 1.0} // Perfect conditions
	result = ProcessMarketData("test_owner", extremeData)
	if result == "Access denied: not authorized to trade" {
		t.Error("Expected extreme condition processing to succeed")
	}

	// Test with poor market conditions
	poorData := []methods.Probability{0.0, 0.0, 1.0, 0.0} // Worst conditions
	result = ProcessMarketData("test_owner", poorData)
	if result == "Access denied: not authorized to trade" {
		t.Error("Expected poor condition processing to succeed")
	}
}

// TestCompleteWorkflow tests a complete trading workflow
func TestCompleteWorkflow(t *testing.T) {
	// Complete workflow test
	Deploy("test_caller", "test_owner")

	// Add authorized trader
	AddAuthorizedTrader("test_owner", "trader1")

	// Simulate market evolution over time
	marketScenarios := [][]methods.Probability{
		{0.5, 0.5, 0.2, 0.5}, // Neutral start
		{0.6, 0.6, 0.15, 0.6}, // Improving market
		{0.8, 0.8, 0.1, 0.8}, // Bull market
		{0.7, 0.7, 0.2, 0.7}, // Continued bull
		{0.4, 0.3, 0.4, 0.3}, // Market correction
		{0.3, 0.2, 0.5, 0.2}, // Bear market
	}

	for i, data := range marketScenarios {
		result := ProcessMarketData("test_owner", data)
		if result == "Access denied: not authorized to trade" {
			t.Errorf("Market scenario %d failed: %s", i+1, result)
		}
	}

	// Verify comprehensive state tracking
	if totalTrades < 3 {
		t.Errorf("Expected at least 3 trades in complete workflow, got %d", totalTrades)
	}

	if len(tradeHistory) < 3 {
		t.Errorf("Expected at least 3 trade records, got %d", len(tradeHistory))
	}

	if len(marketDataHistory) != len(marketScenarios) {
		t.Errorf("Expected %d market data records, got %d", len(marketScenarios), len(marketDataHistory))
	}

	// Check portfolio management
	if len(positionHistory) == 0 {
		t.Error("Expected portfolio positions to be managed")
	}

	// Check risk management
	if riskMetrics.MaxDrawdown == 0 {
		t.Error("Expected risk metrics to be calculated")
	}
}

// TestRealm tests the complete financial trading realm functionality
func TestRealm(t *testing.T) {
	t.Log("=== Financial Trading Realm Tests ===")

	TestDeployTradingAgent(t)
	TestMarketDataProcessing(t)
	TestAccessControl(t)
	TestAuthorizedTraderManagement(t)
	TestTradingDecisions(t)
	TestPortfolioManagement(t)
	TestRiskManagement(t)
	TestQueryMethods(t)
	TestPerformanceTracking(t)
	TestEdgeCases(t)
	TestCompleteWorkflow(t)

	t.Log("=== Financial Trading Tests Complete ===")
}
