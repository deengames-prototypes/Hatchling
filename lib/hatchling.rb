require 'json'

# Load everything we need.
components = ['health_component', 'battle_component', 'display_component', 'interaction_component']

require_relative 'hatchling/game'
components.each do |c|
	require "hatchling/component/#{c}"
end
