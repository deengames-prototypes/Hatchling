require_relative '../utils/logger'
require 'curses'
include Curses

require_relative('../windows/dos_color_strategy')
require_relative('../linux/rgb_color_strategy')

# Wrapper around the display API (currently Curses)
class Display
	def initialize
		ENV['TERM'] = 'xterm-256color' # Helps Linux only
		Curses.noecho # do not show typed keys
		Curses.init_screen		
		Curses.start_color
		Curses.stdscr.keypad(true) # Trap arrow keys
		Curses.curs_set(0) # Hide cursor
		
		Logger.info("Running at #{Curses.cols}x#{Curses.lines} with #{Curses.colors} colours")
		if (Curses.cols < 80 || Curses.lines < 25) then
			raise "Please resize your terminal to be at least 80x25 (currently, it's #{Curses.cols}x#{Curses.lines})"
		end		
		Curses.resizeterm(25, 80)

		# TODO: penguins have 256 colors :O
		for n in (0 .. Curses.colors) do
			Curses.init_pair(n, n, 0)
		end
		
		if (Curses.colors > 16)
			@color_strategy = RgbColorStrategy.new(self)
		else
			@color_strategy = DosColorStrategy.new
		end
	end
	
	def width
		return 80
	end
	
	def height
		return 25
	end
	
	# Color = { :r => red, :g => green, :b => blue }
	def draw(x, y, text, color)		
		return if text.nil? || text.length == 0
		color_index = @color_strategy.get_index_for(color)
		Curses.attron(Curses.color_pair(color_index) | A_NORMAL) {
			Curses.setpos(y, x)
			# Seems like a small thing, but using characters is almost twice as fast
			if (text.length <= 1) then
				Curses.addch(text)
			else 
				Curses.addstr(text)
			end
		}		
	end	
	
	def initialize_color(index, color)
		# Map (0 .. 255) to (0 .. 1000) by multiplying by 4. Max is 1020, so round down.
		Curses.init_color(index, [color.r * 4, 1000].min, [color.g * 4, 1000].min, [color.b * 4, 1000].min)
	end
	
	def update
		Curses.refresh
	end
	
	def destroy
		Logger.info('Terminating display.')
		Curses.close_screen
	end
end
