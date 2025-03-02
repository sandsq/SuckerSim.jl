using SuckerSim
using SuckerSim.Entities
using Test

source = Entity("Kingambit", 50)
target = Entity("Kyurem", 95)

@testset "Move order" begin
    @test status_move > preemptive_attack
    @test regular_attack > preemptive_attack
end

@testset "Actions" begin
    a = Action(source, target, preemptive_attack)
    @test a == Action(source, target, preemptive_attack)
    @test describe(a) == "[Kingambit, 50.0 speed] used PreemptiveAttack() on [Kyurem, 95.0 speed]"
    
    a2 = Action(target, source, status_move)
    @test a < a2

    a3 = Action(source, target, regular_attack)
    @test a2 < a3
end


@testset "States" begin
    a1 = Action(target, source, regular_attack)
    a2 = Action(source, target, preemptive_attack)
    t = TurnState([a1, a2])
    @test t.first_action == a2
    @test t.second_action == a1

    a3 = Action(source, target, regular_attack)
    t2 = TurnState([a1, a3])
    b = BattleState(target, source, [t2, t])
    @test b.turns[1] == t2
    @test b.turns[2] == t
    @test (source, 1) == get_victor(b)
end