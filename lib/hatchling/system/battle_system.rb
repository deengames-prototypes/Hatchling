require_relative '../utils/logger'

# The basic battle system. Don't change it, extend it.
# Uses minimal dependencies (battle component)
class BattleSystem

	def init(entities, args)
		@entities = entities
		@current_map = args[:current_map]
		
		# Copy/pasted from other systems.
		# TODO: DRY please
		@entities.each do |e|
			if e.has?(:name) && e.name.downcase == 'player'
				@player = e
				break
			end			
		end
		
		raise 'Can\'t find player in entities. You need an entity with :name => "Player"' if @player.nil?
	end

	def process(input)
		messages = []
		attacks = []
		
		# Player always goes first
		if input.has_key?(:target) && ['up', 'right', 'down', 'left'].include?(input[:key])			
			attacks << {:attacker => @player, :target => input[:target]} if input[:target].has?(:health)
		end
		
		# Get all entities, who are not the player, who move, and are alive. Process their turns in order of speed (highest first).
		movers = @entities.select { |e| e != @player && e.has?(:battle) && e.has?(:health) && e.get(:health).is_alive? }.sort_by { |e| e.get(:battle).speed }.reverse
		movers.each do |e|
			# We're not guaranteed a good move. Eg. you may be boxed in
			# a corner and unable to get closer to the player.
			move = e.get(:battle).pick_move
			
			if player_at?(move) then					
				attacks << {:attacker => e, :target => @player}				
			elsif is_valid_move?(move) then					
				e.get(:display).move(move)	
			end
		end
		
		return {:messages => messages, :attacks => attacks}
	end
	
	def is_valid_move?(move)
		is_valid = true
		is_valid &= @current_map.is_valid_move?(move) unless @current_map.nil?		
		is_valid &= !player_at?(move)		
		return is_valid
	end
	
	def player_at?(move)
		player_pos = @player.get(:display)
		return (player_pos.x == move[:x] && player_pos.y == move[:y])
	end
end
