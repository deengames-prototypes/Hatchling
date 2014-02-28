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
			@display.fill_screen('.', 7)
			
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
		entities = []
		
		if map['perimeter'] == true
			(0 .. map['width']).each do |x|
				# NOT classes. Wall is a bunch of components and data.
				# Components = DisplayComponent(x, y, char, color)
				# That's all data. There's no code here. Yet.
				# (eg. move component for player can go in code/*.rb)
				entities << { :display => { :x => x, :y => 0, :character => '#', :color => 7 } }
				entities << { :display => { :x => x, :y => map['height'] - 1, :character => '#', :color => 7 } }
			end
			
			(0 .. map['height']).each do |y|
				entities << { :display => { :x => 0, :y => y, :character => '#', :color => 7 } }
				entities << { :display => { :x => map['width'] - 1, :y => y, :character => '#', :color => 7 } }
			end
		end
		
		return entities
	end
end