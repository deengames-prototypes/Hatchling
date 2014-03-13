require_relative '../utils/logger'

class Dungeon
	attr_reader :stairs, :walls, :start_x, :start_y
	attr_reader :perimeter, :width, :height
	
	
	def initialize(floor_num)
		seed = 1024768
		Random.srand(seed)
		
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
				
		made = []
		# number of rooms to make
		target = rand(10) + 30
		
		while (made.length < target)
			radius = rand(2) + 3
			x = rand(@width)
			y = rand(@height)			
			make_circle(x, y, radius, new_walls, false)
			last_seen = {:x => x, :y => y} unless 
				# Perimeter wall
				(@perimeter == true && (x == 0 || y == 0 || x == @width - 1 || y == @height - 1)) ||
				# Filled in here
				new_walls[x][y] == true
			made << {:x => x, :y => y, :radius => radius}
			Logger.info("Made a circle: #{x}, #{y}, r=#{radius}")
		end
		
		# Tunnel from circle to circle
=begin
		made.each do |circle|
			current = circle
			closest = find_closest_circle(current, made)
			
			# Tunnel. X first, then y
			start = [current[:x], closest[:x]].min
			stop =  [current[:x], closest[:x]].max
			
			(start .. stop).each do |x|			
				new_walls[x][current[:y]] = false;
			end
			
			start = [current[:y], closest[:y]].min
			stop =  [current[:y], closest[:y]].max
			(start .. stop).each do |y|
				new_walls[closest[:x]][y] = false;
			end			
		end
=end		

		# Convert to map data		
		new_walls.each do |x, map|
			map.each do |y, is_wall| 
				@walls << [x, y] if is_wall == true
			end
		end
		
		@start_x = last_seen[:x]
		@start_y = last_seen[:y]
	end
	
	def find_closest_circle(current, all)
		closest = all[-1]
		d = distance(current, closest)
		
		all.each do |c|
			n = distance(closest, c)
			if (n < d && (current[:x] != closest[:x] || current[:y] != closest[:y])) then
				d = n
				closest = c
			end
		end
		
		closest
	end
	
	def distance(a, b)
		return ((a[:x] - b[:x])**2 + (a[:y] - b[:y])**2)
	end
	
	def make_circle(x, y, radius, walls, filled)
		random_point = nil
		
		walls[x][y] = false						
		(x - radius .. x + radius).each do |i|
			(y - radius .. y + radius).each do |j|
				if (i - x)**2 + (j - y)**2 <= radius**2 && i >= 0 && j >= 0 && i < @width && j < @height then					
					walls[i][j] = filled
					# Randomly pick a perimeter point and generate a filled circle
					# The source of the magic number 30: If the radius is 3, there
					# are roughly 12 perimeter points; if we want this to happen once
					# every three circles, that's 1/36. 1/30 looks good.
					#random_point = {:x => i, :y => j} if rand(30) == 0 && !filled
				end
			end
		end
		
		if !random_point.nil?
			make_circle(random_point[:x], random_point[:y], radius / 2, walls, true)
		end
	end
end
