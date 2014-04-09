require 'win32/sound'
include Win32

class WindowsAudioManager
	def play(sound_filename)
		Sound.play(sound_filename, Sound::ASYNC)
	end
end
