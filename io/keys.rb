class Keys

	# code_for('A') => 97
	# name_for(97) => 'A'
	
	@@keys = {
		44 => 'comma',
		13 => 'enter',
		63 => 'question mark',
		46 => 'period',
		32 => 'space',
		62 => 'right',
		60 => 'left',
		72 => 'up',
		80 => 'down',
		27 => 'escape'
	}

	def self.name_of(code)
		return @@keys[code]
	end
	
	def self.read_character
		raw = getch
		if (raw.class.name == 'Fixnum')
			return @@keys[raw]
		else
			return raw
		end
	end
end