class Keys

	# code_for('A') => 97
	# name_for(97) => 'A'
	
	@@keys = {		
		13 => 'enter',
		27 => 'escape',
		258 => 'down',
		259 => 'up',
		260 => 'left',
		261 => 'right'
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