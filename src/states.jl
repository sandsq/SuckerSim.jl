

export
	AbstractAction,
	Action,
	describe,
	AbstractTurnState,
	TurnState,
	AbstractBattleState,
	BattleState,
	is_preemptive_successful,
	get_victor



abstract type AbstractAction end

struct Action <: AbstractAction 
	source::AbstractEntity
	target::AbstractEntity
	move::AbstractMove
end
function Base.isless(a1::AbstractAction, a2::AbstractAction)
	Base.isless(a1.move, a2.move)
end
function describe(a::AbstractAction)
	"$(a.source) used $(a.move) on $(a.target)"
end


"""
	AbstractTurnState
Represents state of a single turn
"""
abstract type AbstractTurnState end

"""
	TurnState
Each participant can only take one action, so just hold both actions
"""
struct TurnState{T <: AbstractAction} <: AbstractTurnState
	first_action::T
	second_action::T
	function TurnState(a::Vector{T}) where T <: AbstractAction
		if length(a) != 2
			throw(DimensionMismatch("Number of actions in turn $(length(a)) does not match number of allowed actions (2)."))
		end
		# order turn by entity speed and move prio
		sort!(a, by = x -> x.source.speed, rev=true)
		sort!(a, by = x -> x.move)
		new{T}(a[1], a[2])
	end
	function TurnState(a1::AbstractAction, a2::AbstractAction)
		TurnState([a1, a2])
	end
end
function is_preemptive_successful(t::TurnState)
	if t.second_action.move == preemptive_attack
		throw(error("Preemptive attacks shouldn't appear second in the turn, something went wrong $t."))
	end
	if t.first_action.move == preemptive_attack && 
		t.second_action.move == regular_attack
		return true
	end
	false
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
	# check to ensure that turns only involve participants
end
"""
	get_victor
Return the victor and the turn of the victory
"""
function get_victor(b::AbstractBattleState)
	# last_turn = last(b.turns)
	# if is_preemptive_successful(last_turn)
	# 	return last_turn.first_action.source, length(b.turns)
	# end
	for (tind, turn) in enumerate(b.turns)
		if turn.first_action.move == regular_attack
			return turn.first_action.source, tind
		elseif turn.first_action.move == status_move && 
			turn.second_action.move == regular_attack
			return turn.section_action_source, tind
		elseif is_preemptive_successful(turn)
			return turn.first_action.source, tind
		end
	end
	nothing, -1
end


