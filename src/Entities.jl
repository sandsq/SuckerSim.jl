module Entities
export 
	AbstractEntity,
	Entity

import SuckerSim: ValidMoves


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






include("states.jl")
include("strategies.jl")


end