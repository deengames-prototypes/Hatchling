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
	
	def trigger(event_name, data)
		@entity.trigger(event_name, data, self)
	end
	
	def receive_event(event_name, data)
		@event_handlers[event_name].call(data)
	end
end
