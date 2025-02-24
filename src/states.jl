export
	AbstractAction,
	Action,
	describe,
	AbstractTurnState,
	TurnState,
	AbstractBattleState,
	BattleState,
	check_victory


abstract type AbstractAction end

struct Action <: AbstractAction 
	source::AbstractEntity
	target::AbstractEntity
	move::ValidMoves
end
function Base.isless(a1::Action, a2::Action)
	return Base.isless(a1.move, a2.move)
end
function describe(a::Action)
	return "$(a.source) used $(a.move) on $(a.target)"
end


"""
	AbstractTurnState
Represents state of a single turn
"""
abstract type AbstractTurnState end

struct TurnState{T <: AbstractAction} <: AbstractTurnState
	actions::Vector{T}
	function TurnState(a::Vector{T}) where T <: AbstractAction
		
		# order turn by move prio
		sort!(a, by = x -> x.move, rev=true)
		new{T}(a)
	end
end


"""
	AbstractBattleState
Represents state of battle
"""
abstract type AbstractBattleState end

struct BattleState <: AbstractBattleState
	participant1::AbstractEntity
	participant2::AbstractEntity # team 1 and team 2 if extending
	turns::Vector{AbstractTurnState}
end
function check_victory(b::AbstractBattleState) 
	for turn in b.turns
		println(turn)
	end
end


