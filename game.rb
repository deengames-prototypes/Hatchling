require_relative 'system/display_system'
require_relative 'io/audio_manager'
require 'json'

class Game
	def initialize
		@display = nil
	end

	def start
		begin
			### Make sure all requires are called before this or the executable will crash			
			exit if defined?(Ocra)
			
			# Load the starting map. This should go in a different class.	
			start_map = JSON.parse(File.read('data/maps/start.json'))
			entities = create_entities_for(start_map)
			
			# Pass entities to our systems	
			@display = DisplaySystem.new(start_map) # replace map with entities
			audio = AudioManager.new() # Convert to audio System; pass entities
			
			while (true) do
				@display.draw
				getch		
			end
		rescue	
			@display.destroy unless @display.nil?
			raise # Re-raise after cleaning up
		end
	end
	
	def create_entities_for(map)
		[]
	end
end