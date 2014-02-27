# TODO: centralize platform check and expose constant
if RUBY_PLATFORM.include?('linux')
	require_relative '../linux/audio_manager'
	class AudioManager < LinuxAudioManager
	end
else
	require_relative '../windows/audio_manager'
	class AudioManager < WindowsAudioManager
	end
end
