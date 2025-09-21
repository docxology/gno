# Active Inference Methods for Gno Blockchain

This repository provides a comprehensive collection of professional methods for Active Inference, Bayesian learning, Free Energy Principle, and cognitive modeling on the Gno blockchain.

## Overview

Active Inference is a unifying framework that explains perception, learning, and decision-making as processes that minimize variational free energy. This implementation brings these powerful cognitive and probabilistic methods to smart contracts on Gno.land.

## Repository Structure

```
active_inference/
├── methods/                    # Core method implementations
│   ├── probability.gno        # Probabilistic data structures
│   ├── bayesian_inference.gno # Bayesian network inference
│   ├── free_energy_principle.gno # Free Energy Principle methods
│   ├── cognitive_modeling.gno # Cognitive modeling primitives
│   └── active_inference_core.gno # Active inference integration
├── examples/                   # Thin orchestrator examples
│   ├── basic_inference/       # Bayesian inference demonstration
│   ├── social_coordination/   # Multi-agent coordination
│   └── decision_making/       # Ensemble decision support
└── docs/                      # Documentation
    └── README.md             # This file
```

## Core Methods

### Probabilistic Foundations

The `probability` package provides fundamental probabilistic data structures:

- **Probability**: Represents probability values with validation
- **LogProbability**: Log-space probability for numerical stability
- **Distribution**: Probability distributions over discrete outcomes
- **ConditionalDistribution**: Conditional probability P(X|Y)
- **JointDistribution**: Joint probability distributions P(X,Y)

### Bayesian Inference

The `bayesian_inference` package implements:

- **BayesianNetwork**: Directed acyclic graphs for probabilistic relationships
- **VariableElimination**: Exact inference using variable elimination algorithm
- **MarkovChainMonteCarlo**: Approximate inference using MCMC sampling
- **BeliefPropagation**: Efficient inference in tree-structured networks

### Free Energy Principle

The `free_energy_principle` package implements:

- **GenerativeModel**: Hierarchical generative models
- **VariationalInference**: Approximate inference via variational methods
- **PredictiveCoding**: Predictive coding for hierarchical inference
- **ActiveInference**: Integration of perception, action, and learning

### Cognitive Modeling

The `cognitive_modeling` package provides:

- **CognitiveModel**: Complete cognitive architecture
- **WorkingMemory**: Limited-capacity working memory system
- **LongTermMemory**: Consolidation-based long-term memory
- **AttentionSystem**: Attention mechanisms and salience computation
- **LearningSystem**: Reinforcement and habit learning
- **MetaCognition**: Meta-cognitive monitoring and control

### Active Inference Core

The `active_inference_core` package integrates everything:

- **ActiveInferenceAgent**: Autonomous agent with full cognitive architecture
- **MultiAgentSystem**: Coordination of multiple active inference agents
- **EmergentBehaviorSystem**: Collective behavior emergence
- **DecisionSupportSystem**: Ensemble decision-making
- **AdaptiveController**: Parameter adaptation based on performance

## Thin Orchestrator Examples

### Basic Inference Example

Demonstrates fundamental Bayesian inference operations:

```go
example := NewBasicInferenceExample()

// Perform diagnostic inference
result := example.DemonstrateDiagnosticInference()

// Show causal reasoning
causal := example.DemonstrateCausalReasoning()

// Handle uncertainty
uncertainty := example.DemonstrateUncertaintyHandling()
```

### Social Coordination Example

Shows multi-agent coordination with theory of mind:

```go
example := NewSocialCoordinationExample()

// Run coordination rounds
result := example.RunCoordinationRound(sharedObservation)

// Demonstrate theory of mind
theoryOfMind := example.DemonstrateTheoryOfMind()

// Show collective decision making
collective := example.DemonstrateCollectiveDecisionMaking()
```

### Decision Making Example

Demonstrates ensemble decision support:

```go
example := NewDecisionMakingExample()

// Make ensemble decisions
result := example.MakeDecision(scenarioIndex)

// Show adaptive decision making
adaptive := example.DemonstrateAdaptiveDecisionMaking()

// Quantify uncertainty
uncertainty := example.DemonstrateUncertaintyQuantification()
```

## Key Features

### 100% Test Coverage

Every method includes comprehensive tests covering:
- Normal operation scenarios
- Edge cases and boundary conditions
- Error handling and validation
- Performance characteristics
- Integration with other methods

### Gas-Efficient Design

All methods are optimized for blockchain execution:
- Deterministic behavior for consensus
- Minimal memory allocation
- Efficient numerical computations
- Bounded iteration limits

### Modular Architecture

Methods follow Gno's philosophy of modularity:
- Clean interfaces between components
- Reusable building blocks
- Minimal dependencies
- Composable functionality

### Research-Based Implementation

Methods are grounded in established research:
- **Active Inference**: Friston et al. (various papers)
- **Free Energy Principle**: Friston (2010)
- **Bayesian Networks**: Pearl (1988)
- **Predictive Coding**: Rao & Ballard (1999)

## Usage in Smart Contracts

### Basic Setup

```go
import (
    "gno.land/p/active_inference/methods"
    "gno.land/p/active_inference/methods/bayesian_inference"
)

// Create a Bayesian network
network := bayesian_inference.NewBayesianNetwork()

// Add nodes and relationships
fever := bayesian_inference.NewNode("Fever", []string{"yes", "no"})
cough := bayesian_inference.NewNode("Cough", []string{"yes", "no"})

// Perform inference
inference := bayesian_inference.NewVariableElimination(network)
result := inference.Query(query, evidence)
```

### Active Inference Agent

