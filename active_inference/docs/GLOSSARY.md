# 📚 Active Inference & Gno Blockchain Glossary

A comprehensive glossary of terms used in Active Inference, cognitive modeling, and Gno blockchain development.

## 🔬 Active Inference Terms

### Core Concepts

**Active Inference**
> A unifying framework that explains perception, learning, and decision-making as processes that minimize variational free energy. Active Inference agents actively sample their environment to confirm or update their internal models.

**Variational Free Energy (VFE)**
> A measure of the difference between an agent's internal model and the actual state of the world. Minimizing VFE drives both perception (model updating) and action (information gathering).

**Generative Model**
> An agent's internal probabilistic model of how the world works, including both the likelihood of observations given hidden states and priors over those hidden states.

**Predictive Coding**
> A theory of neural processing where the brain constantly predicts sensory inputs and only encodes the differences (prediction errors) between predictions and actual inputs.

### Cognitive Components

**Working Memory**
> A cognitive system that temporarily holds and manipulates information for complex cognitive tasks. In Active Inference, working memory manages the current context and recent observations.

**Long-term Memory**
> Persistent storage of learned patterns, habits, and knowledge. In cognitive modeling, long-term memory consolidates experiences for future use.

**Attention System**
> Mechanisms that prioritize certain stimuli or information for processing. In Active Inference, attention allocates cognitive resources to minimize prediction errors.

**Meta-Cognition**
> "Thinking about thinking" - the ability to monitor and control one's own cognitive processes. Includes confidence assessment and strategy selection.

**Theory of Mind**
> The ability to understand and predict the mental states of others. In multi-agent systems, theory of mind enables social coordination and cooperation.

### Learning & Adaptation

**Reinforcement Learning (RL)**
> Learning through trial-and-error interactions with an environment. In Active Inference, RL optimizes policies that minimize expected free energy.

**Habit Formation**
> The process of turning deliberate actions into automatic responses through repetition. Habits reduce cognitive load and improve efficiency.

**Belief Updating**
> The process of modifying internal models based on new evidence. In Bayesian terms, this follows Bayes' theorem to update posterior beliefs.

**Policy Selection**
> Choosing optimal courses of action. In Active Inference, policies are selected to minimize expected free energy over future time steps.

## ⛓️ Gno Blockchain Terms

### Core Concepts

**Realm**
> A smart contract on Gno that maintains persistent state. Realms are the primary unit of persistent computation on Gno.land.

**Package**
> A stateless collection of functions and types. Pure packages cannot maintain state but can be used by realms and other packages.

**Gno Module**
> A collection of packages that can be imported and used together. Modules follow semantic versioning and dependency management.

**Transaction**
> An atomic operation that modifies blockchain state. In Gno, transactions execute realm functions or deploy new realms/packages.

### Development Tools

**Gno CLI**
> Command-line interface for Gno development. Used for running, testing, and deploying Gno code.

**Gno VM**
> Virtual machine that executes Gno bytecode on the blockchain. Ensures deterministic execution across all nodes.

**Gno.land**
> The official blockchain platform running Gno. Provides development tools, testnet, and mainnet environments.

**Realm Deployment**
> The process of creating and initializing a new realm on the blockchain. Involves gas fees and consensus validation.

### Gas & Economics

**Gas**
> Computational resource measurement on Gno. Each operation consumes gas, and users pay fees proportional to computation complexity.

**Gas Price**
> The amount of GNO tokens paid per unit of gas. Determined by network congestion and user preferences.

**Gas Limit**
> Maximum gas allowed for a transaction. Prevents infinite loops and ensures network stability.

**Gas Estimation**
> Predicting gas costs for transactions before execution. Important for user experience and cost management.

## 🎯 Integration Terms

### Active Inference + Blockchain

**Cognitive Agent Realm**
> A realm that implements Active Inference algorithms for autonomous decision-making on the blockchain.

**DAO Governance**
> Decentralized autonomous organization governance enhanced with cognitive modeling for better decision-making.

**Prediction Markets**
> Markets where participants trade on future outcomes, enhanced with uncertainty quantification from Active Inference.

**Cognitive Security**
> Security mechanisms that use cognitive modeling to detect anomalies and threats in blockchain systems.

### Technical Integration

**Deterministic Execution**
> Requirement that all operations produce identical results across all nodes. Critical for consensus in blockchain systems.

**Gas Optimization**
> Techniques to minimize computational costs on blockchain. Includes algorithmic improvements and efficient data structures.

**State Persistence**
> Maintaining data across transactions using realms. Essential for learning and adaptation in cognitive systems.

**Cross-Realm Communication**
> Mechanisms for different realms to interact and share information securely.

## 📊 Probabilistic Terms

### Distributions

**Categorical Distribution**
> Discrete probability distribution over a finite set of outcomes. Used for representing preferences or classifications.

**Gaussian Distribution**
> Continuous probability distribution with bell-shaped curve. Commonly used for modeling uncertainty in continuous variables.

