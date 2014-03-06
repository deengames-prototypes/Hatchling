# Some sort of dynamic object, like C#'s ExpandoObject, or like OpenStruct.
# It's a class that has dynamic properties. They're specified through a hash.
# It has a few mor handy methods, like has?(property) and add_all(hash)

# Use OpenStruct to get setters to work, I haven't figured that part out yet :)
require 'ostruct'
class Entity < OpenStruct

	def initialize(hash)
		super(hash)
		@properties = hash
	end
	
	def has?(key)
		return @properties.has_key?(key)
	end
	
	def add(hash)		
		hash.each do |key, value|			
			@properties[key] = hash[key]			
		end
	end
	
	def method_missing(name, *args)
		if self.has?(name)
			return @properties[name]
		else
			raise "There's no #{name} property defined on #{self.name.nil? ? self : self.name}"
		end
	end
end