// Package reinforcement_learning provides reinforcement learning methods
// for cognitive modeling and decision-making on the Gno blockchain.
//
// This package implements:
// - Q-Learning: Value-based reinforcement learning
// - SARSA: On-policy temporal difference learning
// - Policy Gradients: Policy-based reinforcement learning
// - Actor-Critic: Combined value and policy methods
// - Multi-armed bandits: Exploration-exploitation algorithms
package reinforcement_learning

import (
	"math"
	"gno.land/p/nt/ufmt"
	"gno.land/p/active_inference/methods"
)

// QLearningAgent implements Q-learning algorithm
type QLearningAgent struct {
	QTable         map[string]map[string]methods.Probability // state -> action -> value
	LearningRate   methods.Probability
	DiscountFactor methods.Probability
	ExplorationRate methods.Probability
	MinExplorationRate methods.Probability
	ExplorationDecay methods.Probability
	Actions        []string
}

// NewQLearningAgent creates a new Q-learning agent
func NewQLearningAgent(actions []string) *QLearningAgent {
	return &QLearningAgent{
		QTable:             make(map[string]map[string]methods.Probability),
		LearningRate:       0.1,
		DiscountFactor:     0.95,
		ExplorationRate:    1.0,
		MinExplorationRate: 0.01,
		ExplorationDecay:   0.995,
		Actions:            actions,
	}
}

// GetQValue returns the Q-value for a state-action pair
func (qla *QLearningAgent) GetQValue(state, action string) methods.Probability {
	if stateTable, exists := qla.QTable[state]; exists {
		if value, exists := stateTable[action]; exists {
			return value
		}
	}
	return 0 // Default Q-value
}

// SetQValue sets the Q-value for a state-action pair
func (qla *QLearningAgent) SetQValue(state, action string, value methods.Probability) {
	if _, exists := qla.QTable[state]; !exists {
		qla.QTable[state] = make(map[string]methods.Probability)
	}
	qla.QTable[state][action] = value
}

// ChooseAction selects an action using epsilon-greedy policy
func (qla *QLearningAgent) ChooseAction(state string) string {
	// Epsilon-greedy exploration
	if methods.Probability(math.Random()) < qla.ExplorationRate {
		// Explore: random action
		return qla.Actions[int(methods.Probability(len(qla.Actions))*methods.Probability(math.Random()))]
	}

	// Exploit: best action
	bestAction := ""
	bestValue := methods.Probability(math.Inf(-1))

	for _, action := range qla.Actions {
		value := qla.GetQValue(state, action)
		if value > bestValue {
			bestValue = value
			bestAction = action
		}
	}

	if bestAction == "" {
		// No Q-values found, choose random action
		return qla.Actions[int(methods.Probability(len(qla.Actions))*methods.Probability(math.Random()))]
	}

	return bestAction
}

// Update updates the Q-table using Q-learning update rule
func (qla *QLearningAgent) Update(state, action, nextState string, reward methods.Probability) {
	currentQ := qla.GetQValue(state, action)

	// Find maximum Q-value for next state
	maxNextQ := methods.Probability(math.Inf(-1))
	for _, nextAction := range qla.Actions {
		nextQ := qla.GetQValue(nextState, nextAction)
		if nextQ > maxNextQ {
			maxNextQ = nextQ
		}
	}

	// Q-learning update: Q(s,a) = Q(s,a) + α[r + γ*max(Q(s',a')) - Q(s,a)]
	target := reward + qla.DiscountFactor*maxNextQ
	newQ := currentQ + qla.LearningRate*(target-currentQ)

	qla.SetQValue(state, action, newQ)

	// Decay exploration rate
	qla.ExplorationRate = max(qla.ExplorationRate*qla.ExplorationDecay, qla.MinExplorationRate)
}

