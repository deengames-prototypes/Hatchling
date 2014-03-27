require_relative 'base_component'

class Hatchling::BattleComponent < BaseComponent
	attr_reader :strength, :speed
	
	def initialize(strength, speed)		
		validate(strength, :strength)
		validate(speed, :speed)
		@strength = strength
		@speed = speed
	end
	
	# Decide my next move
	# Return a hash with :x and :y if I want to move
	def pick_move		
		# Naive AI: walk towards the player if possible
		player_pos = Game.instance.player.get(:display)	
		myself = self.entity.get(:display)
		
		if rand(2) == 1
			# Try to move horizontally first
			x = get_move_x_dir
			y = x == 0 ? get_move_y_dir : myself.y
		else
			# try to move vertically first
			y = get_move_y_dir
			x = y == 0 ? get_move_x_dir : myself.x
		end
		
		return {:x => x, :y => y}
	end
	
	private
	
	
	def get_move_x_dir
		player_pos = Game.instance.player.get(:display)
		myself = self.entity.get(:display)
		
		if player_pos.x < myself.x
			return myself.x - 1
		elsif player_pos.x > myself.x
			return myself.x + 1
		else
			return 0
		end
	end
	
	def get_move_y_dir
		player_pos = Game.instance.player.get(:display)
		myself = self.entity.get(:display)
		
		if player_pos.y < myself.y
			return myself.y - 1
		elsif player_pos.y > myself.y
			return myself.y + 1
		else
			return 0
		end
	end
	
	def validate(field, name)		
		raise "Invalid value of #{field} for #{name}; please specify an integer value" if field.class.name != 'Fixnum'
		raise "#{name} (#{field}) must be positive" if field <= 0
	end
end
