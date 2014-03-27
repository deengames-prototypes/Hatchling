require_relative 'base_component'

class Hatchling::DisplayComponent < BaseComponent
	attr_accessor :x, :y
	attr_reader :character, :color
	
	def initialize(x, y, char, color)
		@x = x
		@y = y
		@character = char
		@color = color
	end
	
	def move(move)
		@x = move[:x] if move.has_key?(:x)
		@y = move[:y] if move.has_key?(:y)
	end
end