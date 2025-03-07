using Random
DEFAULT_RNG = Xoshiro(6)
export
	AbstractStrategy,
	RandomChoiceStrategy,
	pick_action,
	AbstractSendStrategy,
	SendPreemptiveStrategy,
	SendRegularStrategy,
	SendStatusStrategy


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