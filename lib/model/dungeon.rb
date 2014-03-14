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
		# What are we doing here?
		# 1) Create a spanning tree of all rooms
		# 		For each room, find the closest room
		# 2) For each unconnected room, tunnel to the closest room
		# NB: Start at the starting room (contains the player)
		
		# Find the player's room
		start_room = find_start_room()
		
		# Flood-fill the map
		empty_tiles = find_empty_tiles()
		
		# Assign: connected or not?
		connected_rooms = []
		unconnected_rooms = []		
		
		@rooms.each do |r|
			if empty_tiles.include?({:x => r[:x], :y => r[:y]}) then
				connected_rooms << r
			else
				unconnected_rooms << r
			end
		end
		
		unconnected_rooms.each do |r|
			closest = find_closest_room(r, connected_rooms)
			tunnel(r[:x], r[:y], closest[:x], closest[:y])
			connected_rooms << r
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
		
	# Tunnel along a line, filling in gaps as necessary
	def tunnel(start_x, start_y, stop_x, stop_y)
		Logger.debug("*Tunnel from #{start_x}, #{start_y} to #{stop_x}, #{stop_y}")		
		m = (0.0 + stop_y - start_y) / (stop_x - start_x)		
		last_spot = nil
		
		if m.abs < 1
			# Tunnel horizontally
			Logger.debug("HOrizontal")
			if stop_x < start_x						
				start_x, stop_x = stop_x, start_x
				start_y, stop_y = stop_y, start_y
				Logger.debug("\tReversing")
			end
			
			(start_x .. stop_x).each do |x|
				# y - y1 = m(x - x1)
				# y = m(x-x1) + y1
				y = m * (x - start_x) + start_y
				@new_walls[x][y.round] = false
				Logger.debug("\tTunnel at #{x}, #{y.round}")
				
				if !last_spot.nil?
					d = (x - last_spot[:x]).abs + (y.round - last_spot[:y]).abs
					Logger.debug("\t\td=#{d}") unless d <= 1
					if d >= 1.5
						min = [last_spot[:y], y.round].min
						max = [last_spot[:y], y.round].max
						Logger.debug("\t\tCorrecting: from #{min} to #{max}")
						(min .. max).each do |j|
							i = ((j - last_spot[:y]) / m) + x
							@new_walls[i.round][j] = false
							Logger.debug("\t\t\tCOrrection at #{i.round}, #{j}")							
						end
					end
				end
				
				
				last_spot = {:x => x, :y => y.round}
			end
		elsif m > 1
			Logger.debug("Vertical")
			# Tunnel vertically
			if stop_y < start_y	
				start_x, stop_x = stop_x, start_x
				start_y, stop_y = stop_y, start_y
				Logger.debug("Reversing")
			end
			
			(start_y .. stop_y).each do |y|
				# y - y1 = m(x - x1)
				# (y - y1)/m = x-x1
				# (y-y1)/m  +x1 = x
				x = ((y - start_y) / (0.0 + m)) + start_x
				@new_walls[x.round][y] = false
				
				if !last_spot.nil?
					d = (x - last_spot[:x]).abs + (y.round - last_spot[:y]).abs
					Logger.debug("D=#{d}") unless d <= 1
					if d >= 1.5
						min = [last_spot[:x], x.round].min
						max = [last_spot[:x], x.round].max
						(min .. max).each do |i|
							j = m * (i - last_spot[:x]) + y
							@new_walls[i][j.round] = false
						end
					end
				end
				
				Logger.debug("Tunnelz at #{x.round}, #{y}")				
				last_spot = {:x => x.round, :y => y}
			end
		else # m == 1
			Logger.debug("DIAGONALZ")
			if stop_x < start_x						
				start_x, stop_x = stop_x, start_x
				start_y, stop_y = stop_y, start_y
				Logger.debug("Reversing")
			end

			y_increment = (m > 0 ? 1 : -1)
			y = start_y
			
			(start_x .. stop_x).each do |x|				
				# We're at x, y and want to get to x+1, y+1
				# So delve out x+1, y too
				#@new_walls[x][y - y_increment] = false
				@new_walls[x][y] = false
				@new_walls[x][y + y_increment] = false
				Logger.debug("\tTunnel #{x},#{y}")
				Logger.debug("\tTunnel #{x},#{y + y_increment}")
				#@new_walls[x + 1][start_y] = false
				#@new_walls[x][start_y + y_increment] = false
				y += y_increment				
			end
		end
	end
	
	def find_closest_room(room, rooms)
		min_distance = 999999
		min_room = nil
		
		rooms.each do |r|
			next if r == room || (room[:x] == r[:x] && room[:y] == r[:y])
			d = distance(r[:x], r[:y], room[:x], room[:y])
			if d < min_distance
				min_distance = d
				min_room = r
			end
		end
		
		return min_room
	end
	
	def distance(x1, y1, x2, y2)
		return ((x2 - x1)**2 + (y2 - y1)**2)
	end
end
