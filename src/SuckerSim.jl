module SuckerSim

@enum ValidMoves begin
	non_attack
	regular_attack
	preemptive_attack
end
# higher number (like prio bracket) attack happens first

# function Base.isless(v1::ValidMoves, v2::ValidMoves)
# 	# non_attack < regular_attack < preemptive_attack
# 	if v1 == v2
# 		return false
# 	end
# 	if v1 == non_attack
# 		return true
# 	end
# 	if v1 == regular_attack
# 		if v2 == non_attack
# 			return false
# 		end
# 		return true
# 	end
# 	return false
# end
export
	preemptive_attack,
	regular_attack,
	non_attack
# function Base.show(io::IO, m::ValidMoves)
# 	print(io, )

# end

include("Entities.jl")
using .Entities




end
