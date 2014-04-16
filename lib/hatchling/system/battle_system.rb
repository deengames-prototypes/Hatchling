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
		
		if input.has_key?(:target) && ['up', 'right', 'down', 'left'].include?(input[:key])			
			attacks << {:attacker => @player, :target => input[:target]} if input[:target].has?(:health)
		end
		
		@entities.each do |e|
			next if @player == e
			if e.has?(:battle) then
				move = e.get(:battle).pick_move				
				if is_valid_move?(move)					
					e.get(:display).move(move)	
				end
			end
		end
		
		return {:messages => messages, :attacks => attacks}
	end
	
	def is_valid_move?(move)		
		is_valid = true
		is_valid &= @current_map.is_valid_move?(move) unless @current_map.nil?
		
		player_pos = @player.get(:display)
		is_valid &= (player_pos.x != move[:x] || player_pos.y != move[:y])
		
		return is_valid
	end
end
