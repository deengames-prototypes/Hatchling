require_relative 'base_component'

class DisplayComponent < BaseComponent
	attr_accessor :x, :y
	attr_reader :character, :color
	
	def initialize(x, y, char, color)
		@x = x
		@y = y
		@character = char
		@color = color
		super()
	end
	
	def move(move)
		@x = move[:x] if move.has_key?(:x)
		@y = move[:y] if move.has_key?(:y)
	end
	
	def to_s
		return "#{@character} at (#{x}, #{y})"
	end
end
