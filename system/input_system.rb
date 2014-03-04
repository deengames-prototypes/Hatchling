class InputSystem	

	def initialize(entities)
		@entities = entities		
	end	
	
	def destroy
		
	end

	def get_and_process_input		
		input = Keys.read_character
		
		@entities.each do |e|
			if e.has?(:process_input)				
				e.process_input.process(input)
			end
		end
		
		return input
	end
end