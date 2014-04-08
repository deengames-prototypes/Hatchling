require_relative '../utils/logger'
require_relative '../component/base_component'


# Some sort of dynamic object, like C#'s ExpandoObject, or like OpenStruct.
# It's a class that has dynamic properties. They're specified through a hash.
# It's insensitive to strings vs. symbols, since JSON gives us symbols.
# If you add a "display" component, access it via entity.get(:display)
class Hatchling::Entity 

	def initialize(hash)
		symbols_only = {}
		hash.each do |k, v|
			symbols_only[k.to_sym] = v
			v.entity = self if v.is_a?(BaseComponent)			
		end
				
		@properties = symbols_only
	end
	
	def has?(key)
		key = normalize_key(key)
		return @properties.has_key?(key)
	end
	
	def get(key)
		key = normalize_key(key)
		return @properties[key]
	end
	
	# Not 100% functional. If your entity has a display component, for
	# example, you can write e.display instead of e.get(:display).
	# Some cases fail; needs MOAR testing.
	def method_missing(method, *args, &block)
		key = normalize_key(method)
		# Setter
		if (key.to_s.end_with?('=')) then
			real_key = key.to_s[0, key.length - 1]
			@properties[normalize_key(real_key)] = args[0]
		else
		# Getter
			return self.get(key) if self.has?(key)
			raise "Can't find #{method} property on entity #{self}; key=#{key}"
		end
	end
	
	# Event-based messaging
	
	# Trigger an event for all of its components
	# Called by Event.trigger for all components
	def trigger(event_name, data)
		@properties.each do |name, component|
			component.receive_event(event_name, data)
		end
	end	
	
	private
	
	def normalize_key(key)
		key.to_sym
	end
end
