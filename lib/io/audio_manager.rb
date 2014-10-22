# TODO: centralize platform check and expose constant
if RUBY_PLATFORM.include?('linux')
	require_relative '../linux/audio_manager'
	class AudioManager < LinuxAudioManager
	end
elsif RUBY_PLATFORM.include?('darwin') # Mac OS
  require_relative '../mac/audio_manager'
  Hatchling::AudioManager = MacAudioManager
else
	require_relative '../windows/audio_manager'
	class AudioManager < WindowsAudioManager
	end
end
