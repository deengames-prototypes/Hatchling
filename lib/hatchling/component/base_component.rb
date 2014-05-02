# Base class for all components, with common stuff
class BaseComponent
	
	attr_accessor :entity

	def initialize
		@event_handlers = {}	
	end
	
	def bind(event_name, callback)
		@event_handlers[event_name] = callback
	end
	
	# Event-based messaging
	
	def receive_event(event_name, data)
		# Call event handlers (if there are any)
		@event_handlers[event_name].call(data) unless @event_handlers[event_name].nil?
	end
end
