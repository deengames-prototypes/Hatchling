require_relative '../utils/logger'

class Dungeon
	attr_reader :stairs, :walls, :start_x, :start_y
	attr_reader :perimeter, :width, :height
	
	
	def initialize(floor_num)
		@floor_num = floor_num		
		@width = 80
		@height = 25
		@perimeter = true
		
		@start_x = 5
		@start_y = 5
		
		generate_topology
	end
	
	private 
	
	def generate_topology
		# Fill 'er up!
		@walls = []
		new_walls = {}
		(0..width).each do |x|
			new_walls[x] = {}
			(0..height).each do |y|
				new_walls[x][y] = true
			end
		end
		
		# Create 5-10 circular rooms
		made = 0
		target = rand(10) + 30
		
		while (made < target)
			radius = rand(2) + 3
			x = rand(@width)
			y = rand(@height)
			made += 1
			carve_out_circle(x, y, radius, new_walls)
			last_seen = {:x => x, :y => y}
		end
		
		new_walls.each do |x, map|
			map.each do |y, is_wall| 
				@walls << [x, y] if is_wall == true
			end
		end
		
		@start_x = last_seen[:x]
		@start_y = last_seen[:y]
	end
	
	def carve_out_circle(x, y, radius, walls)
		walls[x][y] = false		
		half_radius = (radius).ceil
		Logger.info("#{x - half_radius}, #{y - half_radius} to #{x + half_radius}, #{y + half_radius}")
		(x - half_radius .. x + half_radius).each do |i|
			(y - half_radius .. y + half_radius).each do |j|
				if (i - x)**2 + (j - y)**2 <= radius**2 && i >= 0 && j >= 0 && i < @width && j < @height then					
					walls[i][j] = false
				end
			end
		end
	end
end
