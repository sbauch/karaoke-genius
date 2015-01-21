class PlaySongController < SPTAudioStreamingController

  def init
    super
    playbackDelegate = self
    delegate         = self
    self
  end

  def clear
    stop(proc{|error| })
    queueClear(proc {|error|})
  end

end