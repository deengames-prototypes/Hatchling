require_relative '../utils/logger'

# A system for stuff that happens when you step on a particular square,
# like applying acid effect, or triggering some other code/events.
class OnStepEventSystem	
	
	attr_reader :messages
		
	def init(entities, args)
		@entities = entities		
	end	
	
	def destroy
	
	end
	
	def check_for_events		
		# Look at all entities and get the OnStepEvent components
		# For anything stepping on a tile, apply the effect
		events = @entities.find_all { |e| e.has?(:on_step) }
		movables = @entities.find_all { |e| e.has?(:display) }
		movables.each do |m|			
			d = m.get(:display)
			apply = events.find_all { |e| e.get(:display).x == d.x && e.get(:display).y == d.y }
			apply.each do |event|
				on_step = event.get(:on_step)
				# Don't trigger on yourself!
				on_step.interact(m) unless m == on_step.entity
			end
		end
	end
end
