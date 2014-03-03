require_relative 'system/display_system'
require_relative 'io/audio_manager'
require_relative 'model/color'
require_relative 'model/entity'
require 'json'

class Game

	def initialize
		@display = nil
	end

	def start
		begin
			### Make sure all requires are called before this or the executable will crash			
			exit if defined?(Ocra)
			
			# Load the game.
			game_data = JSON.parse(File.read('data/game.json'))
			
			# Load entitiy/component definitions			
			@component_definitions = game_data['components']
			
			# Load the starting map.
			start_map = JSON.parse(File.read("data/maps/#{game_data['starting_map']}"))
			@entities = create_entities_for(start_map)
			
			# Pass entities to our systems	
			@display = DisplaySystem.new(@entities) # replace map with entities
			audio = AudioManager.new() # Convert to audio System; pass entities
			@display.fill_screen('.', Color.new(128, 128, 128))
			
			quit = false
			while (!quit) do
				@display.draw
				input = getch
				quit = (input == 27) # 27 = ESC
			end
		rescue	
			@display.destroy unless @display.nil?
			raise # Re-raise after cleaning up
		end
	end
	
	def create_entities_for(map)
		entities = []
		grey = Color.new(192, 192, 192)
		
		if map['perimeter'] == true
			(0 .. map['width']).each do |x|
				# NOT classes. Wall is a bunch of components and data.
				# Components = DisplayComponent(x, y, char, color)
				# That's all data. There's no code here. Yet.
				# Old-style would be to have a MoveComponent instance in Player entity.
				# NewStyle is an empty "move" tag in the entity, and the MoveSystem operates on that.
				
				# TODO: we have some common entities (eg. walls) and components (eg. display), irrespective of game content
				# TODO: move this into a standard place for construction
				entities << Entity.new({ :x => x, :y => 0, :character => '#', :color => grey })
				entities << Entity.new({ :x => x, :y => map['height'] - 1, :character => '#', :color => grey })
			end
			
			(0 .. map['height']).each do |y|
				entities << Entity.new({ :x => 0, :y => y, :character => '#', :color => grey })
				entities << Entity.new({ :x => map['width'] - 1, :y => y, :character => '#', :color => grey })
			end
		end
		
		entities << Entity.new({ :x => 3, :y => 3, :character => '@', :color => Color.new(0, 192, 0) })
		entities << Entity.new({ :x => 7, :y => 4, :character => 'b', :color => Color.new(255, 0, 0) })
		
		return entities
	end
end