```go
import "gno.land/p/active_inference/methods/active_inference_core"

// Create an autonomous agent
agent := active_inference_core.NewActiveInferenceAgent()

// Agent perceives and acts autonomously
err := agent.Perceive(observation)
if err != nil {
    // Handle error
}

policies, err := agent.Plan()
if err != nil {
    // Handle error
}

err = agent.Act(selectedPolicy)
if err != nil {
    // Handle error
}
```

### Multi-Agent Coordination

```go
// Create multi-agent system
system := active_inference_core.NewMultiAgentSystem(5)

// Coordinate agents
err := system.CoordinateAgents()
if err != nil {
    // Handle error
}
```

## Mathematical Foundations

### Variational Free Energy

The variational free energy F is defined as:

```
F = <log q(s) - log p(o,s)>_q(s)
```

Where:
- `q(s)` is the variational posterior over states
- `p(o,s)` is the generative model
- `<>` denotes expectation under q(s)

### Active Inference

Active inference minimizes expected free energy:

```
G = <F> + H[Q(π)]
```

Where:
- `G` is expected free energy
- `H[Q(π)]` is policy entropy for exploration
- `Q(π)` is posterior over policies

## Performance Characteristics

### Computational Complexity

| Method | Time Complexity | Space Complexity | Use Case |
|--------|----------------|------------------|----------|
| Variable Elimination | O(2^n) | O(n) | Small networks, exact inference |
| MCMC Sampling | O(samples × n) | O(n) | Large networks, approximate inference |
| Belief Propagation | O(n) | O(n) | Tree-structured networks |
| Variational Inference | O(iterations × n) | O(n) | Complex generative models |

### Gas Costs (Estimated)

| Operation | Gas Cost | Notes |
|-----------|----------|-------|
| Simple inference | ~50k gas | Basic Bayesian inference |
| MCMC sampling (1000) | ~200k gas | Approximate inference |
| Variational inference | ~100k gas | Single iteration |
| Multi-agent coordination | ~300k gas | 5 agents, 1 round |

## Integration with Gno Ecosystem

### Compatible with Existing Libraries

The methods integrate seamlessly with existing Gno libraries:

```go
import (
    "gno.land/p/nt/avl"     // For efficient data structures
    "gno.land/p/nt/ufmt"    // For formatted output
    "std"                   // For blockchain integration
)
```

### Realm Integration

Methods work within Gno realms for persistent state:

```go
// Global variables persist across transactions
var agent *ActiveInferenceAgent
var network *BayesianNetwork

func init() {
    // Initialize during realm deployment
    agent = NewActiveInferenceAgent()
    network = NewBayesianNetwork()
}

func ProcessObservation(_ realm, observation []Probability) string {
    // Use agent for processing
    err := agent.Perceive(observation)
    if err != nil {
        return "Error processing observation"
    }

    return "Observation processed successfully"
}
```

## Development Guidelines

### Testing Requirements

All methods must have comprehensive tests:

```go
func TestMethod(t *testing.T) {
    // Test normal operation
    // Test edge cases
    // Test error conditions
    // Test performance bounds
}
```

### Documentation Standards

All public methods must be documented:

```go
// MethodName performs operation with parameters.
// It returns result and error if operation fails.
// Parameters:
//   - param1: description of param1
//   - param2: description of param2
// Returns:
//   - result: description of result
//   - error: description of error conditions
func MethodName(param1 Type, param2 Type) (result Type, err error) {
    // Implementation
}
```

### Performance Monitoring

Methods include built-in performance monitoring:

```go
// Track computational resources
start := time.Now()
// ... method implementation ...
elapsed := time.Since(start)

// Log for optimization
ufmt.Printf("Method completed in %v", elapsed)
```

## Future Extensions

### Planned Enhancements

1. **Advanced Inference Algorithms**
   - Junction tree algorithm for exact inference
   - Hamiltonian Monte Carlo for efficient sampling
   - Neural network-based variational inference

2. **Cognitive Extensions**
   - Working memory models with decay and interference
   - Episodic memory with temporal context
   - Social learning and cultural transmission

3. **Multi-Agent Enhancements**
   - Coalition formation algorithms
   - Negotiation protocols
   - Distributed consensus mechanisms

4. **Real-World Applications**
   - Decentralized autonomous organizations (DAOs)
   - Prediction markets with uncertainty quantification
   - Cognitive robotics coordination

## Contributing

### Development Setup

1. Clone the repository
2. Set up Gno development environment
3. Run tests: `gno test ./active_inference/...`
4. Add new methods following established patterns
5. Ensure 100% test coverage
6. Update documentation

### Code Standards

- Follow Gno best practices from `docs/resources/effective-gno.md`
- Use meaningful variable and function names
- Include comprehensive error handling
- Add performance optimizations where beneficial
- Maintain backward compatibility

### Testing Guidelines

- Unit tests for all public methods
- Integration tests for method combinations
- Performance tests for computational bounds
- Fuzzing tests for edge cases
- Documentation tests for examples

## License and Attribution

This implementation is based on research in active inference, Bayesian methods, and cognitive modeling. Key references:

- Friston, K. (2010). The free-energy principle: a unified brain theory?
- Friston, K., et al. (2017). Active inference and epistemic value
- Pearl, J. (1988). Probabilistic Reasoning in Intelligent Systems
- Rao, R. & Ballard, D. (1999). Predictive coding in the visual cortex

## Support

For questions, issues, or contributions:

- GitHub Issues: Report bugs and request features
- Documentation: Comprehensive guides in `docs/` directory
- Examples: Working code in `examples/` directory
- Tests: Extensive test coverage demonstrates usage patterns

---

*This repository represents a comprehensive implementation of active inference methods for the Gno blockchain, designed for both research and production use cases.*
