module SuckerSim

abstract type AbstractMove end
struct StatusMove <: AbstractMove end
status_move = StatusMove()
struct RegularAttack <: AbstractMove end
regular_attack = RegularAttack()
struct PreemptiveAttack <: AbstractMove end
preemptive_attack = PreemptiveAttack()

# higher prio attack happens first which means high prio attack is "less than" regular
function Base.isless(m1::T, m2::S) where {T <: AbstractMove, S <: AbstractMove}
	if m1 == status_move && m2 == preemptive_attack
		return false
	elseif m1 == regular_attack && m2 == preemptive_attack
		return false
	end
	true
end

export
	AbstractMove,
	StatusMove,
	status_move,
	RegularAttack,
	regular_attack,
	PreemptiveAttack,
	preemptive_attack
# function Base.show(io::IO, m::ValidMoves)
# 	print(io, )

# end

include("Entities.jl")
using .Entities




end
