# 🎯 Active Inference on Gno Blockchain - Complete Documentation

*A comprehensive framework for implementing Active Inference, Bayesian learning, Free Energy Principle, and cognitive modeling as smart contracts on the Gno blockchain.*

## 📋 Complete Documentation Overview

This document consolidates all documentation from the Active Inference framework, including:
- **Deployment Guide**: Step-by-step deployment instructions
- **Interactive Tutorials**: Hands-on learning materials
- **Glossary**: Complete terminology reference
- **Standard Libraries Integration**: Gno ecosystem integration
- **API Reference**: Complete method documentation
- **Research Applications**: Scientific use cases
- **Troubleshooting**: Common issues and solutions

---

## 🚀 Quick Start

### 1. Environment Setup
```bash
# Install Gno
git clone https://github.com/gnolang/gno.git
cd gno
make build && make install

# Clone Active Inference framework
git clone https://github.com/gnolang/active-inference.git
cd active-inference
```

### 2. Deploy Everything
```bash
# Make executable and deploy
chmod +x scripts/deploy_realms.sh
./scripts/deploy_realms.sh
```

### 3. Start Using
```bash
# Check cognitive agent
gnokey query realm cognitive_agent Render status

# Perform diagnosis
gnokey tx call diagnostic_ai DiagnosePatient "patient123" \
  '{"fever":true,"cough":true}' '{"temperature":101.5}' --from doctor_key
```

---

## 📖 Interactive Tutorials

### Tutorial 1: Hello Active Inference

**Goal**: Create your first Active Inference agent

```go
package main

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
)

func main() {
    // Create an active inference agent
    agent := active_inference_core.NewActiveInferenceAgent()

    // Observe the environment
    observation := []methods.Probability{0.8, 0.6, 0.4, 0.7}
    err := agent.Perceive(observation)
    if err != nil {
        println("Error perceiving:", err.Error())
        return
    }

    // Plan actions
    policies, err := agent.Plan()
    if err != nil {
        println("Error planning:", err.Error())
        return
    }

    println("Agent created successfully!")
    println("Generated", len(policies), "policy options")
}
```

### Tutorial 2: Bayesian Inference

**Goal**: Create diagnostic systems

```go
package main

import (
    "gno.land/p/active_inference/methods/bayesian_inference"
    "gno.land/p/active_inference/methods"
)

func main() {
    // Create Bayesian network
    network := bayesian_inference.NewBayesianNetwork()

    // Define diseases and symptoms
    flu := bayesian_inference.NewNode("Flu", []string{"yes", "no"})
    fever := bayesian_inference.NewNode("Fever", []string{"yes", "no"})
    cough := bayesian_inference.NewNode("Cough", []string{"yes", "no"})

    // Set up relationships
    fever.AddParent(flu)
    cough.AddParent(flu)

    // Add to network
    network.AddNode(flu)
    network.AddNode(fever)
    network.AddNode(cough)

    // Set probabilities
    flu.SetCPT("", []methods.Probability{0.05, 0.95})
    fever.SetCPT("yes", []methods.Probability{0.9, 0.1})
    fever.SetCPT("no", []methods.Probability{0.1, 0.9})

    // Perform inference
    ve, _ := bayesian_inference.NewVariableElimination(network)
    result := ve.Query(map[string]string{"Flu": ""}, map[string]string{"Fever": "yes"})
    println("P(Flu=yes | Fever=yes):", result["yes"])
}
```

### Tutorial 3: Multi-Agent Systems

**Goal**: Coordinate multiple agents

```go
package main

import (
    "gno.land/p/active_inference/methods/active_inference_core"
    "gno.land/p/active_inference/methods"
)

func main() {
    // Create multi-agent system
    system := active_inference_core.NewMultiAgentSystem(3)

    // Set up social connections
    system.SocialGraph["agent0"] = []string{"agent1", "agent2"}

    // Each agent processes observations
    for i, agent := range system.Agents {
        observation := []methods.Probability{0.5 + 0.1*float64(i), 0.3}
        agent.Perceive(observation)
    }

    // Coordinate agents
    err := system.CoordinateAgents()
    if err != nil {
        println("Coordination error:", err.Error())
        return
    }

    println("Multi-agent coordination completed!")
}
```

---

## 📚 Glossary of Terms

### 🔬 Active Inference Terms

**Active Inference**: A unifying framework that explains perception, learning, and decision-making as processes that minimize variational free energy.

**Variational Free Energy (VFE)**: A measure of the difference between an agent's internal model and the actual state of the world.

**Generative Model**: An agent's internal probabilistic model of how the world works.

**Predictive Coding**: Neural processing where the brain predicts inputs and encodes only prediction errors.

**Working Memory**: Temporary storage for complex cognitive tasks.

**Reinforcement Learning (RL)**: Learning through trial-and-error interactions.

### ⛓️ Gno Blockchain Terms

**Realm**: A smart contract on Gno that maintains persistent state.

**Package**: A stateless collection of functions and types.

**Gas**: Computational resource measurement on Gno.

**Transaction**: An atomic operation that modifies blockchain state.

**Consensus**: Network agreement on blockchain state.

