require_relative '../io/display'

class DisplaySystem	
	
	def init(entities)
		@old_positions = []
		@entities = entities
		@display = Display.new if @display.nil?
	end	
	
	def destroy
		@display.destroy unless @display.nil?
	end

	def draw
		# Clear out their old occupied spaces
		@old_positions.each do |e|
			# TODO: draw the floor that was here
			@display.draw(e[:x], e[:y], '.', Color.new(128, 128, 128))			
		end
		
		@old_positions = []
		
		@entities.each do |e|			
			if e.has?(:display)
				d = e.get(:display)
				@display.draw(d.x, d.y, d.character, d.color)
				@old_positions << { :x => d.x, :y => d.y }
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
	
	private
	
	def is_on_screen?(x, y)
		return x >= 0 && x < @display.width && y >= 0 && y < @display.height			
	end
end
