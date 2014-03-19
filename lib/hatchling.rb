require 'json'
#require 'ruby-prof'

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

#result = RubyProf.profile do
	Game.new.start
#end

File.open('flat.txt', 'w') do |f|
	printer = RubyProf::FlatPrinter.new(result)
	printer.print(f)
end

File.open('graph.txt', 'w') do |f|
	printer = RubyProf::GraphPrinter.new(result)
	printer.print(f, {})
end

Logger.info('Goodbye!');
