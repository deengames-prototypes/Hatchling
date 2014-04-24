require_relative '../io/display'
require_relative '../utils/logger'

### The display system for your game. This code is game specific.
class DisplaySystem	
	
	attr_reader :messages
		
	def init(entities, args)
		# Draw only things that moved; draw a '.' on their old position,
		# and draw them at their new position.		
		@previous_state = {} # entity => old position display component
		@entities = entities
		@display ||= Display.new
		@messages = []
		
		# The full-size screen is 80x24, but we only draw 80x22, because
		# we leave 2 spaces for messages; hence, this magic constant.		
		@EXTRA_SPACE = 2
	end	
	
	def destroy
		@display.destroy unless @display.nil?
	end

	def draw
		floor_color = Color.new(128, 128, 128)
		
		# Draw all squares where entities are removed
		@previous_state.each do |e, display|
			if !@entities.include?(e)
				pos = e.get(:display)				
				draw_on_map(pos.x, pos.y, '.', floor_color) 
				@previous_state.delete(e)
			end
		end
		
		# Draw all entities that moved
		@entities.each do |e|			
			if e.has?(:display)
				d = e.get(:display)
				draw = false
				previous = nil
				
				# Didn't draw you before?
				draw = true if !@previous_state.has_key?(e)				
				# Did you move?
				if @previous_state.has_key?(e)
					previous = @previous_state[e]
					draw = true if previous.x != d.x || previous.y != d.y || previous.color != d.color || previous.character != d.character
				end
				
				if draw == true					
					if !previous.nil?					
						p = self.entity_at(previous.x, previous.y)
						if p.nil?							
							draw_on_map(previous.x, previous.y, '.', floor_color)
						else
							p = p.get(:display)
							draw_on_map(p.x, p.y, p.character, p.color)
						end
					end
					
					draw_on_map(d.x, d.y, d.character, d.color)
					
					@previous_state[e] = DisplayComponent.new(d.x, d.y, d.character, d.color)					
				end
			end
		end
		
		draw_messages		
	end	
	
	def draw_text(x, y, text, color)
		@display.draw(x, y, text, color)
	end
	
	def clear
		self.fill_screen(' ', Color.new(0, 0, 0))
	end
	
	def fill_screen(character, color)
		(0 .. @display.width - 1).each do |x|
			(0 .. @display.height - 1).each do |y|
				@display.draw(x, y, character, color)
			end
		end
	end
	
	# Copied from input_system.rb. TODO: DRY
	def entity_at(x, y)		
		@entities.each do |e|
			return e if e.has?(:display) && e.get(:display).x == x && e.get(:display).y == y && (!defined?(@player) || e != @player)
		end		
		
		return nil
	end
	
	def add_messages(messages)		
		messages = messages.compact		
		messages.each do |m|
			@messages << m
		end
	end
	
	private
	
	def is_on_screen?(x, y)
		return x >= 0 && x < @display.width && y >= 0 && y < @display.height			
	end
	
	# Keeping absolute map coordinates, draw under the messages space
	def draw_on_map(x, y, char, color)
		@display.draw(x, y + @EXTRA_SPACE, char, color)
	end
	
	def draw_messages
		black = Color.new(0, 0, 0)
		white = Color.new(255, 255, 255)
		fill_rectangle(0, 0, @display.width, @EXTRA_SPACE, ' ', black)
		
		# Draw as many messages as will fit. Until we're done.
		# Max two messages		
		@text = ""
		max_length = @EXTRA_SPACE * @display.width
		
		while (@text.length < max_length && @messages.length > 0) do
			# use of "pop" means, oldest message first, because of message ordering.
			next_message = @messages.pop
			@text = "#{@text}#{next_message} "
		end
		
		@text = "#{@text[0, max_length - 4]} ..." if @text.length > max_length
		
		@messages = []
		
		draw_text(0, 0, @text, white)
	end
	
	def fill_rectangle(x, y, width, height, char, color)		
		(y .. y + height - 1).each do |j|
			(x .. x + width - 1).each do |i|				
				@display.draw(i, j, char, color)
			end
		end
	end
end
