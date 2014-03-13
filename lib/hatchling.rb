require 'json'

# Load the game.
if (!File.exists?('data/game.json')) then
	raise 'Missing main game definition file: data/game.json'
end

game_data = JSON.parse(File.read('data/game.json'))
game_name = game_data['name']
			
require_relative 'utils/logger'
require_relative 'game'
Logger.init(game_name)
Logger.info('Starting game ...')
Game.new.start
Logger.info('Goodbye!');
