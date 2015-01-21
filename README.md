## Genius & Spotify karaoke app

The iOS app requires a Rubymotion license to run (submitted a beta build to Apple and working on getting an app.io demo up).
You'll also need to change `app.yml.sample` to 'app.yml` and add your own client ID and server endpoints.

A sinatra app is included in `token_swap/` that handles the Spotify oauth flow. You'll also need to add your Spotify Client ID and Secret here.