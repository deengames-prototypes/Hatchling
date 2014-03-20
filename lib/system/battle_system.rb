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
	end
	
end