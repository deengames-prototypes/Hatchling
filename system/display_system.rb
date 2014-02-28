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
		@display.draw_map(@entities)
	end
end