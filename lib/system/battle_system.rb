require_relative '../utils/logger'

# The basic battle system. Don't change it, extend it.
# Uses minimal dependencies (battle component)
class BattleSystem

	def init(entities)
		@entities = entities
		
		# Copy/pasted from other systems.
		# TODO: DRY please
		@entities.each do |e|
			if e.has?(:name) && e.name.downcase == 'player'
				@player = e
				break
			end			
		end
		
		raise 'Can\'t find player in entities' if @player.nil?
	end

	def process(input)
		if input.has_key?(:target) && ['up', 'right', 'down', 'left'].include?(input)
			# Dear player, please ATTACK! ATTACK! ATTACK! the enemy. kthxbye.
		end
		
		@entities.each do |e|
			next if @player == e
			if e.has?(:battle) then
				move = e.get(:battle).pick_move
				e.get(:display).move(move)  if Game.instance.current_map.is_valid_move?(move)					
			end
		end
	end
	
end