

export
	AbstractStrategy,
	RandomChoiceStrategy

"""
	AbstractStrategy
Representation of attacking strategy
"""
abstract type AbstractStrategy end

struct RandomChoiceStrategy <: AbstractStrategy end

# """
# 	AbstractPunchStrategy
# """
# abstract type AbstractPunchStrategy end

# """
# 	AbstractPuncheeStrategy
# """
# abstract type AbstractPuncheeStrategy end
