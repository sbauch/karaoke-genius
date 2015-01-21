class AppDelegate

  attr_accessor :session

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    rootViewController = SplashController.alloc.init
    rootViewController.title = 'Karaoke Genius'
    rootViewController.view.backgroundColor = '#151515'.uicolor

    @navigationController = UINavigationController.alloc.initWithRootViewController(rootViewController)
    @navigationController.navigationBar.setTitleTextAttributes({UITextAttributeTextColor => '#ffc31c'.uicolor,
                                                                UITextAttributeFont => UIFont.fontWithName('DINCondensed-Bold', size:24)})
    @navigationController.navigationBar.barTintColor = '#151515'.uicolor
    UINavigationBar.appearance.setTintColor('#999999'.uicolor)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @navigationController
    @window.makeKeyAndVisible

    true
  end

  def application(application, openURL:url, sourceApplication:sourceApplication,  annotation:annotation)

    if SPTAuth.defaultInstance.canHandleURL(url, withDeclaredRedirectURL:'karaoke-genius-spotify://'.nsurl)

      SPTAuth.defaultInstance.handleAuthCallbackWithTriggeredAuthURL(url,
        tokenSwapServiceEndpointAtURL: (ENV['HOST'] + '/swap').nsurl,
        callback: proc {|error, session|
          if error
            UIAlertView.alert('Problems', message: error.localizedDescription,
                              buttons: ['OK'])
          else
            getUserInfo(session) do |premium|
              if premium
                save_session(session)
                push_main_view_controller
              else
                UIAlertView.alert('Problems', message: "Only Spotify Premium users can stream songs in Karaoke Genius",
                                  buttons: ['OK'])
              end
            end
          end
        })
    end
  end

  def applicationDidBecomeActive(application)

    if NSUserDefaults['access_token']
      SPTSession.alloc.initWithUserName(NSUserDefaults['spotify_username'],
                                        accessToken: NSUserDefaults['access_token'],
                                        encryptedRefreshToken: NSUserDefaults['refresh_token'],
                                        expirationDate: NSUserDefaults['session_expires']
      ).tap do |session|

        if session.isValid
          save_session(session)
          push_main_view_controller(false)
        else
          SPTAuth.defaultInstance.renewSession(session,
            withServiceEndpointAtURL: (ENV['HOST'] + '/refresh').nsurl,
            callback: proc{|error, session|
              if error
                @navigationController.topViewController.add_auth
                # raise an error
              else
                save_session(session)
                push_main_view_controller
              end
            })
        end
      end
    else
      @navigationController.topViewController.add_auth
    end
  end

  def getUserInfo(session, &block)
    SPTRequest.userInformationForUserInSession(session, callback: proc{|error, user|
      p user.product
      if (user.product == 2 || user.product == 3)
        block.call(true)
      else
        block.call(false)
      end
    })
  end

  def push_main_view_controller(animated = true)
    @navigationController.setViewControllers([SongSelectionController.alloc.init], animated:animated)
  end

  def save_session(session)
    NSUserDefaults['spotify_username']  = session.canonicalUsername
    NSUserDefaults['access_token']      = session.accessToken
    NSUserDefaults['refresh_token']     = session.encryptedRefreshToken
    NSUserDefaults['session_expires']   = session.expirationDate
    self.session = session
  end


end

