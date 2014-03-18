require_relative '../utils/color'
require_relative '../utils/logger'

class DosColorStrategy	

	def initialize
		@rgb_to_index = { }
		
		# Yes, it is surprisingly expensive
		@distance_cache = {}
		
		@colors = [
			Color.new(0, 0, 0),
			Color.new(0, 0, 128),
			Color.new(0, 128, 0),
			Color.new(0, 128, 128),
			Color.new(128, 0, 0),
			Color.new(128, 0, 128),
			Color.new(128, 128, 0),
			Color.new(192, 192, 192),
			Color.new(128, 128, 128),
			Color.new(0, 0, 255),
			Color.new(0, 255, 0),
			Color.new(0, 255, 255),
			Color.new(255, 0, 0),
			Color.new(255, 0, 255),
			Color.new(255, 255, 0),
			Color.new(255, 255, 255)
		]
		
		# Map each colour to itself
		@colors.each do |c|
			@rgb_to_index[c] = @rgb_to_index.length # 0 .. 15
		end
	end
	
	def get_index_for(color)
		if (!@rgb_to_index.has_key?(color)) then
			# Map to the nearest DOS color. This naively uses
			# the distance-between-points formula (no sqrt for speed)			
			min_distance = compute_distance(@colors[0], color)
			match = 0
			
			(1..@colors.size - 1).each do |c|
				distance = compute_distance(color, @colors[c])
				# <=: favour bright colours
				if (distance <= min_distance)
					min_distance = distance
					match = c
				end
			end
			
			# Remember mapping
			@rgb_to_index[color] = match
		end
		
		return @rgb_to_index[color]
	end
	
	def compute_distance(src, target)
		cache_key = "#{src.r} #{src.g} #{src.b} #{target.r} #{target.g} #{target.b}"
		
		if !@distance_cache.has_key?(cache_key)
			@distance_cache[cache_key] = (src.r - target.r)**2 + (src.g - target.g)**2 + (src.b - target.b)**2
		end
		
		return @distance_cache[cache_key] 
	end
	
end