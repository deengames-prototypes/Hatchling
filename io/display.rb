require 'curses'
include Curses

class Display
	@@instance = nil
	
	def initialize
		@@instance = self
		
		ENV['TERM'] = 'xterm-256color'
		Curses.noecho # do not show typed keys
		Curses.init_screen		
		Curses.start_color

		# TODO: penguins have 256 colors :O

		for n in (0 .. Curses.colors) do
			Curses.init_pair(n, n, 0)
		end
	end
	
	# color = 0-15; defaults to grey 
	def draw(x, y, text, color = 7)
		Curses.attron(Curses.color_pair(color) | A_NORMAL) {
			Curses.setpos(y, x)
			# Seems like a small thing, but using characters is almost twice as fast
			if (text.length <= 1) then
				Curses.addch(text)
			else 
				Curses.addstr(text)
			end
		}
	end
	
	def update
		Curses.refresh
	end
end
