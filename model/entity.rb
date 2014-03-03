class Entity

	attr_reader :components
	
	def initialize(components)
		if components.nil? then
			@components = {}
		else
			@components = components
		end
	end
	
	def add_component(key, value)
		if @components.has_key?(key)
			raise "Trying to add component #{key}/#{component} to #{self} when it's already a component!"
		else
			@components[key] = value
		end
	end
	
	def remove_component(key)
		@components.delete(key)
	end
	
	def get(key)
		return @components[key]
	end
end