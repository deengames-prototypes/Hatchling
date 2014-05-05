require_relative '../utils/logger'

class EventSystem

	# Used for our API; users can use stuff like: EventSystem.trigger(:player_died, killer)
	@@instance = nil
	
	def initialize
		@@instance = self
	end

	def init(entities, args)
		@entities = entities		
	end

	def trigger(event_name, data)		
		@entities.each do |e|
			e.trigger(event_name, data)
		end
	end
	
	def self.trigger(event_name, data)
		@@instance.trigger(event_name, data) unless @@instance.nil?
	end
end
