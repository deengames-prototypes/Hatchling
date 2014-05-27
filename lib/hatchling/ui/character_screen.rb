class CharacterScreen

	def initialize(display_system, input_system)
		@display_system = display_system
		@input_system = input_system
	end
	
	def show		
		@display_system.clear
		@input_system.get_input
		# Not a hack. Entities will be drawn over these.
		@display_system.fill_screen('.', Color.new(128, 128, 128))
		@display_system.draw
	end

end