// GetBestAction returns the best action for a state (pure exploitation)
func (qla *QLearningAgent) GetBestAction(state string) string {
	bestAction := ""
	bestValue := methods.Probability(math.Inf(-1))

	for _, action := range qla.Actions {
		value := qla.GetQValue(state, action)
		if value > bestValue {
			bestValue = value
			bestAction = action
		}
	}

	if bestAction == "" {
		return qla.Actions[0] // Default to first action
	}

	return bestAction
}

// SarsaAgent implements SARSA (State-Action-Reward-State-Action) algorithm
type SarsaAgent struct {
	QTable         map[string]map[string]methods.Probability
	LearningRate   methods.Probability
	DiscountFactor methods.Probability
	ExplorationRate methods.Probability
	Actions        []string
	LastState      string
	LastAction     string
}

// NewSarsaAgent creates a new SARSA agent
func NewSarsaAgent(actions []string) *SarsaAgent {
	return &SarsaAgent{
		QTable:         make(map[string]map[string]methods.Probability),
		LearningRate:   0.1,
		DiscountFactor: 0.95,
		ExplorationRate: 1.0,
		Actions:        actions,
	}
}

// GetQValue returns the Q-value for a state-action pair
func (sa *SarsaAgent) GetQValue(state, action string) methods.Probability {
	if stateTable, exists := sa.QTable[state]; exists {
		if value, exists := stateTable[action]; exists {
			return value
		}
	}
	return 0
}

// SetQValue sets the Q-value for a state-action pair
func (sa *SarsaAgent) SetQValue(state, action string, value methods.Probability) {
	if _, exists := sa.QTable[state]; !exists {
		sa.QTable[state] = make(map[string]methods.Probability)
	}
	sa.QTable[state][action] = value
}

// StartEpisode initializes the agent for a new episode
func (sa *SarsaAgent) StartEpisode(initialState string) string {
	action := sa.ChooseAction(initialState)
	sa.LastState = initialState
	sa.LastAction = action
	return action
}

// Step performs one step of SARSA learning
func (sa *SarsaAgent) Step(state, action string, reward methods.Probability) string {
	if sa.LastState != "" && sa.LastAction != "" {
		currentQ := sa.GetQValue(sa.LastState, sa.LastAction)
		nextQ := sa.GetQValue(state, action)

		// SARSA update: Q(s,a) = Q(s,a) + α[r + γ*Q(s',a') - Q(s,a)]
		target := reward + sa.DiscountFactor*nextQ
		newQ := currentQ + sa.LearningRate*(target-currentQ)

		sa.SetQValue(sa.LastState, sa.LastAction, newQ)
	}

	nextAction := sa.ChooseAction(state)
	sa.LastState = state
	sa.LastAction = nextAction
	return nextAction
}

// EndEpisode performs final update for episode end
func (sa *SarsaAgent) EndEpisode(finalReward methods.Probability) {
	if sa.LastState != "" && sa.LastAction != "" {
		currentQ := sa.GetQValue(sa.LastState, sa.LastAction)

		// Final update with no next state
		target := finalReward
		newQ := currentQ + sa.LearningRate*(target-currentQ)

		sa.SetQValue(sa.LastState, sa.LastAction, newQ)
	}

	sa.LastState = ""
	sa.LastAction = ""
}

// ChooseAction selects an action using epsilon-greedy policy
func (sa *SarsaAgent) ChooseAction(state string) string {
	if methods.Probability(math.Random()) < sa.ExplorationRate {
		return sa.Actions[int(methods.Probability(len(sa.Actions))*methods.Probability(math.Random()))]
	}

	bestAction := ""
	bestValue := methods.Probability(math.Inf(-1))

	for _, action := range sa.Actions {
		value := sa.GetQValue(state, action)
		if value > bestValue {
			bestValue = value
			bestAction = action
		}
	}

	if bestAction == "" {
		return sa.Actions[0]
	}

	return bestAction
}

// PolicyGradientAgent implements REINFORCE algorithm
type PolicyGradientAgent struct {
	PolicyNetwork   map[string][]methods.Probability // state -> action probabilities
	ValueNetwork    map[string]methods.Probability   // state -> value estimate
	LearningRate    methods.Probability
	DiscountFactor  methods.Probability
	Actions         []string
	Trajectory      []TrajectoryStep
}

