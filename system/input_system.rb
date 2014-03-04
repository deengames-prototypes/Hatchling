class InputSystem	

	def initialize(player)
		@player = player
	end	
	
	def destroy		
	end

	def get_and_process_input		
		input = Keys.read_character
		
		if (input == 'up') then
			@player.y -= 1
		elsif (input == 'down') then
			@player.y += 1
		elsif (input == 'left') then
			@player.x -= 1
		elsif (input == 'right')
			@player.x += 1
		end
		
		return input
	end
end