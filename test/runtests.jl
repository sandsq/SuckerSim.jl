using SuckerSim
using SuckerSim.Entities
using SuckerSim.Strategies
using SuckerSim.States
import SuckerSim: ValidMoves
using Test

@testset "Actions" begin
    source = Entity("Kingambit")
    target = Entity("Kyurem")
    move = preemptive_attack
    a = Action(source, target, move)
    @assert describe(a) == "Kingambit used preemptive_attack on Kyurem"
end
