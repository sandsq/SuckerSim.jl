module Entities
export 
	AbstractEntity,
	Entity,
	AbstractAction,
	Action,
	describe

import SuckerSim: ValidMoves
using SuckerSim.Strategies

"""
	AbstractEntity
Representation of the agent
"""
abstract type AbstractEntity end


struct Entity <: AbstractEntity
	name::String
end
function Base.show(io::IO, e::Entity)
	print(io, e.name)
end


abstract type AbstractAction end

struct Action <: AbstractAction 
	source::AbstractEntity
	target::AbstractEntity
	move::ValidMoves
end
function describe(a::Action)
	return "$(a.source) used $(a.move) on $(a.target)"
end


# """
# 	AbstractPuncher
# Representation of the agent using Sucker Punch
# """
# abstract type AbstractPuncher <: AbstractEntity end

# """
# 	AbstractPunchee
# Representation of the agent trying to play around Sucker Punch
# """
# abstract type AbstractPunchee <: AbstractEntity end

end