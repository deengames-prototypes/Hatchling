require 'curses'
include Curses

#ENV['TERM'] = 'xterm-256color'
Curses.noecho # do not show typed keys
Curses.init_screen
Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)
Curses.start_color

for n in (0 .. 15) do		
	Curses.init_pair(n, n, 1)
	
	Curses.attron(color_pair(n)|A_NORMAL){
      Curses.addstr("#")
    }
end

Curses.getch