// TrajectoryStep represents one step in an episode
type TrajectoryStep struct {
	State    string
	Action   string
	Reward   methods.Probability
	LogProb  methods.Probability
	Value    methods.Probability
}

// NewPolicyGradientAgent creates a new policy gradient agent
func NewPolicyGradientAgent(actions []string) *PolicyGradientAgent {
	return &PolicyGradientAgent{
		PolicyNetwork:  make(map[string][]methods.Probability),
		ValueNetwork:   make(map[string]methods.Probability),
		LearningRate:   0.01,
		DiscountFactor: 0.99,
		Actions:        actions,
		Trajectory:     make([]TrajectoryStep, 0),
	}
}

// GetActionProbabilities returns action probabilities for a state
func (pga *PolicyGradientAgent) GetActionProbabilities(state string) []methods.Probability {
	if probs, exists := pga.PolicyNetwork[state]; exists {
		return probs
	}

	// Initialize with uniform probabilities
	probs := make([]methods.Probability, len(pga.Actions))
	uniformProb := methods.Probability(1.0 / float64(len(pga.Actions)))
	for i := range probs {
		probs[i] = uniformProb
	}

	pga.PolicyNetwork[state] = probs
	return probs
}

// ChooseAction selects an action based on current policy
func (pga *PolicyGradientAgent) ChooseAction(state string) string {
	probs := pga.GetActionProbabilities(state)

	// Sample from categorical distribution
	cumulative := methods.Probability(0)
	randomVal := methods.Probability(math.Random())

	for i, prob := range probs {
		cumulative += prob
		if randomVal <= cumulative {
			return pga.Actions[i]
		}
	}

	return pga.Actions[0] // Fallback
}

// StoreTransition stores a transition for later policy update
func (pga *PolicyGradientAgent) StoreTransition(state, action string, reward methods.Probability) {
	probs := pga.GetActionProbabilities(state)

	// Find log probability of chosen action
	logProb := methods.Probability(0)
	for i, act := range pga.Actions {
		if act == action {
			if probs[i] > 0 {
				logProb = methods.Probability(math.Log(float64(probs[i])))
			}
			break
		}
	}

	value := pga.ValueNetwork[state]

	step := TrajectoryStep{
		State:   state,
		Action:  action,
		Reward:  reward,
		LogProb: logProb,
		Value:   value,
	}

	pga.Trajectory = append(pga.Trajectory, step)
}

// UpdatePolicy performs policy gradient update using stored trajectory
func (pga *PolicyGradientAgent) UpdatePolicy() {
	if len(pga.Trajectory) == 0 {
		return
	}

	// Calculate returns and advantages
	returns := make([]methods.Probability, len(pga.Trajectory))
	advantages := make([]methods.Probability, len(pga.Trajectory))

	// Calculate discounted returns
	returns[len(pga.Trajectory)-1] = pga.Trajectory[len(pga.Trajectory)-1].Reward
	for i := len(pga.Trajectory) - 2; i >= 0; i-- {
		returns[i] = pga.Trajectory[i].Reward + pga.DiscountFactor*returns[i+1]
	}

	// Calculate advantages (returns - baseline values)
	for i, step := range pga.Trajectory {
		advantages[i] = returns[i] - step.Value
	}

	// Update policy using REINFORCE
	for i, step := range pga.Trajectory {
		probs := pga.GetActionProbabilities(step.State)

		// Update action probabilities
		for j, action := range pga.Actions {
			if action == step.Action {
				// Increase probability of chosen action
				gradient := advantages[i] * (1 - probs[j])
				probs[j] += pga.LearningRate * step.LogProb * gradient
			} else {
				// Decrease probability of other actions
				gradient := advantages[i] * (-probs[j])
				probs[j] += pga.LearningRate * step.LogProb * gradient
			}

			// Ensure non-negative
			if probs[j] < 0 {
				probs[j] = 0
			}
		}

		// Normalize probabilities
		sum := methods.Probability(0)
		for _, prob := range probs {
			sum += prob
		}

		if sum > 0 {
			for j := range probs {
				probs[j] = probs[j] / sum
			}
		}

		pga.PolicyNetwork[step.State] = probs
	}

	// Update value function (simple average)
	for _, step := range pga.Trajectory {
		currentValue := pga.ValueNetwork[step.State]
		targetValue := returns[len(pga.Trajectory)-1] // Use final return as target
		newValue := currentValue + pga.LearningRate*(targetValue-currentValue)
		pga.ValueNetwork[step.State] = newValue
	}

	// Clear trajectory for next episode
	pga.Trajectory = nil
}

