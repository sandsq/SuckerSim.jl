using SuckerSim
using SuckerSim.Entities
using Test
using Logging
using Random
debuglogger = ConsoleLogger(stderr, Logging.Debug)
# Base.global_logger(debuglogger)

# kingambit = Entity("Kingambit", 50, p_attacker)
# kyurem = Entity("Kyurem", 95, r_attacker)

# @testset "Move order" begin
#     @test status_move < preemptive_attack
#     @test regular_attack < preemptive_attack
# end

# @testset "Actions" begin
#     a = Action(kingambit, kyurem, preemptive_attack)
#     @test a == Action(kingambit, kyurem, preemptive_attack)
#     @test describe(a) == "[Kingambit, 50 speed, PreemptiveAttacker() role] used PreemptiveAttack() on [Kyurem, 95 speed, RegularAttacker() role]"
    
#     a2 = Action(kyurem, kingambit, status_move)
#     @test a > a2

#     a3 = Action(kingambit, kyurem, regular_attack)
#     @test a2 > a3
# end


# @testset "States" begin
#     a1 = Action(kyurem, kingambit, regular_attack)
#     a2 = Action(kingambit, kyurem, preemptive_attack)
#     t = TurnState([a1, a2])

#     a3 = Action(kingambit, kyurem, regular_attack)
#     t2 = TurnState([a3, a1])

#     @testset "TurnState sorting" begin
#         @test t.first_action == a2
#         @test t.second_action == a1

#         @test t2.first_action == a1
#         @test t2.second_action == a3
#     end

    
#     b = BattleState(kyurem, kingambit, [t, t2])

#     @testset "BattleState" begin
#         @test b.turns[1] == t
#         @test b.turns[2] == t2
#     end

#     @testset "victory conditions" begin
#         @testset "both regular attacks" begin
#             a1 = Action(kingambit, kyurem, regular_attack)
#             a2 = Action(kyurem, kingambit, regular_attack)
#             t = TurnState([a1, a2])
#             b = BattleState(kingambit, kyurem, [t])
#             @test get_victor(b) == (kyurem, 1)
#         end

#         @testset "both status moves" begin
#             a1 = Action(kingambit, kyurem, status_move)
#             a2 = Action(kyurem, kingambit, status_move)
#             t = TurnState([a1, a2])
#             b = BattleState(kingambit, kyurem, [t])
#             @test get_victor(b) == (nothing, -1)
#         end

#         @testset "regular vs status" begin
#             a1 = Action(kingambit, kyurem, regular_attack)
#             a2 = Action(kyurem, kingambit, status_move)
#             t = TurnState([a1, a2])
#             b = BattleState(kingambit, kyurem, [t])
#             @test get_victor(b) == (kingambit, 1)
#         end

#         @testset "preemptive vs regular" begin
#             a1 = Action(kingambit, kyurem, preemptive_attack)
#             a2 = Action(kyurem, kingambit, regular_attack)
#             t = TurnState([a2, a1])
#             @test is_preemptive_successful(t)
#             b = BattleState(kingambit, kyurem, [t])
#             @test get_victor(b) == (kingambit, 1)
#         end

#         @testset "preemptive vs status" begin
#             a1 = Action(kingambit, kyurem, preemptive_attack)
#             a2 = Action(kyurem, kingambit, status_move)
#             t = TurnState([a2, a1])
#             @test !is_preemptive_successful(t)
#             b = BattleState(kingambit, kyurem, [t])
#             @test get_victor(b) == (nothing, -1)
#         end

#         @testset "preemptive vs successful status pp stall, preemptive attack counter function" begin
#             a1 = Action(kingambit, kyurem, preemptive_attack)
#             a2 = Action(kyurem, kingambit, status_move)
#             t = TurnState([a2, a1])
#             b = BattleState(kingambit, kyurem, [t for i in 1:8])
#             @test get_victor(b) == (kyurem, 8)
#             @test SuckerSim.Entities._count_preemptive_uses(b) == 8
#         end

#         @testset "failed status pp stall" begin
#             a1 = Action(kingambit, kyurem, preemptive_attack)
#             a1_5 = Action(kingambit, kyurem, regular_attack)
#             a2 = Action(kyurem, kingambit, status_move)
#             t = TurnState([a2, a1])
#             b = BattleState(kingambit, kyurem, append!([t for i in 1:4], [TurnState(a1_5, a2)], [t for i in 1:4]))
#             @test get_victor(b) == (kingambit, 5)
#         end

