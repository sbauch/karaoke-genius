class PlaySongController < SPTAudioStreamingController

  def init
    super
    playbackDelegate = self
    delegate         = self
    self
  end

  def clear
    stop(proc{|error|
    })

    queueClear(proc {|error|
    })
  end


  def play # from a paused state
    setIsPlaying(true, callback: proc{|error|
      if error
      end
    })

  end

  def pause
    setIsPlaying(false, callback: proc{|error|
      if error
        p error
      end
    })

  end

  def playbackState


  end

  def audioStreamingDidSkipToNextTrack(track)

  end

  def audioStreaming(controller, didChangeToTrack: track)

  end

  def audioStreamingDidBecomeActivePlaybackDevice(controller)
  end

  def audioStreamingDidBecomeInactivePlaybackDevice(controller)
    mainController.pause
    mainController.show_play_or_pause_button(true)
  end

  def audioStreamingDidEncounterTemporaryConnectionError(error)
    mainController.pause
  end

  def audioStreaming(audioStreaming, didFailToPlayTrack: trackUri)
    mainController.cantPlayTrack
  end

  def audioStreaming(audioStreaming, didReceiveMessage:message)
    NSLog(message)
  end


end