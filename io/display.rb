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
		Curses.curs_set(0) # Hide cursor

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

		Curses.setpos(3, 3) # Hack. Cursor on a wall shows the underlying tile; position elsewhere. This is despite hiding the cursor.
	end
	
	def draw_map(map)
		(0 .. map['width']).each do |x|
			(0 .. map['height']).each do |y|
				if map['perimeter'] == true && (x == 0 || y == 0 || x == map['width'] - 1 || y == map['height'] - 1) then
					self.draw(x, y, '#')
				else
					self.draw(x, y, '.')
				end
			end
		end

		self.update
	end
	
	def update
		Curses.refresh
	end

	def destroy
		Curses.close_screen
	end
end
