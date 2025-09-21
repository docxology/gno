// Package multi_agent_system_test provides comprehensive tests for the multi-agent system realm
package multi_agent_system

import (
	"testing"
	"gno.land/p/active_inference/methods"
)

// TestDeploySystem tests the deployment of the multi-agent system
func TestDeploySystem(t *testing.T) {
	// Test initial deployment
	result := Deploy("test_caller", "test_owner")
	if result != "Multi-agent system deployed successfully" {
		t.Errorf("Expected successful deployment, got: %s", result)
	}

	// Test duplicate deployment
	result = Deploy("test_caller", "another_owner")
	if result != "Multi-agent system already deployed" {
		t.Errorf("Expected deployment already error, got: %s", result)
	}
}

// TestAgentRegistration tests agent registration functionality
func TestAgentRegistration(t *testing.T) {
	// Deploy system first
	Deploy("test_caller", "test_owner")

	// Test agent registration
	result := RegisterAgent("test_owner", "agent1")
	if result != "Agent agent1 registered successfully. Total agents: 1" {
		t.Errorf("Expected successful registration, got: %s", result)
	}

	// Test duplicate registration
	result = RegisterAgent("test_owner", "agent1")
	if result != "Agent already registered" {
		t.Errorf("Expected already registered error, got: %s", result)
	}

	// Test registering second agent
	result = RegisterAgent("test_owner", "agent2")
	if result != "Agent agent2 registered successfully. Total agents: 2" {
		t.Errorf("Expected successful second registration, got: %s", result)
	}
}

// TestCoordinationRound tests coordination functionality
func TestCoordinationRound(t *testing.T) {
	// Deploy system first
	Deploy("test_caller", "test_owner")

	// Register minimum agents for coordination
	RegisterAgent("test_owner", "agent1")
	RegisterAgent("test_owner", "agent2")

	// Test coordination round
	observation := []methods.Probability{0.6, 0.4, 0.7, 0.3}
	result := CoordinateRound("test_owner", observation)

	if result == "Access denied" {
		t.Error("Expected coordination to succeed, got access denied")
	}

	if result == "Need at least 2 agents for coordination" {
		t.Error("Expected coordination to succeed with 2 agents")
	}
}

// TestAccessControl tests access control mechanisms
func TestAccessControl(t *testing.T) {
	// Deploy system
	Deploy("test_caller", "test_owner")

	// Test unauthorized access
	result := RegisterAgent("unauthorized_user", "agent1")
	if result != "Access denied: not authorized" {
		t.Errorf("Expected access denied, got: %s", result)
	}

	// Test authorized access
	result = RegisterAgent("test_owner", "agent1")
	if result == "Access denied: not authorized" {
		t.Error("Expected authorized access to succeed")
	}
}

// TestQueryMethods tests query functionality
func TestQueryMethods(t *testing.T) {
	// Deploy system
	Deploy("test_caller", "test_owner")

	// Register an agent
	RegisterAgent("test_owner", "agent1")

	// Test system status query
	status := GetSystemStatus("test_owner")
	if status == "Access denied" {
		t.Error("Expected system status access to succeed")
	}

	// Test agent list query
	agents := GetRegisteredAgents("test_owner")
	if agents == "Access denied" {
		t.Error("Expected agent list access to succeed")
	}

	// Test unauthorized query access
	statusUnauthorized := GetSystemStatus("unauthorized_user")
	if statusUnauthorized != "Access denied" {
		t.Errorf("Expected access denied for unauthorized query, got: %s", statusUnauthorized)
	}
}

// TestCoordinationHistory tests coordination history tracking
func TestCoordinationHistory(t *testing.T) {
	// Deploy system
	Deploy("test_caller", "test_owner")

	// Register agents
	RegisterAgent("test_owner", "agent1")
	RegisterAgent("test_owner", "agent2")

	// Run coordination round
	observation := []methods.Probability{0.5, 0.5, 0.5, 0.5}
	CoordinateRound("test_owner", observation)

	// Test history query
	history := GetCoordinationHistory("test_owner")
	if history == "Access denied" {
		t.Error("Expected history access to succeed")
	}

	if history == "No coordination history available" {
		t.Error("Expected coordination history to be available after running round")
	}
}

