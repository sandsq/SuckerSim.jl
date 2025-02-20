module SuckerSim

@enum ValidMoves begin
	preemptive_attack
	regular_attack
	non_attack
end
export
	preemptive_attack,
	regular_attack,
	non_attack
# function Base.show(io::IO, m::ValidMoves)
# 	print(io, )

# end

include("States.jl")
using .States

include("Strategies.jl")
using .Strategies

include("Entities.jl")
using .Entities




end
