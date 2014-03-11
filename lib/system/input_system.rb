require 'ostruct'
require_relative '../utils/logger'

class InputSystem	

	def initialize(entities, player)
		@player = player
		@entities = entities
	end	
	
	def destroy
	end

	def get_input
		Keys.read_character
	end
	
	def get_and_process_input			
		input = Keys.read_character
		target = OpenStruct.new({ x: @player.x, y: @player.y })
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
		
		if e.nil? || (e.has?(:solid) && e.solid == false)
			@player.x = target.x
			@player.y = target.y			
		end
		
		if (!e.nil?)			
			e.process_input(input)
		end
		
		return input		
	end
	
	def entity_at(x, y)		
		@entities.each do |e|
			return e if x == e.x && y == e.y && e != @player
		end		
		
		return nil
	end
end
