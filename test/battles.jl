@testset "test battles" begin

	@testset "battles between send strats" begin
		deos_reg = Entity("Deo-S", 180, r_attacker)
		deos_status = Entity("Deo-S", 180, s_attacker)
		king = Entity("Kingambit", 50, p_attacker)
		(victor, b) = execute_battle(deos_reg, SendStrategy(), king, SendStrategy())
		@test victor == king

		(victor, b) = execute_battle(deos_status, SendStrategy(), king, SendStrategy())
		@test victor == deos_status
		@test length(b.turns) == MAX_USES
	end

	deos_reg = Entity("Deo-S", 180, r_attacker)
	deos_status = Entity("Deo-S", 180, s_attacker)
	king = Entity("Kingambit", 50, p_attacker)
	king_reg = Entity("Kingambit", 50, r_attacker)

	@testset "face off" begin
		side1 = [(deos_reg, RandomStrategy()), (deos_reg, SendStrategy()), (deos_status, SendStrategy()), (deos_reg, LessLikeyStrategy()), (deos_reg, MoreLikelyStrategy())]
		side2 = [(king, RandomStrategy()), (king, SendStrategy()),(king_reg, SendStrategy()), (king, LessLikeyStrategy()), (king, MoreLikelyStrategy())]
		num_sims = 100000
		
		for p2 in side2
			println("@@@@@")
			for p1 in side1
				def_wins = 0
				for i in 1:num_sims
					(victor, b) = execute_battle(p1[1], p1[2], p2[1], p2[2])
					if victor == p1[1]
						def_wins += 1
					end
				end
				
				println("$p1 vs $p2 $(def_wins / num_sims) winrate")
			end
		end
	end

	# @testset "regular send vs preemptive less likely" begin
	# 	p1 = (deos_reg, SendStrategy())
	# 	p2 = (king, LessLikeyStrategy())
	# 	(victor, b) = execute_battle(p1[1], p1[2], p2[1], p2[2])
	# 	println("$victor with battle $b")
	# end

	@testset "regular attacker less likely strat vs preemptive attacker less likely strat" begin
		# first sucker not guaranteed to happen immediately
		# ([Deo-S, 180 speed, RegularAttacker() role], RandomStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.1664 winrate
		# ([Deo-S, 180 speed, RegularAttacker() role], SendStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.12498 winrate
		# ([Deo-S, 180 speed, StatusAttacker() role], SendStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.0004 winrate
		# ([Deo-S, 180 speed, RegularAttacker() role], LessLikeyStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.18651 winrate
		# ([Deo-S, 180 speed, RegularAttacker() role], MoreLikelyStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.13839 winrate

		# first sucker will happen immediately
		# ([Deo-S, 180 speed, RegularAttacker() role], RandomStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.08291 winrate
		# ([Deo-S, 180 speed, RegularAttacker() role], SendStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.0 winrate
		# ([Deo-S, 180 speed, StatusAttacker() role], SendStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.00265 winrate
		# ([Deo-S, 180 speed, RegularAttacker() role], LessLikeyStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.18588 winrate
		# ([Deo-S, 180 speed, RegularAttacker() role], MoreLikelyStrategy()) vs ([Kingambit, 50 speed, PreemptiveAttacker() role], LessLikeyStrategy()) 0.01763 winrate
	end

	@testset "send first x suckers and then become less likely to use it; basically allow like/more likely strats to define their own odds at each step" begin

	end

end