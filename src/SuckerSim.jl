module SuckerSim



abstract type AbstractMove end
struct StatusMove <: AbstractMove end
status_move = StatusMove()
struct RegularAttack <: AbstractMove end
regular_attack = RegularAttack()
struct PreemptiveAttack <: AbstractMove end
preemptive_attack = PreemptiveAttack()

const MAX_USES = 8

# Attack with higher priority bracket happens first, but higher number appears later in sort. Implement isless "correctly" and reverse the sort direction
function Base.isless(m1::T, m2::S) where {T <: AbstractMove, S <: AbstractMove}
	if m2 == preemptive_attack && m1 == status_move
		return true
	elseif m2 == preemptive_attack && m1 == regular_attack
		return true
	end
	false
end

export
	AbstractMove,
	StatusMove,
	status_move,
	RegularAttack,
	regular_attack,
	PreemptiveAttack,
	preemptive_attack,
	MAX_USES
# function Base.show(io::IO, m::ValidMoves)
# 	print(io, )

# end

include("Entities.jl")
using .Entities




end
