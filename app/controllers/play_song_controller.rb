class PlaySongController < SPTAudioStreamingController

  def init
    super
    playbackDelegate = self
    delegate         = self
    self
  end

end