class SingalongController < UIViewController
  include BW::KVO

  attr_accessor :spotify_song_id

  def viewDidLoad
    self.navigationItem.title = 'Sing!'
    self.view.backgroundColor = '#151515'.uicolor
    self.automaticallyAdjustsScrollViewInsets = false

    init_spotify do
      @song_controller.queueURI(('spotify:track:' + self.spotify_song_id).nsurl, callback: proc{|error|
        if error
          p error
        else
          add_scrubber
          observe(@song_controller, :currentPlaybackPosition) do |old_value, new_value|
            update_scrubber(new_value)
            scroll_lyrics(new_value)
          end
        end
      })


    end

    @loader = UIActivityIndicatorView.alloc.init.tap do |loader|
      loader.frame = [[50, 200], [270, 50]]
      loader.startAnimating
    end

    self.view.addSubview(@loader)

  end

  def viewWillDisappear(animated)
    @song_controller.clear

  end

  def init_spotify(&block)
    @song_controller ||= PlaySongController.alloc.initWithClientId(ENV['CLIENT_ID'])

    if @song_controller.loggedIn == false

      @song_controller.loginWithSession(UIApplication.sharedApplication.delegate.session, callback:proc {|error|

        if error
          p error
        else
          block.call
        end
      })
    else
      block.call
    end
  end

  def scroll_lyrics(playback_position)
    return unless @lyrics
    @middle_lyric_char ||= 0

    lyrics_chars  = @lyrics.text.length + 200
    song_duration = @song_controller.currentTrackMetadata['SPTAudioStreamingMetadataTrackDuration']
    new_middle_lyric_char = (playback_position / song_duration) * lyrics_chars
    @middle_lyric_char = new_middle_lyric_char

    @lyrics.scrollRangeToVisible((@middle_lyric_char)..(@middle_lyric_char + 500))

  end

  def add_scrubber
    @scrubber = ScrubberView.alloc.init
    @scrubber.delegate = self
    view.addSubview(@scrubber)
  end

  def update_scrubber(playbackPosition)
    @scrubber.update(playbackPosition, @song_controller.currentTrackMetadata['SPTAudioStreamingMetadataTrackDuration'])
  end

  def seek_to_percentage(percentage)
    timestamp = percentage * @song_controller.currentTrackMetadata['SPTAudioStreamingMetadataTrackDuration']
    @song_controller.seekToOffset(timestamp, callback: proc{|error|
      if error
        p error
      end
    })

  end

  def get_lyrics(artist, track)
    GeniusClient.search(artist, track) do |genius_lyric_attr_string, error|
      @loader.stopAnimating

      if error
        UIAlertView.alert('Problems', message: "Couldn't find that song on Genius",
                          buttons: ['Choose a New Song'])


      else
        @lyrics = UITextView.alloc.initWithFrame([[25, 80], [Device.screen.width - 50, self.view.frame.size.height - 60]]).tap do |tv|
          tv.attributedText = NSAttributedString.alloc.initWithAttributedString(genius_lyric_attr_string.attributedString)
          tv.backgroundColor = UIColor.clearColor
          tv.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
          tv.editable = false
          tv.setTextContainerInset(UIEdgeInsetsMake(self.view.frame.size.height - 60, 0, 0, 0))
        end

        self.view.addSubview(@lyrics)
      end
    end
  end



end