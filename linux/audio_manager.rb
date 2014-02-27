class LinuxAudioManager
	def play(sound_filename)
		# TODO: centralize exec/play part
		exec("aplay -q -N #{sound_filename}") if fork.nil?
	end
end
