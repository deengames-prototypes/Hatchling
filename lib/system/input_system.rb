require 'ostruct'
require_relative '../utils/logger'

class InputSystem

	def init(entities)		
		@entities = entities
		@entities.each do |e|
			if e.has?(:name) && e.name.downcase == 'player'
				@player = e
				Logger.debug("P=#{@player}")
				break
			end			
		end
		
		raise 'Can\'t find player in entities' if @player.nil?
	end	
	
	def destroy
	end

	def get_input
		Keys.read_character
	end
	
	def get_and_process_input			
		input = Keys.read_character
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
		
		if e.nil? || (e.has?(:solid) && e.solid == false)
			@player.get(:display).x = target.x
			@player.get(:display).y = target.y			
		end
		
		if (!e.nil? && e.has?(:input))			
			e.get(:input).process_input(input)
		end
		
		return input
	end
	
	def entity_at(x, y)		
		@entities.each do |e|
			return e if e.has?(:display) && e.get(:display).x == x && e.get(:display).y == y && e != @player
		end		
		
		return nil
	end
end
