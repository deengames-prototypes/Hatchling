class LinuxAudioManager

	def initialize
		# Play at 100% volume
		`amixer set Master 100`
	end
	
	def play(sound_filename)
		# TODO: centralize exec/play part
		exec("aplay -q -N #{sound_filename}") if fork.nil?
	end
end
