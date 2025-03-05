using SuckerSim
using SuckerSim.Entities
using Test
using Logging
debuglogger = ConsoleLogger(stderr, Logging.Debug)
Base.global_logger(debuglogger)

kingambit = Entity("Kingambit", 50)
kyurem = Entity("Kyurem", 95)

@testset "Move order" begin
    @test status_move < preemptive_attack
    @test regular_attack < preemptive_attack
end

@testset "Actions" begin
    a = Action(kingambit, kyurem, preemptive_attack)
    @test a == Action(kingambit, kyurem, preemptive_attack)
    @test describe(a) == "[Kingambit, 50.0 speed] used PreemptiveAttack() on [Kyurem, 95.0 speed]"
    
    a2 = Action(kyurem, kingambit, status_move)
    @test a > a2

    a3 = Action(kingambit, kyurem, regular_attack)
    @test a2 > a3
end


@testset "States" begin
    a1 = Action(kyurem, kingambit, regular_attack)
    a2 = Action(kingambit, kyurem, preemptive_attack)
    t = TurnState([a1, a2])

    a3 = Action(kingambit, kyurem, regular_attack)
    t2 = TurnState([a3, a1])

    @testset "TurnState sorting" begin
        @test t.first_action == a2
        @test t.second_action == a1

        @test t2.first_action == a1
        @test t2.second_action == a3
    end

    
    b = BattleState(kyurem, kingambit, [t, t2])

    @testset "BattleState" begin
        @test b.turns[1] == t
        @test b.turns[2] == t2
    end

    @testset "victory conditions" begin
        @testset "both regular attacks" begin
            a1 = Action(kingambit, kyurem, regular_attack)
            a2 = Action(kyurem, kingambit, regular_attack)
            t = TurnState([a1, a2])
            b = BattleState(kingambit, kyurem, [t])
            @test get_victor(b) == (kyurem, 1)
        end

        @testset "both status moves" begin
            a1 = Action(kingambit, kyurem, status_move)
            a2 = Action(kyurem, kingambit, status_move)
            t = TurnState([a1, a2])
            b = BattleState(kingambit, kyurem, [t])
            @test get_victor(b) == (nothing, -1)
        end

        @testset "regular vs status" begin
            a1 = Action(kingambit, kyurem, regular_attack)
            a2 = Action(kyurem, kingambit, status_move)
            t = TurnState([a1, a2])
            b = BattleState(kingambit, kyurem, [t])
            @test get_victor(b) == (kingambit, 1)
        end

        @testset "preemptive vs regular" begin
            a1 = Action(kingambit, kyurem, preemptive_attack)
            a2 = Action(kyurem, kingambit, regular_attack)
            t = TurnState([a2, a1])
            @test is_preemptive_successful(t)
            b = BattleState(kingambit, kyurem, [t])
            @test get_victor(b) == (kingambit, 1)
        end

        @testset "preemptive vs status" begin
            a1 = Action(kingambit, kyurem, preemptive_attack)
            a2 = Action(kyurem, kingambit, status_move)
            t = TurnState([a2, a1])
            @test !is_preemptive_successful(t)
            b = BattleState(kingambit, kyurem, [t])
            @test get_victor(b) == (nothing, -1)
        end

        @testset "preemptive vs successful status pp stall" begin
            a1 = Action(kingambit, kyurem, preemptive_attack)
            a2 = Action(kyurem, kingambit, status_move)
            t = TurnState([a2, a1])
            b = BattleState(kingambit, kyurem, [t for i in 1:8])
            @test get_victor(b) == (kyurem, 8)
        end

        @testset "failed status pp stall" begin
            a1 = Action(kingambit, kyurem, preemptive_attack)
            a1_5 = Action(kingambit, kyurem, regular_attack)
            a2 = Action(kyurem, kingambit, status_move)
            t = TurnState([a2, a1])
            b = BattleState(kingambit, kyurem, append!([t for i in 1:4], [TurnState(a1_5, a2)], [t for i in 1:4]))
            @test get_victor(b) == (kingambit, 5)
        end

        @testset "partial pp stall into attack on preemptive" begin
            a1 = Action(kingambit, kyurem, preemptive_attack)
            a2 = Action(kyurem, kingambit, status_move)
            a2_5 = Action(kyurem, kingambit, regular_attack)
            t = TurnState([a2, a1])
            b = BattleState(kingambit, kyurem, append!([t for i in 1:5], [TurnState(a2_5, a1)], [t for i in 1:3]))
            @test get_victor(b) == (kingambit, 6)
        end

        @testset "partial pp stall into attack on attack" begin
            a1 = Action(kingambit, kyurem, preemptive_attack)
            a1_5 = Action(kingambit, kyurem, regular_attack)
            a2 = Action(kyurem, kingambit, status_move)
            a2_5 = Action(kyurem, kingambit, regular_attack)
            t = TurnState([a2, a1])
            b = BattleState(kingambit, kyurem, append!([t for i in 1:6], [TurnState(a2_5, a1_5)], [t for i in 1:2]))
            @test get_victor(b) == (kyurem, 7)
        end
    end
    
end