**Beta Distribution**
> Distribution over probabilities (values between 0 and 1). Useful for modeling beliefs about success rates.

**Dirichlet Distribution**
> Multivariate generalization of Beta distribution. Used for modeling distributions over categorical distributions.

### Information Theory

**Entropy**
> Measure of uncertainty or information content in a probability distribution. Higher entropy indicates more uncertainty.

**Mutual Information**
> Amount of information shared between two random variables. Measures statistical dependence.

**Kullback-Leibler Divergence (KL)**
> Measure of difference between two probability distributions. Used in variational inference.

**Cross-Entropy**
> Measure of difference between predicted and actual distributions. Commonly used as loss function.

## 🤖 Machine Learning Terms

### Reinforcement Learning

**Q-Learning**
> Model-free reinforcement learning algorithm that learns action values. Uses temporal difference learning.

**SARSA**
> On-policy reinforcement learning algorithm that learns from actual experience. Stands for State-Action-Reward-State-Action.

**Policy Gradient**
> Family of reinforcement learning algorithms that optimize policies directly. Effective for continuous action spaces.

**Actor-Critic**
> Reinforcement learning architecture with separate policy (actor) and value (critic) networks.

**Multi-Armed Bandit**
> Decision problem where agent must choose between options with unknown rewards. Models exploration vs exploitation.

### Bayesian Methods

**Bayesian Network**
> Probabilistic graphical model representing conditional dependencies between random variables.

**Variable Elimination**
> Exact inference algorithm for Bayesian networks. Eliminates variables to compute marginal distributions.

**Markov Chain Monte Carlo (MCMC)**
> Class of algorithms for sampling from probability distributions. Used for approximate inference.

**Belief Propagation**
> Message-passing algorithm for inference in graphical models. Efficient for tree-structured networks.

## 🔧 Development Terms

### Testing & Quality

**Unit Test**
> Test that verifies the behavior of individual functions or methods in isolation.

**Integration Test**
> Test that verifies the interaction between multiple components or modules.

**Gas Test**
> Test that measures computational cost (gas usage) of operations on the blockchain.

**Deterministic Test**
> Test that ensures operations produce identical results across different executions.

### Performance

**Complexity Analysis**
> Mathematical analysis of algorithm efficiency in terms of time and space requirements.

**Gas Profiling**
> Measuring and analyzing gas consumption patterns in smart contracts.

**Memory Optimization**
> Techniques to minimize memory usage in blockchain applications.

**Concurrent Processing**
> Executing multiple operations simultaneously while maintaining determinism.

## 📈 Advanced Concepts

### Multi-Agent Systems

**Emergent Behavior**
> Complex patterns that arise from simple interactions between multiple agents. Not explicitly programmed but emerges from collective behavior.

**Social Coordination**
> Mechanisms that enable multiple agents to work together towards common goals. Includes communication and cooperation protocols.

**Collective Intelligence**
> Intelligence that emerges from the collaboration and competition of many agents. Often superior to individual intelligence.

**Consensus Formation**
> Process by which agents reach agreement on beliefs or decisions. Critical for multi-agent coordination.

### Cognitive Architectures

**Hierarchical Planning**
> Planning at multiple levels of abstraction, from high-level goals to specific actions.

**Attention Allocation**
> Distributing cognitive resources to different tasks or stimuli based on importance.

**Memory Consolidation**
> Process of transferring information from short-term to long-term memory.

**Goal System**
> Set of objectives and motivations that drive agent behavior and decision-making.

## 🎨 Visualization Terms

### Cognitive Visualization

**Belief Landscape**
> Visual representation of an agent's probability distributions over different states or outcomes.

**Attention Heatmap**
> Visual display showing where an agent is focusing its cognitive resources.

**Decision Tree**
> Hierarchical representation of decision-making processes and their outcomes.

**Time Series Analysis**
> Visualization of how beliefs, actions, or performance change over time.

### Blockchain Visualization

**Transaction Flow**
> Animated representation of how transactions move through the network and get processed.

**State Evolution**
> Visual depiction of how blockchain state changes over time.

**Gas Consumption**
> Charts and graphs showing computational resource usage patterns.

**Consensus Animation**
> Visual representation of how consensus is reached across network nodes.

---

## 🔗 Cross-References

For more detailed information, see:

- **[Active Inference Research](./research/active_inference.md)** - Mathematical foundations and research papers
- **[Gno Documentation](./gno/overview.md)** - Official Gno blockchain documentation
- **[API Reference](./api/overview.md)** - Complete API documentation for all methods
- **[Examples](./examples/overview.md)** - Working code examples and tutorials

## 📝 Contributing to the Glossary

This glossary is a living document. To contribute:

1. **Add New Terms**: Use clear, concise definitions with examples where helpful
2. **Update Definitions**: Keep terms current with latest research and practices
3. **Add Cross-References**: Link related terms for better navigation
4. **Include Examples**: Provide code examples or use cases where appropriate

*Maintained by the Active Inference on Gno community.*
