

function execute_battle(participant1::Entity, strategy1::AbstractStrategy, participant2::Entity, strategy2::AbstractStrategy)
	battle_state = BattleState(participant1, participant2, [])
	fallback_count = 0
	while get_victor(battle_state)[1] === nothing
		a1 = pick_action(strategy1, battle_state, participant1)
		a2 = pick_action(strategy2, battle_state, participant2)
		t = TurnState([a1, a2])
		battle_state = BattleState(participant1, participant2, push!(battle_state.turns, t))

		if fallback_count >= 100
			throw(ErrorException("battle has gone over 100 turns, this is unlikely so something probably went wrong"))
		end
		fallback_count += 1
	end
end
