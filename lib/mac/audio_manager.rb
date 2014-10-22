class MacAudioManager
  def initialize
    #100% volume settter omitted; I really cannot seem to find a way to set the volume
  end
  
  def play(sound_filename)
    #uses afplay, which is said to be present on all mac after version 10.5
    exec "afplay -v 100 #{sound_filename}" if fork.nil?
  end
end
