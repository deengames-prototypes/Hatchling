class Input

	# code_for('A') => 97
	# name_for(97) => 'A'
	
	def initialize
	  @keys = {
	    10 => 'enter',  # Linux?
		  13 => 'enter', # Windows?
		  27 => 'escape',
		  258 => 'down',
		  259 => 'up',
		  260 => 'left',
		  261 => 'right'
	  }
	end
	
	def read_character
		raw = getch while raw.nil?
		if raw.class.name == 'Fixnum' && @keys.key?(raw)
			return @keys[raw]
		else
			return raw.to_s
		end
	end
end
