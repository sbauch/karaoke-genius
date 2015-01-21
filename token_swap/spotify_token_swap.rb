require 'sinatra'
require 'net/http'
require 'net/https'
require 'base64'
require 'json'
require 'encrypted_strings'
require "bundler/setup"

CLIENT_ID = "3edb3fcb3fa34d46b9f0cedff6ccfb60"
CLIENT_SECRET = "a116c44b322147d0aa99757e58ca552e"
ENCRYPTION_SECRET = "cFJLyifeUJUBFWdHzVbykfDmPHtLKLGzViHW9aHGmyTLD8hGXC"
CLIENT_CALLBACK_URL = "karaoke-genius-spotify://"
AUTH_HEADER = "Basic " + Base64.strict_encode64(CLIENT_ID + ":" + CLIENT_SECRET)
SPOTIFY_ACCOUNTS_ENDPOINT = URI.parse("https://accounts.spotify.com")

set :port, 1234 
set :bind, '0.0.0.0' 


post '/swap' do

    auth_code = params[:code]

    http = Net::HTTP.new(SPOTIFY_ACCOUNTS_ENDPOINT.host, SPOTIFY_ACCOUNTS_ENDPOINT.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new("/api/token")

    request.add_field("Authorization", AUTH_HEADER)

    request.form_data = {
        "grant_type" => "authorization_code",
        "redirect_uri" => CLIENT_CALLBACK_URL,
        "code" => auth_code
    }

    response = http.request(request)

    # encrypt the refresh token before forwarding to the client
    if response.code.to_i == 200
        token_data = JSON.parse(response.body)
        refresh_token = token_data["refresh_token"]
        encrypted_token = refresh_token.encrypt(:symmetric, :password => ENCRYPTION_SECRET)
        token_data["refresh_token"] = encrypted_token
        response.body = JSON.dump(token_data)
    end

    status response.code.to_i
    return response.body
end

post '/refresh' do

    # Request a new access token using the POST:ed refresh token

    http = Net::HTTP.new(SPOTIFY_ACCOUNTS_ENDPOINT.host, SPOTIFY_ACCOUNTS_ENDPOINT.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new("/api/token")

    request.add_field("Authorization", AUTH_HEADER)

    encrypted_token = params[:refresh_token]
    refresh_token = encrypted_token.decrypt(:symmetric, :password => ENCRYPTION_SECRET)

    request.form_data = {
        "grant_type" => "refresh_token",
        "refresh_token" => refresh_token
    }

    response = http.request(request)

    status response.code.to_i
    return response.body

end



