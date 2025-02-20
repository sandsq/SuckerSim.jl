module Strategies

export
	AbstractStrategy,
	Strategy

using SuckerSim.States


"""
	AbstractStrategy
Representation of attacking strategy
"""
abstract type AbstractStrategy end

struct Strategy <: AbstractStrategy
	current_state::AbstractTurnState
end

# """
# 	AbstractPunchStrategy
# """
# abstract type AbstractPunchStrategy end

# """
# 	AbstractPuncheeStrategy
# """
# abstract type AbstractPuncheeStrategy end

end