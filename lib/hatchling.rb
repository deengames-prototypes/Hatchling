require_relative 'utils/logger'
require_relative 'game'
Logger.info('Starting game ...')
Game.new.start
Logger.info('Normal termination. Goodbye!');