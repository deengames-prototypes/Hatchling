require 'json'

# Load everything. And I mean everything :)
components = ['health_component', 'battle_component', 'display_component']

require_relative 'hatchling/game'
components.each do |c|
	require "hatchling/component/#{c}"
end