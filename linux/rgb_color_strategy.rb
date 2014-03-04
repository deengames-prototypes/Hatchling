require_relative '../utils/color'
require_relative '../utils/logger'

class RgbColorStrategy

	def initialize(display)
		@display = display		
		
		# color => index int
		@rgb_to_index = {
			# Black = 0
			Color.new(0, 0, 0) => 0
		}
	end

	def get_index_for(color)		
		# Just cache and use the colour. We get up to 255.
		# TODO: make sure we don't go over 255
		key = color.to_s
		if (!@rgb_to_index.has_key?(key))
			index = @rgb_to_index.size
			@display.initialize_color(index, color)
			@rgb_to_index[key] = index			
			raise "WTF index=#{index}" if (index > 100)
		end		
		return @rgb_to_index[key]
	end

end
