require_relative 'system/display_system'
require_relative 'system/input_system'
require_relative 'system/battle_system'
require_relative 'io/audio_manager'
require_relative 'io/keys'
require_relative 'utils/color'
require_relative 'model/entity'
require_relative 'component/display_component'
require_relative 'component/input_component'

require 'ostruct'
require 'json'

class Game

	attr_reader :current_map, :player
	
	@@instance = nil	
	
	def initialize	
		# Set the seed here for seeded games
		#seed = 289538379890027845966326158351430095932
		#Random.srand(seed)
		
		seed = srand()
		srand(seed)
		Logger.info("This is game ##{seed}")
		
		@@instance = self
		@display = DisplaySystem.new
		@input = InputSystem.new
		@battle = BattleSystem.new
		@systems = [@display, @input, @battle]
	end
	
	def self.instance
		@@instance
	end
	
	def start
		begin
			### Make sure all requires are called before this or the executable will crash			
			exit if defined?(Ocra)			
			
			game_data = OpenStruct.new(JSON.parse(File.read('data/game.json')))
			if game_data.starting_map.nil?
				raise 'Game definition is missing a starting map ("starting_map" property); please tell it which map to start on.'
			end
			
			if (!File.exists?("data/maps/#{game_data.starting_map}"))
				raise "Starting map (data/maps/#{game_data.starting_map}) seems to be missing."
			end
			
			# Load entitiy/component definitions			
			@component_definitions = game_data.components
			
			# Load the starting map.
			@town = OpenStruct.new(JSON.parse(File.read("data/maps/#{game_data.starting_map}")))
			@town.floor = 0
			change_map(@town)
			@current_map = @town
			@display.clear # change_map draws dots, but we can't init the display any later
			
			audio = AudioManager.new() # Convert to audio System; pass entities
			
			### Draw the titlescreen ###
			@display.draw_text((80 - game_data.name.length) / 2, 10, game_data.name.upcase, Color.new(255, 0, 0))
			@display.draw_text((80 - 23) / 2, 12, 'Press any key to begin.', Color.new(255, 255, 255))
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
				@display.add_messages(input[:messages]) unless input.nil? || input[:messages].nil?
				@display.add_messages(battle_messages) unless battle_messages.nil?
								
				@display.draw
				input = @input.get_and_process_input
				battle_messages = @battle.process(input)
				quit = (input[:key] == 'q' || input[:key] == 'escape')
			end
			Logger.info('Normal termination')
		rescue StandardError => e
			Logger.info("Termination by error: #{e}\n#{e.backtrace}")
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
			(0 .. map.width).each do |x|
				# TODO: we have some common entities (eg. walls) and components (eg. display), irrespective of game content
				# TODO: move this into a standard place for construction
				entities << Entity.new({ :display => DisplayComponent.new(x, 0, '#', grey) })
				entities << Entity.new({ :display => DisplayComponent.new(x, map.height - 1, '#', grey) })
			end
						
			(0 .. map.height).each do |y|
				entities << Entity.new({ :display => DisplayComponent.new(0, y, '#', grey) })
				entities << Entity.new({ :display => DisplayComponent.new(map.width - 1, y, '#', grey) })
			end
		end
		
		@player = Entity.new({
			# For identification
			:name => 'Player',
			# Display properties
			:display => DisplayComponent.new(map.start_x.to_i, map.start_y.to_i, '@', Color.new(255, 192, 32))
		})		
		
		if map.respond_to?('stairs') && !map.stairs.nil? then			
			if map.stairs.class.name != 'Array'			
				# single object
				map.stairs = [map.stairs]
			end
			
			map.stairs.each do |s|
				if s.has_key?('direction') && s['direction'].downcase == 'up' then
					input = InputComponent.new(Proc.new { |input| change_floor(@current_map.floor - 1) if input == '<' })
					c = '<'
				else					
					input = InputComponent.new(Proc.new { |input| change_floor(@current_map.floor + 1) if input == '>' })
					c = '>'
				end
				
				e = Entity.new({
					:display => DisplayComponent.new(s['x'], s['y'], c, Color.new(255, 255, 255)),
					:input => input,
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
			white = Color.new(255, 255, 255)
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
	end
	
	def change_map(new_map)
		@current_map = new_map
		@entities = create_entities_for(@current_map)
		
		# Pass entities to our systems	
		@systems.each do |s|
			s.init(@entities)
		end
		
		@display.fill_screen('.', Color.new(128, 128, 128))
	end
end
