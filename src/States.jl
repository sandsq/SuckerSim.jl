module States

export
	AbstractBattleState,
	AbstractTurnState,
	TurnState

"""
	AbstractBattleState
Represents state of battle
"""
abstract type AbstractBattleState end

"""
	AbstractTurnState
Represents state of a single turn
"""
abstract type AbstractTurnState end

struct TurnState <: AbstractTurnState
	description::String
end

end