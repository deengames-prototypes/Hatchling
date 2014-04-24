require_relative 'system/display_system'
require_relative 'system/input_system'
require_relative 'system/battle_system'
require_relative 'io/audio_manager'
require_relative 'io/keys'
require_relative 'utils/color'
require_relative 'model/entity'
require_relative 'component/display_component'
require_relative 'component/input_component'
require_relative 'component/experience_component'

require 'ostruct'
require 'json'

module Hatchling
	class Game

		attr_reader :current_map, :player
		
		@@instance = nil	
		
		def initialize			
			@@instance = self
			@display = DisplaySystem.new
			@input = InputSystem.new(Keys)
			@battle = BattleSystem.new
			@systems = [@display, @input, @battle]
		end
		
		def self.instance
			@@instance
		end
		
		def start
			setup_logger = false
			
			begin
				### Make sure all requires are called before this or the executable will crash			
				exit if defined?(Ocra)			
				
				# Load the game.
				if (!File.exists?('data/game.json')) then
					raise 'Missing main game definition file: data/game.json'
				end

				game_data = OpenStruct.new(JSON.parse(File.read('data/game.json')))
				game_name = game_data.name
				
				Logger.init(game_name)
				setup_logger = true
				Logger.info('Starting game ...')
				note_seed
				
				if game_data.starting_map.nil?
					raise 'Game definition is missing a starting map ("starting_map" property); please tell it which map to start on.'
				end
				
				if (!File.exists?("data/maps/#{game_data.starting_map}"))
					raise "Starting map (data/maps/#{game_data.starting_map}) seems to be missing."
				end
				
				# Load entitiy/component definitions			
				@component_definitions = game_data.components
				battler = Battler.new # Game-specific class instance
				
				# Load the starting map.
				@town = OpenStruct.new(JSON.parse(File.read("data/maps/#{game_data.starting_map}")))
				@town.floor = 0
				change_map(@town)
				@current_map = @town
				@display.clear # change_map draws dots, but we can't init the display any later
				
				### Draw the titlescreen ###
				@display.draw_text((80 - game_data.name.length) / 2, 10, game_data.name.upcase, Color.new(255, 0, 0))
				@display.draw_text((80 - 23) / 2, 12, 'Press any key to begin.', Color.new(255, 255, 255))				
				AudioManager.new.play(game_data.titlescreen_audio) if !game_data.titlescreen_audio.nil?				
				@input.get_input				
				
				### Draw the story ###
				if (!game_data.story.nil?) then
					@display.clear				
					@display.draw_text(0, 0, game_data.story, Color.new(192, 192, 192))
					@input.get_input			
				end
				
				# Start drawing the main map
				@display.fill_screen('.', Color.new(128, 128, 128))
				@display.draw
				
				battle_messages = []
				input = nil
				quit = false
				
				while (!quit) do					
					@display.add_messages(battle_messages) unless battle_messages.nil?
					@display.draw					
					input = @input.get_and_process_input
					
					battle_results = @battle.process(input)
					battle_messages = battle_results[:messages]
					battler_results = battler.resolve_attacks(battle_results[:attacks])
					
					battler_results[:messages].each do |m|
						battle_messages << m
					end
					
					@entities.each do |e|
						@entities.delete(e) if e.has?(:health) && !e.get(:health).is_alive?
					end
					
					quit = (input[:key] == 'q' || input[:key] == 'escape')
				end
				
				Logger.info('Normal termination')
			rescue StandardError => e
				Logger.info("Termination by error: #{e}\n#{e.backtrace}") unless !setup_logger
				@systems.each do |s|
					s.destroy unless s.nil? || !s.respond_to?(:destroy)
				end
				raise # Re-raise after cleaning up
			end
		end
		
		def create_entities_for(map)
			entities = []
			grey = Color.new(192, 192, 192)
			
			if map.respond_to?('perimeter') && map.perimeter == true
				(0 .. map.width - 1).each do |x|
					# TODO: we have some common entities (eg. walls) and components (eg. display), irrespective of game content
					# TODO: move this into a standard place for construction
					entities << Entity.new({ :display => DisplayComponent.new(x, 0, '#', grey) })
					entities << Entity.new({ :display => DisplayComponent.new(x, map.height - 1, '#', grey) })
				end
							
				(0 .. map.height - 1).each do |y|
					entities << Entity.new({ :display => DisplayComponent.new(0, y, '#', grey) })
					entities << Entity.new({ :display => DisplayComponent.new(map.width - 1, y, '#', grey) })
				end
			end
			
			@player ||= Entity.new({
				# For identification
				:name => 'Player',
				# Display properties
				:display => DisplayComponent.new(map.start_x.to_i, map.start_y.to_i, '@', Color.new(255, 192, 32)),
				:health => HealthComponent.new(50),
				:battle => BattleComponent.new({:strength => 7, :speed => 3 }),
				# TODO: make this lambda available to the user to specify. Simple exponential growth: 50x^2 + 100x
				:experience => ExperienceComponent.new(lambda { |level| return (level**2 * 50) + (level * 100) })
			})
			
			if map.respond_to?('stairs') && !map.stairs.nil? then			
				if map.stairs.class.name != 'Array'			
					# single object
					map.stairs = [map.stairs]
				end
				
				map.stairs.each do |s|
					if s.has_key?('direction') && s['direction'].downcase == 'up' then
						i = InputComponent.new(Proc.new { |input| change_floor(@current_map.floor - 1) if input == '<' })
						c = '<'
					else					
						i = InputComponent.new(Proc.new { |input| change_floor(@current_map.floor + 1) if input == '>' })
						c = '>'
					end
					
					e = Entity.new({
						:display => DisplayComponent.new(s['x'], s['y'], c, Color.new(255, 255, 255)),
						:input => i,
						:solid => false
					})				
					
					entities << e
				end
			end
			
			if map.respond_to?('npcs') && !map.npcs.nil?
				(map.npcs).each do |npc|				
					entities << Entity.new({ :display => DisplayComponent.new(npc['x'], npc['y'], '@', Color.new(npc['color']['r'], npc['color']['g'], npc['color']['b']))})
				end
			end
			
			if map.respond_to?('walls') && !map.walls.nil? then								
				map.walls.each do |w|
					entities << Entity.new({ :display => DisplayComponent.new(w[0], w[1], '#', grey) })
				end
			end
			
			if map.respond_to?('entities') && !map.entities.nil?
				map.entities.each do |e|
					entities << e
				end			
			end
			
			# Draw last
			entities << @player
			
			return entities
		end
		
		def change_floor(floor_num)
			if floor_num > 0
				change_map(Dungeon.new(floor_num))
			else
				change_map(@town)
			end
					
			stairs = @current_map.stairs.find { |s| !s['direction'].nil? && s['direction'].downcase == 'up' }			
			if stairs.nil?
				stairs = @current_map.stairs.find { |s| !s['direction'].nil? && s['direction'].downcase == 'down' }
			end
			
			p = @player.get(:display)
			p.x = stairs['x']
			p.y = stairs['y']			
		end
		
		def change_map(new_map)
			@current_map = new_map
			@entities = create_entities_for(@current_map)
			
			# Synch entities of the generated map (Hatchling: from JSON) and Dungeon map (from the game)
			# This simplifies all kinds of things, like collision detection.
			@entities.concat(new_map.entities) if !new_map.entities.nil?
			@current_map.entities = @entities
			
			# Pass entities to our systems	
			@systems.each do |s|				
				s.init(@entities, { :current_map => @current_map })				
			end
			
			@display.fill_screen('.', Color.new(128, 128, 128))
		end
		
		private
		
		def note_seed
			# Set the seed here for seeded games
			#seed = 225931023275159639213945590160008751535
			#Random.srand(seed)
			
			seed = srand()
			srand(seed)
			Logger.info("This is game ##{seed}")
		end
	end
end
