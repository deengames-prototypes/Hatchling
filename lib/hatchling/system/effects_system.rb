class EffectsSystem
	def init(entities, args)
		@entities = entities
	end
	
	# Decrement life on all environmental effects (acid, goop, etc.)
	# Once they're at zero, remove them.
	def decay_effects
		@entities.each do |e|
			if e.has?(:lifetime)
				life = e.get(:lifetime) # health component. It's a hack.
				life.get_hurt(1)				
				Game.instance.remove_entity(e) if !life.is_alive?
			end
		end
	end
end
