# TODO: centralize platform check and expose constant
if RUBY_PLATFORM.include?('linux')
	require_relative '../linux/audio_manager'
	class Hatchling::AudioManager < LinuxAudioManager
	end
elsif RUBY_PLATFORM.include?('darwin') # macos
  require_relative '../mac/audio_manager'
  Hatchling::AudioManager = Class.new MacAudioManager
else
	require_relative '../windows/audio_manager'
	class Hatchling::AudioManager < WindowsAudioManager
	end
end
