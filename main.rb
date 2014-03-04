require_relative 'utils/logger'
require_relative 'game'
Logger.new.info('Starting game ...')
Game.new.start
Logger.new.info('Normal termination. Goodbye!');