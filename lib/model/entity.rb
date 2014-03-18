# Some sort of dynamic object, like C#'s ExpandoObject, or like OpenStruct.
# It's a class that has dynamic properties. They're specified through a hash.
# It's insensitive to strings vs. symbols, since JSON gives us symbols.
class Entity 

	def initialize(hash)
		symbols_only = {}
		hash.each do |k, v|
			symbols_only[k.to_sym] = v
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
	
	def peekz
		@properties
	end
	
	private
	
	def normalize_key(key)
		if key.class.name == 'String'
			return key.to_sym 
		else
			return key
		end
	end
end