// ActorCriticAgent implements actor-critic algorithm
type ActorCriticAgent struct {
	ActorNetwork   map[string][]methods.Probability // Policy: state -> action probabilities
	CriticNetwork  map[string]methods.Probability   // Value: state -> value estimate
	ActorLearningRate  methods.Probability
	CriticLearningRate methods.Probability
	DiscountFactor methods.Probability
	Actions        []string
	LastState      string
	LastAction     string
	LastValue      methods.Probability
}

// NewActorCriticAgent creates a new actor-critic agent
func NewActorCriticAgent(actions []string) *ActorCriticAgent {
	return &ActorCriticAgent{
		ActorNetwork:       make(map[string][]methods.Probability),
		CriticNetwork:      make(map[string]methods.Probability),
		ActorLearningRate:  0.01,
		CriticLearningRate: 0.02,
		DiscountFactor:     0.99,
		Actions:            actions,
	}
}

// GetActionProbabilities returns action probabilities for a state
func (aca *ActorCriticAgent) GetActionProbabilities(state string) []methods.Probability {
	if probs, exists := aca.ActorNetwork[state]; exists {
		return probs
	}

	// Initialize with uniform probabilities
	probs := make([]methods.Probability, len(aca.Actions))
	uniformProb := methods.Probability(1.0 / float64(len(aca.Actions)))
	for i := range probs {
		probs[i] = uniformProb
	}

	aca.ActorNetwork[state] = probs
	return probs
}

// GetValue returns the value estimate for a state
func (aca *ActorCriticAgent) GetValue(state string) methods.Probability {
	if value, exists := aca.CriticNetwork[state]; exists {
		return value
	}
	return 0 // Default value
}

// SetValue sets the value estimate for a state
func (aca *ActorCriticAgent) SetValue(state string, value methods.Probability) {
	aca.CriticNetwork[state] = value
}

// ChooseAction selects an action based on current policy
func (aca *ActorCriticAgent) ChooseAction(state string) string {
	probs := aca.GetActionProbabilities(state)

	// Sample from categorical distribution
	cumulative := methods.Probability(0)
	randomVal := methods.Probability(math.Random())

	for i, prob := range probs {
		cumulative += prob
		if randomVal <= cumulative {
			return aca.Actions[i]
		}
	}

	return aca.Actions[0]
}

// StartEpisode initializes the agent for a new episode
func (aca *ActorCriticAgent) StartEpisode(initialState string) string {
	action := aca.ChooseAction(initialState)
	aca.LastState = initialState
	aca.LastAction = action
	aca.LastValue = aca.GetValue(initialState)
	return action
}

