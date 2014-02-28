require_relative '../io/display'

class DisplaySystem	

	def initialize(entities)
		@entities = entities
		@display = Display.new
	end	
	
	def destroy
		@display.destroy
	end

	def draw
		@entities.each do |e|
			if !e[:display].nil?
				component = e[:display]
				@display.draw(component[:x], component[:y], component[:character], component[:color])
			end
		end
	end
	
	def fill_screen(character, color)
		(0 .. @display.width).each do |x|
			(0 .. @display.height).each do |y|
				@display.draw(x, y, character, color)
			end
		end
	end
end