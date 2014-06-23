require_relative 'base_component'

class BattleComponent < BaseComponent
	attr_reader :strength, :speed
	
	def initialize(props, event_handlers = {})
		validate(props[:strength], :strength)		
		validate(props[:speed], :speed)
				
		@strength = props[:strength]
		@speed = props[:speed]
		
		if props.has_key?(:defense) then
			validate(props[:defense], :defense)
			@defense = props[:defense]
		end
		
		@target = props[:target] if props.has_key?(:target)
		
		@before_move = event_handlers[:before_move] unless event_handlers[:before_move].nil?
		@on_move = event_handlers[:on_move] unless event_handlers[:on_move].nil?
		super()
	end
	
	# Decide my next move
	# Return a hash with :x and :y if I want to move
	def pick_move		
		# Naive AI: always take one turn, and walk towards the target if possible
		myself = self.entity.get(:display)
		
		# Randomly decide if you should go horizontally or vertically first
		# Otherwise, you'll always close distance on the shortest axis
		if rand(2) == 1
			# Try to move horizontally first
			x = get_move_x_dir
			y = x == myself.x ? get_move_y_dir : myself.y
		else
			# try to move vertically first
			y = get_move_y_dir
			x = y == myself.y ? get_move_x_dir : myself.x
		end
				
		return {:x => x, :y => y}
	end
	
	
	# Event handlers
	
	# Triggered when entity actually moves; this exposes their new position
	def on_move(move)		
		@on_move.call(move) unless @on_move.nil?
	end
	
	# Triggered right before an entity moves; this exposes their current position
	def before_move(move)
		@before_move.call(move) unless @before_move.nil?
	end
	
	private
	
	
	def get_move_x_dir
		target_xy = @target.get(:display)
		myself = self.entity.get(:display)
		
		if target_xy.x < myself.x
			return myself.x - 1
		elsif target_xy.x > myself.x
			return myself.x + 1
		else
			return myself.x
		end
	end
	
	def get_move_y_dir
		target_xy = @target.get(:display)
		myself = self.entity.get(:display)
		
		if target_xy.y < myself.y
			return myself.y - 1
		elsif target_xy.y > myself.y
			return myself.y + 1
		else
			return myself.y
		end
	end
	
	def validate(field, name)		
		raise "Invalid value of #{field} for #{name}; please specify an integer value" if field.class.name != 'Fixnum'
		raise "#{name} (#{field}) must be positive" if field <= 0
	end
end
