using Random
const DEFAULT_RNG = Xoshiro(6)
export
	AbstractStrategy,
	pick_action,
	RandomStrategy,
	SendStrategy,
	AbstractSmartStrategy,
	SmartStrategy,
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

struct SendStrategy <: AbstractStrategy end


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


abstract type AbstractSmartStrategy <: AbstractStrategy end
"""
	LessLikelyStrategy
For the preemptive attacker, it is less likely to use a preemptive attack the fewer uses it has remaining
For the regular attacker, it is less likely to use a status move the fewer uses the preemptive attack has remaining (ie trying to pp stall)
"""
struct LessLikeyStrategy <: AbstractSmartStrategy end
struct MoreLikelyStrategy <: AbstractSmartStrategy end


function pick_action(rng:: AbstractRNG, strat::Union{LessLikeyStrategy, MoreLikelyStrategy}, battle_state::AbstractBattleState, attacker::Entity{R}) where R <: AbstractRole
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
		# use this janky spread so that when full PP use is not guaranteed
		# random_roll = rand(1:MAX_USES/(MAX_USES - 1):(MAX_USES + 1))
		random_roll = rand(1:MAX_USES)
		if random_roll <= uses_remaining
			Action(attacker, defender, move_to_use)
		else
			Action(attacker, defender, regular_attack)
		end
	elseif typeof(strat) == MoreLikelyStrategy
		# use this janky spread so that when there is 1 use remaining, it is not guaranteed to be used
		# means if there are 7 uses remaining, the chance is the same as 8 uses remaining
		random_roll = rand(0:MAX_USES/(MAX_USES - 1):MAX_USES)
		if random_roll >= uses_remaining
			Action(attacker, defender, move_to_use)
		else
			Action(attacker, defender, regular_attack)
		end
	else
		throw(ErrorException("$(typeof(strat)) is not a valid smart strategy"))
	end
	
end

function pick_action(strat::Union{LessLikeyStrategy, MoreLikelyStrategy}, 
	battle_state::AbstractBattleState, attacker::Entity{R}) where R <: AbstractRole
	pick_action(DEFAULT_RNG, strat, battle_state, attacker)
end


struct SmartStrategy <: AbstractSmartStrategy
	name::String
	probability_of_nth::Vector{Function}
	function SmartStrategy(name::String, probability_of_nth::Vector{Function})
		if length(probability_of_nth) != MAX_USES
			throw(ErrorException("You need as many functions as there are uses of preemptive attack ($(MAX_USES))"))
		end
		for (n, f) in enumerate(probability_of_nth)
			if hasmethod(f, (BattleState, )) == false
				throw(ErrorException("Your $(n)th probability determination function needs to take a BattleState as an argument"))
			end
		end
		return new(name, probability_of_nth)
	end
end


function pick_action(rng:: AbstractRNG, strat::SmartStrategy, 
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

	num_preemptive_uses = _count_preemptive_uses(battle_state)
	prob_func = strat.probability_of_nth[num_preemptive_uses + 1]

	uses_remaining = MAX_USES - num_preemptive_uses
	if uses_remaining <= 0
		throw(ErrorException("$(uses_remaining) shouldn't be possible; the battle should have a victor when there are 0 remaining uses"))
	end
	
	prob_of_use = prob_func(battle_state)
	if rand() <= prob_of_use
		Action(attacker, defender, move_to_use)
	else
		Action(attacker, defender, regular_attack)
	end
end


function pick_action(strat::SmartStrategy, 
	battle_state::AbstractBattleState, attacker::Entity{R}) where R <: AbstractRole
	pick_action(DEFAULT_RNG, strat, battle_state, attacker)
end
