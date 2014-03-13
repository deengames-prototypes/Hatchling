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
		end		
		
		g = GraphOperator.new(@width, @height, made, new_walls, last_seen)
		g.connect_unconnected_rooms!()

		# Convert to map data		
		new_walls.each do |x, map|
			map.each do |y, is_wall| 
				@walls << [x, y] if is_wall == true
			end
		end
		
		@start_x = last_seen[:x]
		@start_y = last_seen[:y]
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
					# random_point = {:x => i, :y => j} if rand(30) == 0 && !filled
				end
			end
		end
		
		if !random_point.nil?
			make_circle(random_point[:x], random_point[:y], radius / 2, walls, true)
		end
	end
end

class GraphOperator	
	def initialize(width, height, rooms, new_walls, player_start)
		@width = width
		@height = height
		@rooms = rooms
		@new_walls = new_walls
		@player_start = player_start
	end
	
	def connect_unconnected_rooms!()
		# This is a complex operation to ensure all our rooms are connected.
		# Algorithm:
		# 1) Find the room which the player inhabits (guaranteed to be the center of one circle)
		# 2) Flood fill and store explored spaces.
		# 3) Note the perimeter tiles of every room.
		# 4) Break these into two groups: those connected (to the player point) and those unconnected
		# 5) For every unconnected room:
		# 		Calculate the distance of every perimeter tile to every connected room's perimeter tiles. Store the path.
		#		Find the minimal path.
		#		Make the path (walkable tiles)
		# 6) Done!
		
		# Find the player's room
		start_room = find_start_room()
		
		# Flood-fill the map
		empty_tiles = find_empty_tiles()
		
		# Find perimeters by room
		perimeters = find_perimeters
		
		# Assign: connected or not?		
		perimeters.each do |p|
			room = p[:room]
			if empty_tiles.include?({:x => room[:x], :y => room[:y]}) then
				room[:connected] = true				
			else
				room[:connected] = false				
			end
		end
	end
	
	# Returns a room object (:x, :y, :radius)
	def find_start_room()	
		@rooms.each do |c|
			if @player_start[:x] == c[:x] && @player_start[:y] == c[:y]
				return c
			end
		end		
		raise 'Can\'t find start room for player'
	end
	
	# Returns a bunch of elements like {:x => i, :y => j}
	def find_empty_tiles()
		empty_tiles = []
		visited_tiles = {}				
		queue = [{:x => @player_start[:x], :y => @player_start[:y]}]
				
		(0 .. @width).each do |x|
			visited_tiles[x] = {}
			(0 .. @height).each do |y|
				visited_tiles[x][y] = nil
			end
		end		
		
		processed = 0
		while (queue.length > 0) do
			current = queue.pop			
			x = current[:x]
			y = current[:y]
			visited_tiles[x][y] = true			
			empty_tiles << current if @new_walls[x][y] == false
			
			# Queue conditions:
			# 1) Position is on the map
			# 2) Space is unoccupied
			# 3) Space was never visited
			# 4) Space is not in queue
			spot = {:x => x - 1, :y => y}
			queue << spot if x - 1 > 0 && @new_walls[x - 1][y] == false && visited_tiles[x-1][y].nil? && !queue.include?(spot)
			spot = {:x => x, :y => y - 1}
			queue << spot if y - 1 > 0 && @new_walls[x][y - 1] == false && visited_tiles[x][y-1].nil? && !queue.include?(spot)
			spot = {:x => x + 1, :y => y}
			queue << spot if x + 1 < @width && @new_walls[x + 1][y] == false && visited_tiles[x+1][y].nil? && !queue.include?(spot)
			spot = {:x => x, :y => y + 1}
			queue << spot if y + 1 < @height && @new_walls[x][y + 1] == false && visited_tiles[x][y+1].nil? && !queue.include?(spot)			
		end

		return empty_tiles		
	end
	
	# Returns an array, where each element is {room => r, points => [ ... ]}
	# NOTE: doesn't return exactly the outside wall of each perimeter tile. More
	# like, returns a bunch of points along the perimeter. 
	# But, ya know, it's good enough for what I want.
	def find_perimeters
		to_return = [] # same order as @rooms
		@rooms.each do |r|
			x = r[:x]
			y = r[:y]
			radius = r[:radius]
			this_circle = []
			(x - radius .. x + radius).each do |i|			
				# +y and -y
				# x^2 - y^2 = r^2 => y = sqrt(r^2 - x^2)
				j = Math.sqrt(radius**2 - (i-x)**2).round
				
				point = {:x => i, :y => y + j}
				this_circle << point unless this_circle.include?(point)
				point = {:x => i, :y => y - j}
				this_circle << point unless this_circle.include?(point)
			end
			
			obj = {:room => r, :tiles => this_circle}
			to_return << obj
			Logger.debug("Added #{obj}")
		end
		
		return to_return
	end
end
