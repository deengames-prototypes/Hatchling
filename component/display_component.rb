class DisplayComponent
	attr_accessor :x, :y, :character, :color # instance of Color
	
	def initialize(x, y, character, color)
		@x = x
		@y = y
		@character = character
		@color = color
	end
end