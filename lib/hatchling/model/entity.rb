require_relative '../utils/logger'
require_relative '../component/base_component'


# Some sort of dynamic object, like C#'s ExpandoObject, or like OpenStruct.
# It's a class that has dynamic properties. They're specified through a hash.
# It's insensitive to strings vs. symbols, since JSON gives us symbols.
# If you add a "display" component, access it via entity.get(:display)
class Hatchling::Entity 

	def initialize(hash)
		@properties = {}
			
		hash.each do |k, v|
			add(k, v)
		end		
	end
	
	def add(key, value)
		key = normalize_key(key)
		value.entity = self if value.is_a?(BaseComponent)
		@properties[key] = value
	end
	
	def has?(key)
		key = normalize_key(key)
		return @properties.has_key?(key)
	end
	
	def get(key)
		key = normalize_key(key)
		return @properties[key]
	end
	
	# Event-based messaging
	
	# Trigger an event for all of its components
	# Called by Event.trigger for all components
	def trigger(event_name, data)
		@properties.each do |name, component|
			# Don't do this for flat tags, eg. :name
			component.receive_event(event_name, data) if component.respond_to?(:receive_event)
		end
	end	
	
	private
	
	def normalize_key(key)
		return key.is_a?(Symbol) ? key : key.to_sym
	end
end
