require 'win32/sound'
include Win32

class AudioManager
	def play(sound_filename)
		Sound.play(sound_filename)
	end
end