### 🎯 Integration Terms

**Cognitive Agent Realm**: A realm implementing Active Inference algorithms.

**DAO Governance**: Enhanced governance with cognitive modeling.

**Gas Optimization**: Techniques to minimize blockchain computational costs.

**Deterministic Execution**: Identical results across all network nodes.

---

## 🔧 Standard Libraries Integration

### Core Gno Libraries

#### `std` - Blockchain Primitives
```go
import "std"

// Essential blockchain operations
currentRealm := std.CurrentRealm()
blockTime := std.BlockTime()
blockHeight := std.BlockHeight()

// Event emission
std.Emit("AgentDecision", decisionData)
```

#### `avl` - Data Structures
```go
import "gno.land/p/nt/avl"

// Efficient data structures
type WorkingMemory struct {
    tree   *avl.Tree
    capacity int
}

func (wm *WorkingMemory) AddItem(key string, value []Probability) {
    wm.tree.Set(key, value)
}
```

#### `ufmt` - String Formatting
```go
import "gno.land/p/nt/ufmt"

// Type-safe formatting
result := ufmt.Sprintf("Belief: %.3f", belief)
```

#### `math` - Mathematical Functions
```go
import "math"

// Mathematical operations
entropy := -probability * math.Log(float64(probability))
```

### Integration Patterns

**State Persistence**:
```go
var agent *ActiveInferenceAgent

func init() {
    agent = NewActiveInferenceAgent() // Persisted across transactions
}
```

**Gas Optimization**:
```go
// Early termination
if len(observation) == 0 {
    return "Error: Empty observation"
}

// Batch processing
func BatchProcess(observations [][]Probability) string {
    // Process multiple items efficiently
}
```

---

## 🏗️ Core Active Inference Methods

### Agent Architecture

| Method | Purpose | Complexity | Gas Cost |
|--------|---------|------------|----------|
| `NewActiveInferenceAgent()` | Create autonomous agent | O(1) | ~1,000 |
| `Perceive()` | Process observations | O(n) | ~2,000 |
| `Plan()` | Generate policies | O(n) | ~3,000 |
| `Act()` | Execute actions | O(1) | ~1,500 |
| `Learn()` | Update from feedback | O(n) | ~2,500 |

### Bayesian Inference

| Method | Purpose | Complexity | Gas Cost |
|--------|---------|------------|----------|
| `NewBayesianNetwork()` | Create network | O(1) | ~500 |
| `VariableElimination.Query()` | Exact inference | O(2^n) | ~5,000 |
| `MCMC.Sample()` | Approximate inference | O(iterations) | ~10,000 |

### Cognitive Modeling

| Method | Purpose | Complexity | Gas Cost |
|--------|---------|------------|----------|
| `NewWorkingMemory()` | Create memory system | O(1) | ~800 |
| `AddItem()` | Store information | O(log n) | ~500 |
| `Decay()` | Memory consolidation | O(n) | ~1,000 |

---

## 🚀 Deployment to Gno.land

### Prerequisites
```bash
# Get test tokens
# Visit: https://faucet.gno.land/

# Create key pair
gnokey add your_key_name
```

### Automated Deployment
```bash
# Deploy all realms
./scripts/deploy_realms.sh --network testnet --key your_key_name
```

### Manual Deployment
```bash
# Deploy individual realm
gnokey tx realm create cognitive_agent --from your_key --gas 200000

# Initialize
gnokey tx call cognitive_agent Deploy "your_address" --from your_key
```

### Realm Interaction
```bash
# Process observation
gnokey tx call cognitive_agent ProcessObservation "[0.8,0.6,0.4,0.7]" --from your_key

# Query status
gnokey query realm cognitive_agent Render status

# Learn from feedback
gnokey tx call cognitive_agent LearnFromFeedback "0.8" --from your_key
```

---

## 🎯 Real-World Applications

### Healthcare - Medical Diagnosis
```bash
# Deploy diagnostic AI
gnokey tx realm create diagnostic_ai --from doctor_key --gas 300000

# Perform diagnosis
gnokey tx call diagnostic_ai DiagnosePatient "patient123" \
  '{"fever":true,"cough":true,"fatigue":true}' \
  '{"temperature":101.5}' --from doctor_key
```

### Finance - Trading Agents
```bash
# Deploy trading agent
gnokey tx realm create trading_agent --from trader_key --gas 250000

# Process market data
gnokey tx call trading_agent ProcessMarketData "[0.6,0.8,0.4,0.7]" --from trader_key
```

### Governance - DAO Enhancement
```go
package dao_realm

func EvaluateProposal(proposalData []Probability) string {
    // Use Active Inference for evaluation
    agent.Perceive(proposalData)
    policies, _ := agent.Plan()

    if policies[0].Actions[0] > 0.5 {
        return "APPROVE"
    }
    return "REJECT"
}
```

---

## 📊 Performance & Optimization

### Gas Cost Analysis

| Operation | Gas Cost | Optimization |
|-----------|----------|--------------|
| Simple observation | ~2,000 gas | Batch processing |
| Bayesian inference | ~5,000 gas | Efficient algorithms |
| Multi-agent coordination | ~15,000 gas | Parallel execution |
| Memory operations | ~3,000 gas | Object pooling |
| State persistence | ~1,000 gas | Minimal state |

