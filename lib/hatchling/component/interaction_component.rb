require_relative 'base_component'

# NOTE: depends on a DisplayComponent (needs coordinates)
class InteractionComponent < BaseComponent	
	
	def initialize(action_lambda)
		@action_lambda = action_lambda
	end
	
	def interact(target)
		@action_lambda.call(target)
	end
end