// Step performs one step of actor-critic learning
func (aca *ActorCriticAgent) Step(state string, reward methods.Probability) string {
	currentValue := aca.GetValue(state)
	tdError := reward + aca.DiscountFactor*currentValue - aca.LastValue

	// Update critic (value function)
	newValue := aca.LastValue + aca.CriticLearningRate*tdError
	aca.SetValue(aca.LastState, newValue)

	// Update actor (policy)
	probs := aca.GetActionProbabilities(aca.LastState)

	for i, action := range aca.Actions {
		if action == aca.LastAction {
			// Update chosen action probability
			gradient := tdError * (1 - probs[i])
			probs[i] += aca.ActorLearningRate * gradient
		} else {
			// Update other action probabilities
			gradient := tdError * (-probs[i])
			probs[i] += aca.ActorLearningRate * gradient
		}

		// Ensure non-negative
		if probs[i] < 0 {
			probs[i] = 0
		}
	}

	// Normalize probabilities
	sum := methods.Probability(0)
	for _, prob := range probs {
		sum += prob
	}

	if sum > 0 {
		for i := range probs {
			probs[i] = probs[i] / sum
		}
	}

	aca.ActorNetwork[aca.LastState] = probs

	// Prepare for next step
	nextAction := aca.ChooseAction(state)
	aca.LastState = state
	aca.LastAction = nextAction
	aca.LastValue = currentValue

	return nextAction
}

// EndEpisode performs final updates for episode end
func (aca *ActorCriticAgent) EndEpisode(finalReward methods.Probability) {
	// Final TD error
	tdError := finalReward - aca.LastValue

	// Final critic update
	newValue := aca.LastValue + aca.CriticLearningRate*tdError
	aca.SetValue(aca.LastState, newValue)

	// Final actor update
	probs := aca.GetActionProbabilities(aca.LastState)

	for i, action := range aca.Actions {
		if action == aca.LastAction {
			gradient := tdError * (1 - probs[i])
			probs[i] += aca.ActorLearningRate * gradient
		} else {
			gradient := tdError * (-probs[i])
			probs[i] += aca.ActorLearningRate * gradient
		}

		if probs[i] < 0 {
			probs[i] = 0
		}
	}

	// Normalize
	sum := methods.Probability(0)
	for _, prob := range probs {
		sum += prob
	}

	if sum > 0 {
		for i := range probs {
			probs[i] = probs[i] / sum
		}
	}

	aca.ActorNetwork[aca.LastState] = probs
}

// MultiArmedBandit implements various multi-armed bandit algorithms
type MultiArmedBandit struct {
	Algorithm     string // "epsilon-greedy", "ucb", "thompson"
	Arms          []string
	Counts        map[string]int                    // Number of pulls per arm
	Values        map[string]methods.Probability   // Estimated value per arm
	Alpha         map[string]methods.Probability   // For Thompson sampling
	Beta          map[string]methods.Probability   // For Thompson sampling
	Epsilon       methods.Probability
	TotalPulls    int
}

// NewMultiArmedBandit creates a new multi-armed bandit
func NewMultiArmedBandit(arms []string, algorithm string) *MultiArmedBandit {
	mab := &MultiArmedBandit{
		Algorithm:  algorithm,
		Arms:       arms,
		Counts:     make(map[string]int),
		Values:     make(map[string]methods.Probability),
		Alpha:      make(map[string]methods.Probability),
		Beta:       make(map[string]methods.Probability),
		Epsilon:    0.1,
		TotalPulls: 0,
	}

	// Initialize all arms
	for _, arm := range arms {
		mab.Counts[arm] = 0
		mab.Values[arm] = 0
		mab.Alpha[arm] = 1
		mab.Beta[arm] = 1
	}

	return mab
}

// SelectArm selects an arm to pull using the specified algorithm
func (mab *MultiArmedBandit) SelectArm() string {
	switch mab.Algorithm {
	case "epsilon-greedy":
		return mab.selectEpsilonGreedy()
	case "ucb":
		return mab.selectUCB()
	case "thompson":
		return mab.selectThompson()
	default:
		return mab.selectEpsilonGreedy() // Default
	}
}

// selectEpsilonGreedy implements epsilon-greedy algorithm
func (mab *MultiArmedBandit) selectEpsilonGreedy() string {
	if methods.Probability(math.Random()) < mab.Epsilon {
		// Explore: random arm
		return mab.Arms[int(methods.Probability(len(mab.Arms))*methods.Probability(math.Random()))]
	}

	// Exploit: best arm
	bestArm := ""
	bestValue := methods.Probability(math.Inf(-1))

	for _, arm := range mab.Arms {
		if mab.Values[arm] > bestValue {
			bestValue = mab.Values[arm]
			bestArm = arm
		}
	}

	if bestArm == "" {
		return mab.Arms[0]
	}

	return bestArm
}

