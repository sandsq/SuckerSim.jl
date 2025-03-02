using SuckerSim
using SuckerSim.Entities
using Test
using Logging
debuglogger = ConsoleLogger(stderr, Logging.Debug)
Base.global_logger(debuglogger)

source = Entity("Kingambit", 50)
target = Entity("Kyurem", 95)

@testset "Move order" begin
    @test status_move < preemptive_attack
    @test regular_attack < preemptive_attack
end

@testset "Actions" begin
    a = Action(source, target, preemptive_attack)
    @test a == Action(source, target, preemptive_attack)
    @test describe(a) == "[Kingambit, 50.0 speed] used PreemptiveAttack() on [Kyurem, 95.0 speed]"
    
    a2 = Action(target, source, status_move)
    @test a > a2

    a3 = Action(source, target, regular_attack)
    @test a2 > a3
end


@testset "States" begin
    a1 = Action(target, source, regular_attack)
    a2 = Action(source, target, preemptive_attack)
    t = TurnState([a1, a2])

    a3 = Action(source, target, regular_attack)
    t2 = TurnState([a3, a1])

    @testset "TurnState sorting" begin
        @test t.first_action == a2
        @test t.second_action == a1

        @test t2.first_action == a1
        @test t2.second_action == a3
    end

    
    b = BattleState(target, source, [t, t2])

    @testset "BattleState" begin
        @test b.turns[1] == t
        @test b.turns[2] == t2
    end

    @testset "victory conditions" begin
        @testset "both regular attacks" begin
            a1 = Action(source, target, regular_attack)
            a2 = Action(target, source, regular_attack)
            t = TurnState([a1, a2])
            b = BattleState(source, target, [t])
            @test get_victor(b) == (target, 1)
        end

        @testset "both status moves" begin
            a1 = Action(source, target, status_move)
            a2 = Action(target, source, status_move)
            t = TurnState([a1, a2])
            b = BattleState(source, target, [t])
            @test get_victor(b) == (nothing, -1)
        end

        @testset "regular vs status" begin
            a1 = Action(source, target, regular_attack)
            a2 = Action(target, source, status_move)
            t = TurnState([a1, a2])
            b = BattleState(source, target, [t])
            @test get_victor(b) == (source, 1)
        end

        @testset "preemptive vs regular" begin
            a1 = Action(source, target, preemptive_attack)
            a2 = Action(target, source, regular_attack)
            t = TurnState([a2, a1])
            @test is_preemptive_successful(t)
            b = BattleState(source, target, [t])
            @test get_victor(b) == (source, 1)
        end

        @testset "preemptive vs status" begin
            a1 = Action(source, target, preemptive_attack)
            a2 = Action(target, source, status_move)
            t = TurnState([a2, a1])
            @test !is_preemptive_successful(t)
            b = BattleState(source, target, [t])
            @test get_victor(b) == (nothing, -1)
        end

        @testset "preemptive vs status pp stall" begin
            a1 = Action(source, target, preemptive_attack)
            a2 = Action(target, source, status_move)
            t = TurnState([a2, a1])
            b = BattleState(source, target, [t for i in 1:8])
            @test get_victor(b) == (target, 8)
        end
    end
    
end