require_relative '../io/display'
require_relative '../utils/logger'

### The display system for your game. This code is game specific.
class DisplaySystem	
	
	def init(entities)
		# Draw only things that moved; draw a '.' on their old position,
		# and draw them at their new position.
		@previous_state = {}
		@entities = entities
		@display = Display.new if @display.nil?
	end	
	
	def destroy
		@display.destroy unless @display.nil?
	end

	def draw
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
							@display.draw(previous.x, previous.y, '.', Color.new(128, 128, 128))
						else
							p = p.get(:display)
							@display.draw(p.x, p.y, p.character, p.color)
						end
					end
					
					@display.draw(d.x, d.y, d.character, d.color)
					
					@previous_state[e] = DisplayComponent.new(d.x, d.y, d.character, d.color)					
				end
			end
		end
	end	
	
	def draw_text(x, y, text, color)
		@display.draw(x, y, text, color)
	end
	
	def clear
		self.fill_screen(' ', Color.new(0, 0, 0))
	end
	
	def fill_screen(character, color)
		(0 .. @display.width).each do |x|
			(0 .. @display.height).each do |y|
				@display.draw(x, y, character, color)
			end
		end
	end
	
	# Copied from input_system.rb. TODO: DRY
	def entity_at(x, y)		
		@entities.each do |e|
			return e if e.has?(:display) && e.get(:display).x == x && e.get(:display).y == y && e != @player
		end		
		
		return nil
	end
	
	private
	
	def is_on_screen?(x, y)
		return x >= 0 && x < @display.width && y >= 0 && y < @display.height			
	end
end