#         @testset "partial pp stall into attack on preemptive" begin
#             a1 = Action(kingambit, kyurem, preemptive_attack)
#             a2 = Action(kyurem, kingambit, status_move)
#             a2_5 = Action(kyurem, kingambit, regular_attack)
#             t = TurnState([a2, a1])
#             b = BattleState(kingambit, kyurem, append!([t for i in 1:5], [TurnState(a2_5, a1)], [t for i in 1:3]))
#             @test get_victor(b) == (kingambit, 6)
#         end

#         @testset "partial pp stall into attack on attack" begin
#             a1 = Action(kingambit, kyurem, preemptive_attack)
#             a1_5 = Action(kingambit, kyurem, regular_attack)
#             a2 = Action(kyurem, kingambit, status_move)
#             a2_5 = Action(kyurem, kingambit, regular_attack)
#             t = TurnState([a2, a1])
#             b = BattleState(kingambit, kyurem, append!([t for i in 1:6], [TurnState(a2_5, a1_5)], [t for i in 1:2]))
#             @test get_victor(b) == (kyurem, 7)
#         end
#     end
# end

# @testset "strategies" begin
#     @testset "random strategy" begin
#         strat = RandomStrategy()
#         b = BattleState(kingambit, kyurem, [])
#         pre_count = 0
#         reg_count = 0
#         total_trials = 1000
#         for i in 1:total_trials
#             a = pick_action(strat, b, kingambit)
#             if a == Action(kingambit, kyurem, preemptive_attack)
#                 pre_count += 1
#             else
#                 reg_count += 1
#             end
#         end
#         # since result depends on rng, just use a big enough sample size and check if it is an expected range
#         @test 0.9 * total_trials / 2 <= pre_count <= 1.1 * total_trials / 2
#         @test 0.9 * total_trials / 2 <= reg_count <= 1.1 * total_trials / 2
#         @test pre_count + reg_count == total_trials
#     end

#     @testset "full send strats" begin
#         strat = SendStrategy()
#         b = BattleState(kingambit, kyurem, [])
#         @test pick_action(strat, b, kingambit) == Action(kingambit, kyurem, preemptive_attack)

#         @test pick_action(strat, b, kyurem) == Action(kyurem, kingambit, regular_attack)

#         status_kyurem = Entity("Kyurem", 95, s_attacker)
#         status_b = BattleState(kingambit, status_kyurem, [])
#         @test pick_action(strat, status_b, status_kyurem) == Action(status_kyurem, kingambit, status_move)
#     end

#     @testset "preemptive attack depending on PP remaining" begin
#         lstrat = LessLikeyStrategy()
#         a1 = Action(kingambit, kyurem, preemptive_attack)
#         a2 = Action(kyurem, kingambit, status_move)
#         t = TurnState([a1, a2])
#         b = BattleState(kingambit, kyurem, [t for i in 1:7])
#         total_trials = 10000
#         c = 0
#         c2 = 0
#         for i in 1:total_trials
#             option_picked = pick_action(lstrat, b, kingambit)
#             if option_picked == Action(kingambit, kyurem, preemptive_attack)
#                 c += 1
#             end

#             option_picked2 = pick_action(lstrat, b, kyurem)
#             if option_picked2 == Action(kyurem, kingambit, status_move)
#                 c2 += 1
#             end
#         end
#         @test 0.9 / 8 * total_trials <= c <= 1.1 / 8 * total_trials
#         @test 0.9 / 8 * total_trials <= c2 <= 1.1 / 8 * total_trials
	    
#         mstrat = MoreLikelyStrategy()
#         c = 0
#         c2 = 0
#         for i in 1:total_trials
#             option_picked = pick_action(mstrat, BattleState(b.participant1, b.participant2, b.turns[1:6]), kingambit)
#             if option_picked == Action(kingambit, kyurem, preemptive_attack)
#                 c += 1
#             end

#             option_picked2 = pick_action(mstrat, BattleState(b.participant1, b.participant2, b.turns[1:6]), kyurem)
#             if option_picked2 == Action(kyurem, kingambit, status_move)
#                 c2 += 1
#             end
#         end
#         @test 5.9 / 8 * total_trials <= c <= 6.1 / 8 * total_trials
#         @test 5.9 / 8 * total_trials <= c2 <= 6.1 / 8 * total_trials
#     end

# end

include("battles.jl")