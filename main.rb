require_relative 'io/display'
require_relative 'io/audio_manager'
require 'json'

start = Time.new
duration = Time.new - start
draws = 0

display = Display.new
audio = AudioManager.new

begin
	### Make sure all requires are called before this or the executable will crash
	exit if defined?(Ocra)

	# Load the starting map. This should go in a different class.
	raise 'starting map (data/maps/start.json) is missing' if !File.exists?('data/maps/start.json')
	start_map = JSON.parse(File.read('data/maps/start.json'))
	display.draw_map(start_map)
	getch
rescue
	display.destroy
end


