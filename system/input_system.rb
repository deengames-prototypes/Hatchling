class InputSystem	

	def initialize(entities)
		@entities = entities		
	end	
	
	def destroy
		
	end

	def get_and_process_input		
		input = Keys.read_character
		
		@entities.each do |e|
			if e.has_tag?(:input)
				e.process_input(input)
			end
		end
		
		return input
	end
end