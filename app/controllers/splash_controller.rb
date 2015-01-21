class SplashController < UIViewController

  def viewDidLoad
    @loader = UIActivityIndicatorView.alloc.init.tap do |loader|
      loader.frame = [[50, 400], [270, 50]]
      loader.startAnimating
    end

    addLabels

    self.view.addSubview(@loader)


  end

  def addLabels
    label = UILabel.alloc.initWithFrame([[25,190],[Device.screen.width - 50, 140]]).tap do |lbl|
      lbl.font = UIFont.fontWithName('DINCondensedC', size: 30)
      lbl.textColor = '#ffc31c'.uicolor
      lbl.text = "Log In with Spotify to sing along to your favorite tunes"
      lbl.textAlignment = NSTextAlignmentCenter
      lbl.numberOfLines = 0
    end

    self.view.addSubview(label)

    sublabel = UILabel.alloc.initWithFrame([[25,330],[Device.screen.width - 50, 40]]).tap do |lbl|
      lbl.font = UIFont.fontWithName('DINCondensedC', size: 20)
      lbl.textColor = '#999999'.uicolor
      lbl.text = "You must be a Spotify Premium user"
      lbl.textAlignment = NSTextAlignmentCenter
      lbl.numberOfLines = 0
    end

    self.view.addSubview(sublabel)

  end

  def add_auth
    @loader.fade_out do
      auth_button = UIButton.custom.tap do |btn|
        btn.setBackgroundImage('spotify_auth'.uiimage, forState: UIControlStateNormal)
        btn.on(:touch){auth_spotify}
        btn.frame = [[50, 400], [270, 50]]
        btn.alpha = 0.0
      end
      self.view.addSubview(auth_button)
      auth_button.fade_in
    end

  end

  def auth_spotify
    callback_url = "karaoke-genius-spotify://"
    SPTAuth.defaultInstance.loginURLForClientId(ENV['CLIENT_ID'],
                                                declaredRedirectURL: callback_url.nsurl,
                                                scopes:[SPTAuthPlaylistModifyPrivateScope,
                                                        SPTAuthPlaylistReadPrivateScope,
                                                        SPTAuthUserLibraryReadScope,
                                                        SPTAuthStreamingScope],
                                                withResponseType: 'code').open

  end


end