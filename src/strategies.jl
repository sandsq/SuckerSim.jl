using Random
const DEFAULT_RNG = Xoshiro(6)
export
	AbstractStrategy,
	pick_action,
	RandomStrategy,
	SendStrategy,
	AbstractSmartStrategy,
	LessLikeyStrategy,
	MoreLikelyStrategy


function identify_defender(battle_state::AbstractBattleState, attacker::AbstractEntity)
	if attacker == battle_state.participant1
		battle_state.participant2 
	elseif attacker == battle_state.participant2
		battle_state.participant1
	else
		throw(ErrorException("attacker $(attacker) is not a participant of battle $(battle_state)"))
	end
end

function _count_preemptive_uses(b::BattleState)
	c = 0
	for turn in b.turns
		if turn.first_action.move == preemptive_attack || turn.second_action.move == preemptive_attack
			c += 1
		end
	end
	c
end

abstract type AbstractStrategy end
struct RandomStrategy <: AbstractStrategy end
struct SendStrategy <: AbstractStrategy end
abstract type AbstractSmartStrategy <: AbstractStrategy end
struct LessLikeyStrategy <: AbstractSmartStrategy end
struct MoreLikelyStrategy <: AbstractSmartStrategy end

pick_action(rng::AbstractRNG, s::AbstractStrategy, b::AbstractBattleState, attacker::AbstractEntity) = throw(ErrorException("pick_action not implemented for strategy of type $(typeof(s))."))

pick_action(s::AbstractStrategy, b::AbstractBattleState, attacker::AbstractEntity) = pick_action(DEFAULT_RNG, s, b, attacker)

function pick_action(::AbstractRNG, strat::RandomStrategy, 
	battle_state::AbstractBattleState, attacker::Entity{R}) where R <: AbstractRole
	moves = 
	if R == PreemptiveAttacker
		[preemptive_attack, regular_attack]
	elseif R == RegularAttacker || S == StatusAttacker
		[regular_attack, status_move]
	else
		throw(ErrorException("$R not a valid role"))
	end
	defender = identify_defender(battle_state, attacker)
	
	roll = rand(1:length(moves))
	selected_move = moves[roll]
	Action(attacker, defender, selected_move)
end

function pick_action(strat::RandomStrategy, 
	battle_state::AbstractBattleState, attacker::Entity{R}) where R <: AbstractRole
	pick_action(DEFAULT_RNG, strat, battle_state, attacker)
end



function pick_action(rng:: AbstractRNG, strat::SendStrategy, 
	battle_state::AbstractBattleState, attacker::Entity{R}) where {R <: AbstractRole}
	defender = identify_defender(battle_state, attacker)
	if R == PreemptiveAttacker
		Action(attacker, defender, preemptive_attack)
	elseif R == RegularAttacker
		Action(attacker, defender, regular_attack)
	elseif R == StatusAttacker
		Action(attacker, defender, status_move)
	else
		throw(ErrorException("$(R) is not a valid role"))
	end
	
end

function pick_action(strat::SendStrategy, 
	battle_state::AbstractBattleState, attacker::Entity{R}) where {R <: AbstractRole}
	pick_action(DEFAULT_RNG, strat, battle_state, attacker)
end


function pick_action(rng:: AbstractRNG, strat::AbstractSmartStrategy, 
	battle_state::AbstractBattleState, attacker::Entity{R}) where R <: AbstractRole
	move_to_use = 
	if R == PreemptiveAttacker
		preemptive_attack
	elseif R == RegularAttacker || R == StatusAttacker
		status_move
	else
		throw(ErrorException("$R is not a valid role"))
	end

	defender = identify_defender(battle_state, attacker)
	# MAX_USES
	uses_remaining = MAX_USES - _count_preemptive_uses(battle_state)
	if uses_remaining <= 0
		throw(ErrorException("$(uses_remaining) shouldn't be possible; the battle should have a victor when there are 0 remaining uses"))
	end
	
	if typeof(strat) == LessLikeyStrategy
		random_roll = rand(1:MAX_USES)
		if random_roll <= uses_remaining
			Action(attacker, defender, move_to_use)
		else
			Action(attacker, defender, regular_attack)
		end
	elseif typeof(strat) == MoreLikelyStrategy
		# use this janky spread so that when there is 1 use remaining, it is not guaranteed to be used
		# means if there are 7 uses remaining, the chance is the same as 8 uses remaining
		random_roll = rand(0:8/7:8)
		if random_roll >= uses_remaining
			Action(attacker, defender, move_to_use)
		else
			Action(attacker, defender, regular_attack)
		end
	else
		throw(ErrorException("$(typeof(strat)) is not a valid smart strategy"))
	end
	
end

function pick_action(strat::AbstractSmartStrategy, 
	battle_state::AbstractBattleState, attacker::Entity{R}) where R <: AbstractRole
	pick_action(DEFAULT_RNG, strat, battle_state, attacker)
end