// TestAgentBeliefs tests belief retrieval functionality
func TestAgentBeliefs(t *testing.T) {
	// Deploy system
	Deploy("test_caller", "test_owner")

	// Register agent
	RegisterAgent("test_owner", "agent1")

	// Test belief query
	beliefs := GetAgentBeliefs("test_owner")
	if beliefs == "Access denied" {
		t.Error("Expected belief access to succeed")
	}

	if beliefs == "No agents available" {
		t.Error("Expected agent to be available")
	}
}

// TestEdgeCases tests edge cases and boundary conditions
func TestEdgeCases(t *testing.T) {
	// Test deployment without owner
	result := Deploy("test_caller", "")
	if result != "Invalid owner address" {
		t.Errorf("Expected invalid owner address error, got: %s", result)
	}

	// Test coordination with single agent
	Deploy("test_caller", "test_owner")
	RegisterAgent("test_owner", "agent1")

	result = CoordinateRound("test_owner", []methods.Probability{0.5, 0.5})
	if result != "Need at least 2 agents for coordination" {
		t.Errorf("Expected need more agents error, got: %s", result)
	}
}

// TestMetrics tests metrics tracking functionality
func TestMetrics(t *testing.T) {
	// Deploy system
	Deploy("test_caller", "test_owner")

	// Register agents and run coordination
	RegisterAgent("test_owner", "agent1")
	RegisterAgent("test_owner", "agent2")
	CoordinateRound("test_owner", []methods.Probability{0.5, 0.5, 0.5, 0.5})

	// Test system status includes metrics
	status := GetSystemStatus("test_owner")
	if status == "Access denied" {
		t.Error("Expected status access to succeed")
	}

	// Check that metrics are tracked
	if totalCoordinationRounds != 1 {
		t.Errorf("Expected 1 coordination round, got %d", totalCoordinationRounds)
	}

	if len(coordinator.Agents) != 2 {
		t.Errorf("Expected 2 agents, got %d", len(coordinator.Agents))
	}
}

// TestCompleteWorkflow tests a complete workflow from deployment to coordination
func TestCompleteWorkflow(t *testing.T) {
	// Complete workflow test
	Deploy("test_caller", "test_owner")

	// Register multiple agents
	agents := []string{"agent1", "agent2", "agent3", "agent4", "agent5"}
	for _, agentID := range agents {
		result := RegisterAgent("test_owner", agentID)
		if result != "Agent "+agentID+" registered successfully. Total agents: "+string(len(agents)) {
			t.Errorf("Failed to register agent %s: %s", agentID, result)
		}
	}

	// Run multiple coordination rounds
	for i := 0; i < 3; i++ {
		observation := []methods.Probability{0.5 + 0.1*methods.Probability(i), 0.4, 0.6, 0.3}
		result := CoordinateRound("test_owner", observation)
		if result == "Access denied" || result == "Need at least 2 agents for coordination" {
			t.Errorf("Coordination round %d failed: %s", i+1, result)
		}
	}

	// Verify final state
	if totalCoordinationRounds != 3 {
		t.Errorf("Expected 3 coordination rounds, got %d", totalCoordinationRounds)
	}

	if len(coordinator.Agents) != 5 {
		t.Errorf("Expected 5 agents, got %d", len(coordinator.Agents))
	}

	if len(coordinationHistory) != 3 {
		t.Errorf("Expected 3 coordination history records, got %d", len(coordinationHistory))
	}
}

// TestRealm tests the complete realm functionality
func TestRealm(t *testing.T) {
	t.Log("=== Multi-Agent System Realm Tests ===")

	TestDeploySystem(t)
	TestAgentRegistration(t)
	TestAccessControl(t)
	TestCoordinationRound(t)
	TestQueryMethods(t)
	TestCoordinationHistory(t)
	TestAgentBeliefs(t)
	TestEdgeCases(t)
	TestMetrics(t)
	TestCompleteWorkflow(t)

	t.Log("=== Multi-Agent System Tests Complete ===")
}
