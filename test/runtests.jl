using SuckerSim
using SuckerSim.Entities
import SuckerSim: ValidMoves
using Test

source = Entity("Kingambit")
target = Entity("Kyurem")

@testset "Move order" begin
    @test non_attack < regular_attack 
    @test non_attack < preemptive_attack 
    @test regular_attack < preemptive_attack
end

@testset "Actions" begin
    move = preemptive_attack
    a = Action(source, target, move)
    @test a == Action(source, target, preemptive_attack)
    @test describe(a) == "Kingambit used preemptive_attack on Kyurem"
    
    a2 = Action(target, source, non_attack)
    @test a2 < a
end


@testset "States" begin
    a1 = Action(target, source, regular_attack)
    a2 = Action(source, target, preemptive_attack)
    t = TurnState([a1, a2])
    @test t.actions[1] == a2
    @test t.actions[2] == a1

    a3 = Action(source, target, regular_attack)
    t2 = TurnState([a1, a3])
    b = BattleState([t2, t])
    @test b.turns[1] == t2
    @test b.turns[2] == t
end