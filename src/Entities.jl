module Entities

using SuckerSim
export 
	AbstractEntity,
	Entity

"""
	AbstractEntity
Representation of the agent
"""
abstract type AbstractEntity end

struct Entity <: AbstractEntity
	name::String
	speed::Float64
end
function Base.show(io::IO, e::Entity)
	print(io, "[$(e.name), $(e.speed) speed]")
end

include("states.jl")
include("strategies.jl")

end