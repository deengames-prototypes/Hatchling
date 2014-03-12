class Dungeon
	attr_reader :stairs, :start_x, :start_y
	
	def initialize(floor_num)
		@floor_num = floor_num
	end
end