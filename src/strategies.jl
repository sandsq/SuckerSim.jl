using Random
const DEFAULT_RNG = Xoshiro(6)
export
	AbstractStrategy,
	RandomChoiceStrategy,
	pick_action,
	AbstractSendStrategy,
	SendPreemptiveStrategy,
	SendRegularStrategy,
	SendStatusStrategy,
	AbstractTacticalPreemptiveStrategy,
	PreemptiveLessStrategy,
	PreemptiveMoreStrategy,
	AbstractTacticalStatusStrategy,
	StatusLessStrategy,
	StatusMoreStrategy


function identify_defender(battle_state::AbstractBattleState, attacker::AbstractEntity)
	if attacker == battle_state.participant1
		battle_state.participant2 
	elseif attacker == battle_state.participant2
		battle_state.participant1
	else
		throw(ErrorException("attacker $(attacker) is not a participant of battle $(battle_state)"))
	end
end

"""
	AbstractStrategy
Representation of attacking strategy
"""
abstract type AbstractStrategy end
pick_action(rng::AbstractRNG, s::AbstractStrategy, b::AbstractBattleState, attacker::AbstractEntity, moves::Vector{T}) where T <: AbstractMove = throw(ErrorException("pick_action not implemented for strategy of type $(typeof(s))."))
pick_action(s::AbstractStrategy, b::AbstractBattleState, attacker::AbstractEntity, moves::Vector{T}) where T <: AbstractMove = pick_action(DEFAULT_RNG, s, b, attacker, moves)

struct RandomChoiceStrategy <: AbstractStrategy end

function pick_action(::AbstractRNG, ::RandomChoiceStrategy, 
	battle_state::AbstractBattleState, attacker::AbstractEntity, 
	moves::Vector{T}) where T <: AbstractMove
	defender = identify_defender(battle_state, attacker)
	
	roll = rand(1:length(moves))
	selected_move = moves[roll]
	Action(attacker, defender, selected_move)
end

function pick_action(::RandomChoiceStrategy, 
	battle_state::AbstractBattleState, attacker::AbstractEntity, 
	moves::Vector{T}) where T <: AbstractMove
	pick_action(DEFAULT_RNG, RandomChoiceStrategy(), battle_state, attacker, moves)
end

abstract type AbstractSendStrategy <: AbstractStrategy end
struct SendPreemptiveStrategy <: AbstractSendStrategy end
struct SendRegularStrategy <: AbstractSendStrategy end
struct SendStatusStrategy <: AbstractSendStrategy end

function pick_action(rng:: AbstractRNG, strat::S, 
	battle_state::AbstractBattleState, attacker::AbstractEntity, 
	moves::Vector{T}) where {T <: AbstractMove, S <: AbstractSendStrategy}
	defender = identify_defender(battle_state, attacker)
	if typeof(strat) == SendPreemptiveStrategy
		Action(attacker, defender, preemptive_attack)
	elseif typeof(strat) == SendRegularStrategy
		Action(attacker, defender, regular_attack)
	elseif typeof(strat) == SendStatusStrategy
		Action(attacker, defender, status_move)
	else
		throw(ErrorException("$(typeof(strat)) is not a valid send strat"))
	end
	
end

function pick_action(strat::S, 
	battle_state::AbstractBattleState, attacker::AbstractEntity, 
	moves::Vector{T}) where {T <: AbstractMove, S <: AbstractSendStrategy}
	pick_action(DEFAULT_RNG, strat, battle_state, attacker, moves)
end


function _count_preemptive_uses(b::BattleState)
	c = 0
	for turn in b.turns
		if turn.first_action.move == preemptive_attack || turn.second_action.move == preemptive_attack
			c += 1
		end
	end
	c
end

abstract type AbstractTacticalPreemptiveStrategy <: AbstractStrategy end
"""
	PreemptiveLessStrategy
The lower the PP of the preemptive attack, the less likely it will be used
"""
struct PreemptiveLessStrategy <: AbstractTacticalPreemptiveStrategy end
"""
	PreemptiveMoreStrategy
The lower the PP of the preemptive attack, the more likely it will be used
"""
struct PreemptiveMoreStrategy <: AbstractTacticalPreemptiveStrategy end

function pick_action(rng:: AbstractRNG, strat::S, 
	battle_state::AbstractBattleState, attacker::AbstractEntity, 
	moves::Vector{T}) where {T <: AbstractMove, S <: AbstractTacticalPreemptiveStrategy}
	defender = identify_defender(battle_state, attacker)
	# MAX_USES
	uses_remaining = MAX_USES - _count_preemptive_uses(battle_state)
	random_roll = rand(1:MAX_USES)
	if typeof(strat) == PreemptiveLessStrategy
		if random_roll <= uses_remaining
			Action(attacker, defender, preemptive_attack)
		else
			Action(attacker, defender, regular_attack)
		end
	elseif typeof(strat) == PreemptiveMoreStrategy
		if random_roll >= uses_remaining
			Action(attacker, defender, preemptive_attack)
		else
			Action(attacker, defender, regular_attack)
		end
	else
		throw(ErrorException("$(typeof(strat)) is not a valid preemptive tactical strat"))
	end
	
end

function pick_action(strat::S, 
	battle_state::AbstractBattleState, attacker::AbstractEntity, 
	moves::Vector{T}) where {T <: AbstractMove, S <: AbstractTacticalPreemptiveStrategy}
	pick_action(DEFAULT_RNG, strat, battle_state, attacker, moves)
end



abstract type AbstractTacticalStatusStrategy <: AbstractStrategy end
"""
	StatusLessStrategy
The lower the PP of the opponent's preemptive attack, the less likely a status move will be used
"""
struct StatusLessStrategy <: AbstractTacticalStatusStrategy end
"""
	StatusMoreStrategy
The lower the PP of the opponent's preemptive attack, the more likely a status move will be used
"""
struct StatusMoreStrategy <: AbstractTacticalStatusStrategy end