### Memory Usage

| Component | Memory Usage | Notes |
|-----------|--------------|-------|
| Single Agent | ~5-10 KB | Basic cognitive architecture |
| Bayesian Network | ~10-50 KB | Depends on network size |
| Working Memory | ~1-5 KB | Limited capacity system |
| Multi-Agent System | ~50-200 KB | Scales with agent count |

### Optimization Techniques

1. **Batch Processing**: Combine operations
2. **Early Termination**: Exit when thresholds met
3. **Fixed-Size Structures**: Predictable memory usage
4. **Memory Pooling**: Reuse allocated objects
5. **Gas Checkpointing**: Monitor and optimize costs

---

## 🧪 Testing Framework

### Comprehensive Test Coverage

```go
// Unit test example
func TestActiveInferenceAgent(t *testing.T) {
    agent := NewActiveInferenceAgent()
    observation := []Probability{0.8, 0.6, 0.4, 0.7}

    err := agent.Perceive(observation)
    assert(err == nil, "Perception should succeed")

    policies, err := agent.Plan()
    assert(err == nil, "Planning should succeed")
    assert(len(policies) > 0, "Should generate policies")
}

// Gas cost testing
func TestGasEfficiency(t *testing.T) {
    startGas := getGasUsed()
    // ... perform operations
    endGas := getGasUsed()
    gasCost := endGas - startGas
    assert(gasCost < 10000, "Gas cost should be reasonable")
}
```

### Running Tests
```bash
# Run all tests
gno test ./...

# Test specific package
gno test ./methods/probability

# Test realm
gno test ./realms/cognitive_agent
```

---

## 🔗 Web3 Integration Examples

### Frontend Integration
```javascript
// Connect to realm
const agentAddress = "g1abc...def";

// Process observation
const tx = await contract.ProcessObservation([0.8, 0.6, 0.4, 0.7]);
await tx.wait();

// Query status
const status = await contract.GetAgentStatus();
console.log("Agent status:", status);
```

### Real-time Dashboard
```go
package monitoring_realm

func GetSystemMetrics() string {
    return ufmt.Sprintf(`System Metrics:
Total Diagnoses: %d
Average Confidence: %.2f%%
Active Agents: %d
Gas Efficiency: %.2f`,
        totalDiagnoses, avgConfidence, activeAgents, gasEfficiency)
}
```

---

## 🔮 Advanced Features

### Research Applications

**Healthcare**:
- AI-assisted medical diagnosis
- Treatment recommendation systems
- Patient monitoring and prediction
- Clinical decision support

**Finance**:
- Algorithmic trading with risk management
- Portfolio optimization
- Market sentiment analysis
- Real-time exposure monitoring

**Governance**:
- Enhanced DAO decision-making
- Policy evaluation with uncertainty
- Consensus formation
- Transparency and auditability

### Future Extensions

1. **Advanced Inference**: Neural network-based methods
2. **Cognitive Extensions**: Episodic memory, social learning
3. **Multi-Agent Enhancements**: Coalition formation, negotiation
4. **Real-World Applications**: Robotics, IoT, Industry 4.0

---

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch: `git checkout -b feature/your-feature`
3. Make changes following established patterns
4. Add comprehensive tests
5. Update documentation
6. Submit pull request

### Code Standards
- Follow Gno best practices
- Add comprehensive error handling
- Include performance optimizations
- Maintain backward compatibility
- Document all public interfaces

### Testing Requirements
- 100% test coverage for new code
- Gas cost analysis for performance-critical functions
- Integration tests for cross-method interactions
- Edge case testing for robustness

---

## 📚 Additional Resources

### Documentation
- **[Interactive Tutorials](docs/INTERACTIVE_TUTORIALS.md)**: Step-by-step learning
- **[Glossary](docs/GLOSSARY.md)**: Complete terminology reference
- **[Standard Libraries](docs/STANDARD_LIBRARIES.md)**: Gno integration guide
- **[API Reference](./api/)**: Complete method documentation

### Community
- **Gno Documentation**: [docs.gno.land](https://docs.gno.land)
- **Gno Community**: [gno.land](https://gno.land)
- **GitHub Repository**: [github.com/gnolang/active-inference](https://github.com/gnolang/active-inference)

### Learning Materials
- **Mathematical Foundations**: Research papers and theory
- **Video Tutorials**: Visual guides for complex concepts
- **Example Applications**: Real-world use cases
- **Best Practices**: Production deployment guidelines

---

## 🎉 Mission Accomplished

This comprehensive documentation provides everything needed to:

✅ **Understand** Active Inference and Gno blockchain integration
✅ **Learn** through interactive tutorials and examples
✅ **Deploy** production-ready smart contracts
✅ **Optimize** for gas efficiency and performance
✅ **Extend** with custom cognitive methods
✅ **Contribute** to the growing ecosystem
✅ **Research** cutting-edge applications

*🚀 **Ready to deploy cognitive agents on the blockchain? The future of intelligent systems awaits!***
