require_relative '../io/color'

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
		if (!@rgb_to_index.has_key?(color))
			index = @rgb_to_index.size
			@display.initialize_color(index, color)
			@rgb_to_index[color] = index
		end
		
		return @rgb_to_index[color]
	end

end