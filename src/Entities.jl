module Entities

using SuckerSim
export 
	PreemptiveAttacker,
	p_attacker,
	RegularAttacker,
	r_attacker,
	StatusAttacker,
	s_attacker,d
	AbstractEntity,
	Entity


abstract type AbstractRole end
struct PreemptiveAttacker <: AbstractRole end
p_attacker = PreemptiveAttacker()
struct RegularAttacker <: AbstractRole end
r_attacker = RegularAttacker()
struct StatusAttacker <: AbstractRole end
s_attacker = StatusAttacker()

"""
	AbstractEntity
Representation of the agent
"""
abstract type AbstractEntity end

struct Entity{R <: AbstractRole} <: AbstractEntity
	name::String
	speed::Number
	role::R
	# if extending, have Entity hold valid moves as well
end
function Base.show(io::IO, e::Entity)
	print(io, "[$(e.name), $(e.speed) speed, $(e.role) role]")
end

include("states.jl")
include("strategies.jl")
include("battles.jl")

end