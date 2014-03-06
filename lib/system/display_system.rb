require_relative '../io/display'

class DisplaySystem	

	def initialize(entities)
		@old_positions = []
		@entities = entities
		@display = Display.new
	end	
	
	def destroy
		@display.destroy
	end

	def draw
		# Clear out their old occupied spaces
		@old_positions.each do |e|
			# TODO: draw the floor that was here
			@display.draw(e[:x], e[:y], '.', Color.new(128, 128, 128))			
		end
		
		@old_positions = []
		
		@entities.each do |e|			
			if e.has?(:character) && e.has?(:color)
				@display.draw(e.x, e.y, e.character, e.color)
				@old_positions << { :x => e.x, :y => e.y }
			end
		end		
	end
	
	def draw_text(x, y, text, color)
		@display.draw(x, y, text, color)
	end
	
	def fill_screen(character, color)
		(0 .. @display.width).each do |x|
			(0 .. @display.height).each do |y|
				@display.draw(x, y, character, color)
			end
		end
	end
end