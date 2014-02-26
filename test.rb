require 'curses'
include Curses

#ENV['TERM'] = 'xterm-256color'
Curses.noecho # do not show typed keys
Curses.init_screen
Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)
Curses.start_color

for n in (0 .. 15) do		
	Curses.init_pair(n, n, 0)
end

start = Time.new
duration = Time.new - start
draws = 0

while (duration <= 10) do
	
	for y in (0 .. 25) do
		for x in (0 .. 80) do
		
			color = y % 16 #rand(0..15)
			letter = ('a'..'z').to_a.shuffle[0]
			
			Curses.attron(color_pair(color)|A_NORMAL){
				setpos(y, x)
				addch(letter)
			}
		end
	end
	
	setpos(0, 0)
	addstr("#{draws/duration} FPS ")
	
	refresh
	draws += 1
	
	duration = Time.new - start	
end

puts "Completed in #{duration} seconds with #{draws/duration} FPS"