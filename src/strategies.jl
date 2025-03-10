using Random
const DEFAULT_RNG = Xoshiro(6)
export
	AbstractStrategy,
	pick_action,
	RandomStrategy


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
struct SmartStrategy <: AbstractStrategy end

pick_action(rng::AbstractRNG, s::AbstractStrategy, b::AbstractBattleState, attacker::AbstractEntity) = throw(ErrorException("pick_action not implemented for strategy of type $(typeof(s))."))
pick_action(s::AbstractStrategy, b::AbstractBattleState, attacker::AbstractEntity) = pick_action(DEFAULT_RNG, s, b, attacker)

function pick_action(::AbstractRNG, strat::RandomStrategy, 
	battle_state::AbstractBattleState, attacker::Entity{R}) where R <: AbstractRole
	moves = 
	if R == PreemptiveAttacker
		[preemptive_attack, regular_attack]
	elseif R == RegularAttacker
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



# function pick_action(rng:: AbstractRNG, strat::S, 
# 	battle_state::AbstractBattleState, attacker::AbstractEntity) where {S <: AbstractSendStrategy}
# 	defender = identify_defender(battle_state, attacker)
# 	if typeof(strat) == SendPreemptiveStrategy
# 		Action(attacker, defender, preemptive_attack)
# 	elseif typeof(strat) == SendRegularStrategy
# 		Action(attacker, defender, regular_attack)
# 	elseif typeof(strat) == SendStatusStrategy
# 		Action(attacker, defender, status_move)
# 	else
# 		throw(ErrorException("$(typeof(strat)) is not a valid send strat"))
# 	end
	
# end

# function pick_action(strat::S, 
# 	battle_state::AbstractBattleState, attacker::AbstractEntity) where {S <: AbstractSendStrategy}
# 	pick_action(DEFAULT_RNG, strat, battle_state, attacker)
# end




# abstract type AbstractTacticalPreemptiveStrategy <: AbstractStrategy end
# """
# 	PreemptiveLessStrategy
# The lower the PP of the preemptive attack, the less likely it will be used
# """
# struct PreemptiveLessStrategy <: AbstractTacticalPreemptiveStrategy end
# """
# 	PreemptiveMoreStrategy
# The lower the PP of the preemptive attack, the more likely it will be used
# """
# struct PreemptiveMoreStrategy <: AbstractTacticalPreemptiveStrategy end


# abstract type AbstractTacticalStatusStrategy <: AbstractStrategy end
# """
# 	StatusLessStrategy
# The lower the PP of the opponent's preemptive attack, the less likely a status move will be used
# """
# struct StatusLessStrategy <: AbstractTacticalStatusStrategy end
# """
# 	StatusMoreStrategy
# The lower the PP of the opponent's preemptive attack, the more likely a status move will be used
# """
# struct StatusMoreStrategy <: AbstractTacticalStatusStrategy end


# function pick_action(rng:: AbstractRNG, strat::S, 
# 	battle_state::AbstractBattleState, attacker::AbstractEntity) where {S <: Union{AbstractTacticalPreemptiveStrategy, AbstractTacticalStatusStrategy}}
# 	move_to_use = 
# 	if S <: AbstractTacticalPreemptiveStrategy
# 		preemptive_attack
# 	elseif S <: AbstractTacticalStatusStrategy
# 		status_move
# 	else
# 		throw(ErrorException("$S is not a valid tactical strategy"))
# 	end

	

# 	defender = identify_defender(battle_state, attacker)
# 	# MAX_USES
# 	uses_remaining = MAX_USES - _count_preemptive_uses(battle_state)
# 	if uses_remaining <= 0
# 		throw(ErrorException("$(uses_remaining) shouldn't be possible; the battle should have a victor when there are 0 remaining uses"))
# 	end
	
# 	if typeof(strat) == PreemptiveLessStrategy || typeof(strat) == StatusLessStrategy
# 		random_roll = rand(1:MAX_USES)
# 		if random_roll <= uses_remaining
# 			Action(attacker, defender, move_to_use)
# 		else
# 			Action(attacker, defender, regular_attack)
# 		end
# 	elseif typeof(strat) == PreemptiveMoreStrategy || typeof(strat) == StatusMoreStrategy
# 		# use this janky spread so that when there is 1 use remaining, it is not guaranteed to be used
# 		# means if there are 7 uses remaining, the chance is the same as 8 uses remaining
# 		random_roll = rand(0:8/7:8)
# 		if random_roll >= uses_remaining
			
# 			Action(attacker, defender, move_to_use)
# 		else
# 			Action(attacker, defender, regular_attack)
# 		end
# 	else
# 		throw(ErrorException("$(typeof(strat)) is not a valid tactical strat"))
# 	end
	
# end

# function pick_action(strat::S, 
# 	battle_state::AbstractBattleState, attacker::AbstractEntity) where {S <: Union{AbstractTacticalPreemptiveStrategy, AbstractTacticalStatusStrategy}}
# 	pick_action(DEFAULT_RNG, strat, battle_state, attacker)
# end




