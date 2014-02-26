require_relative 'io/display'
require_relative 'io/audio_manager'

start = Time.new
duration = Time.new - start
draws = 0

display = Display.new
audio = AudioManager.new

### Make sure all requires are called before this or the executable will crash
exit if defined?(Ocra)

audio.play('assets/audio/beep.wav')
while (duration <= 3) do
	
	for y in (0 .. 25) do
		for x in (0 .. 80) do
		
			color = y % 16 #rand(0..15)
			letter = ('a'..'z').to_a.shuffle[0]
			display.draw(x, y, letter, color)			
		end
	end
	
	display.draw(0, 0, "#{draws/duration} FPS ")
	display.update
	draws += 1
	
	duration = Time.new - start	
end

puts "Completed in #{duration} seconds with #{draws/duration} FPS"