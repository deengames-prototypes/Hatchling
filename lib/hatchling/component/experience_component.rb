require_relative 'base_component'
require_relative '../system/event_system'

class ExperienceComponent < BaseComponent
	attr_reader :experience, :level	
	
	def initialize(exp_for_level_lambda)
		@exp_for_level = exp_for_level_lambda
		@experience = 0
		@level = 1
		super()
	end
	
	def next_level_at
		return @exp_for_level.call(@level + 1)
	end
	
	def gain_experience(points)
		raise "Please specify numerical experience points (not: #{points})" if !['Float', 'Fixnum'].include?(points.class.name)
		raise "Please specify a positive amount of experience points" if points <= 0
		
		@experience += points
		old_level = @level
		
		while (@experience >= next_level_at) do
			@level += 1
		end
		
		EventSystem.trigger(:leveled_up, { :level => @level, :levels_up  => @level - old_level })
	end
end
