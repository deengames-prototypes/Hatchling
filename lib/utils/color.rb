class Color
	attr_reader :r, :g, :b
	
	def initialize(r, g, b)
		@r = r
		@g = g
		@b = b
	end
	
	def to_s
		"Color (#{@r}, #{@g}, #{@b})"
	end
end
