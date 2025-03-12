@testset "test battles" begin

	@testset "battles between send strats" begin
		deos_reg = Entity("Deo-S", 180, r_attacker)
		deos_status = Entity("Deo-S", 180, s_attacker)
		king = Entity("Kingambit", 50, p_attacker)
		(victor, b) = execute_battle(deos_reg, SendStrategy(), kingambit, SendStrategy())
		@test victor == king

		(victor, b) = execute_battle(deos_status, SendStrategy(), kingambit, SendStrategy())
		@test victor == deos_status
		@test length(b.turns) == MAX_USES
	end

	deos_reg = Entity("Deo-S", 180, r_attacker)
	deos_status = Entity("Deo-S", 180, s_attacker)
	king = Entity("Kingambit", 50, p_attacker)

	@testset "face off" begin
		side1 = [(deos_reg, RandomStrategy()), (deos_reg, SendStrategy()), (deos_status, SendStrategy()), (deos_reg, LessLikeyStrategy()), (deos_reg, MoreLikelyStrategy())]
		side2 = [(king, RandomStrategy()), (king, SendStrategy()), (king, LessLikeyStrategy()), (king, MoreLikelyStrategy())]
		num_sims = 100000
		for p1 in side1
			for p2 in side2
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

end