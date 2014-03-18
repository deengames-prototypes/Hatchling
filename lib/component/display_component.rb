class DisplayComponent
	attr_accessor :x, :y
	attr_reader :character, :color
	
	def initialize(x, y, char, color)
		@x = x
		@y = y
		@character = char
		@color = color
	end
end