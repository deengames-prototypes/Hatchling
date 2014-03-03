# Some sort of dynamic object, like C#'s ExpandoObject, or like OpenStruct.
# It's a class that has dynamic properties. They're specified through a hash.
# It has a few mor handy methods, like has?(property) and add_all(hash)
class Entity

	def initialize(hash)
		@properties = hash
	end
	
	def has?(key)
		return @properties.has_key?(key)
	end
	
	def add_all(hash)
		hash.each do |key|
			@properties[key] = hash[key]
		end
	end
	
	def method_missing(name, *args)
		if self.has?(name)
			return @properties[name]
		else
			raise "There's no #{name} property defined on #{self}"
		end
	end
end