// selectUCB implements Upper Confidence Bound algorithm
func (mab *MultiArmedBandit) selectUCB() string {
	if mab.TotalPulls < len(mab.Arms) {
		// Pull each arm at least once
		return mab.Arms[mab.TotalPulls]
	}

	bestArm := ""
	bestUCB := methods.Probability(math.Inf(-1))

	for _, arm := range mab.Arms {
		confidence := methods.Probability(math.Sqrt(2 * math.Log(float64(mab.TotalPulls)) / float64(mab.Counts[arm])))
		ucb := mab.Values[arm] + confidence

		if ucb > bestUCB {
			bestUCB = ucb
			bestArm = arm
		}
	}

	if bestArm == "" {
		return mab.Arms[0]
	}

	return bestArm
}

// selectThompson implements Thompson sampling
func (mab *MultiArmedBandit) selectThompson() string {
	bestArm := ""
	bestSample := methods.Probability(math.Inf(-1))

	for _, arm := range mab.Arms {
		// Sample from Beta distribution
		sample := mab.sampleBeta(mab.Alpha[arm], mab.Beta[arm])

		if sample > bestSample {
			bestSample = sample
			bestArm = arm
		}
	}

	if bestArm == "" {
		return mab.Arms[0]
	}

	return bestArm
}

// sampleBeta samples from a Beta distribution (simplified)
func (mab *MultiArmedBandit) sampleBeta(alpha, beta methods.Probability) methods.Probability {
	// Simplified Beta sampling using uniform random
	x := methods.Probability(math.Random())
	y := methods.Probability(math.Random())

	// Use method of rejection for Beta(α,β)
	// This is a simplified implementation
	return (x * alpha) / (x*alpha + y*beta)
}

// Update updates the bandit with the result of pulling an arm
func (mab *MultiArmedBandit) Update(arm string, reward methods.Probability) {
	if _, exists := mab.Counts[arm]; !exists {
		return // Invalid arm
	}

	mab.Counts[arm]++
	mab.TotalPulls++

	// Update value estimate
	n := methods.Probability(mab.Counts[arm])
	oldValue := mab.Values[arm]
	mab.Values[arm] = oldValue + (reward-oldValue)/n

	// Update Thompson sampling parameters
	if reward > 0 {
		mab.Alpha[arm]++
	} else {
		mab.Beta[arm]++
	}
}

// GetBestArm returns the currently best arm
func (mab *MultiArmedBandit) GetBestArm() string {
	bestArm := ""
	bestValue := methods.Probability(math.Inf(-1))

	for _, arm := range mab.Arms {
		if mab.Values[arm] > bestValue {
			bestValue = mab.Values[arm]
			bestArm = arm
		}
	}

	if bestArm == "" {
		return mab.Arms[0]
	}

	return bestArm
}

// GetStatistics returns statistics about the bandit
func (mab *MultiArmedBandit) GetStatistics() string {
	result := ufmt.Sprintf("Multi-Armed Bandit Statistics (%s)\n", mab.Algorithm)
	result += ufmt.Sprintf("Total pulls: %d\n\n", mab.TotalPulls)

	result += "Arm Statistics:\n"
	for _, arm := range mab.Arms {
		result += ufmt.Sprintf("  %s: pulls=%d, value=%.3f\n",
			arm, mab.Counts[arm], mab.Values[arm])
	}

	bestArm := mab.GetBestArm()
	result += ufmt.Sprintf("\nBest arm: %s (value: %.3f)\n", bestArm, mab.Values[bestArm])

	return result
}

// Helper functions
func max(a, b methods.Probability) methods.Probability {
	if a > b {
		return a
	}
	return b
}

func min(a, b methods.Probability) methods.Probability {
	if a < b {
		return a
	}
	return b
}
