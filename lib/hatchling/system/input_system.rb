require 'ostruct'
require_relative '../utils/logger'
require_relative '../ui/character_screen'

class InputSystem

	def initialize(key_reader, display_system)
		@key_reader = key_reader
		@display_system = display_system
		setup_default_key_mappings
	end

	# TODO: accept a mapping of keys and functions to call when they're pressed
	# eg. pressing "c" calls "show_character_sheet," but we do that already.
	# Consider also exposing the mappings so that Hatchling users can tweak them.
	def init(entities, args)
		@entities = entities
		@entities.each do |e|
			if e.has?(:name) && e.name.downcase == 'player'
				@player = e
				break
			end			
		end
		
		raise 'Can\'t find player in entities. You need an entity with :name => "player"' if @player.nil?
	end	
	
	def destroy
	end
	
	def get_input
		i = @key_reader.read_character while i.nil?
		return i
	end
	
	## Processes input and returns what we did; a hash:
	# :key => the key pressed (eg. 'up')
	# :target => the thing you walked into (if you moved into something)
	def get_and_process_input		
		input = @key_reader.read_character		
		moves = ['up', 'down', 'left', 'right']
				
		# Processes input; notifies the target (if any and we moved)
		# Also does stuff like trapping ">" and sending it to stairs
		target = process_move(input)		
		
		@mappings.each do |key, function|
			function.call if input == key
		end
		
		result = {:key => input}
		result[:target] = target unless target.nil?
		# Time passes if you moved
		result[:pass_time] = moves.include?(input)
		return result
	end
	
	def entity_at(x, y)		
		@entities.each do |e|
			return e if e.has?(:display) && e.get(:display).x == x && e.get(:display).y == y && e != @player
		end		
		
		return nil
	end
	
	private
	
	## Processes input and moves the player appropriately; returns the
	# target of the player's move. If the player moved into something
	# (like a monster or wall), that will be returned.
	def process_move(input)
		target = OpenStruct.new({ x: @player.get(:display).x, y: @player.get(:display).y })
		
		if (input == 'up') then
			target.y -= 1
		elsif (input == 'down') then
			target.y += 1
		elsif (input == 'left') then
			target.x -= 1
		elsif (input == 'right')
			target.x += 1
		end
		
		e = entity_at(target.x, target.y)
		
		# Nothing there or nothing solid (like stairs)
		if e.nil? || (e.has?(:solid) && e.solid == false)
			@player.get(:display).x = target.x
			@player.get(:display).y = target.y			
		end
		
		if (!e.nil? && e.has?(:input))			
			e.get(:input).process_input(input)
		end
		
		return e
	end
	
	def setup_default_key_mappings
		@mappings = {
			'c' => lambda { CharacterScreen.new(@display_system, self).show }
		}		
	end
end
