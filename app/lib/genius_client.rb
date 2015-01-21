class GeniusClient

    def self.client
      @client ||= AFMotion::Client.build('https://api.rapgenius.com') do
        header "Accept", "application/json"
        response_serializer :json
      end
    end

    def self.search(artist, song, &block)
      self.client.get('/search', {'q' => artist +  ' ' + song}) do |result|

        begin
          song_id = result.object['response']['hits'][0]['result']['id']
        rescue
          song_id = nil
        end

        if song_id
          self.get_lyrics(song_id) do |attr_string|
            block.call(attr_string, nil)
          end
        else

          block.call(nil, true)
        end
      end

    end

    def self.get_lyrics(song_id, &block)
      self.client.get("/songs/#{song_id}") do |result|
        lyrics = result.object['response']['song']['lyrics']['dom']['children']
        attr_string = GeniusLyricAttributedString.new(lyrics)
        block.call(attr_string)
      end
    end

end