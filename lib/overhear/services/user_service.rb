# frozen_string_literal: true

module Overhear
  # Service for user-specific ListenBrainz API actions.
  # @since 0.1.0
  class UserService
    # @param http [Overhear::HttpConnection]
    # @param username [String] the authenticated user's ListenBrainz username
    def initialize(http, username)
      @http = http
      @username = username
    end

    # Gets the user's currently playing track
    # @return [Song, nil] the currently playing song, or nil if nothing is playing
    def now_playing
      Overhear.logger.info("Fetching currently playing track for user: #{@username}")
      response = @http.get("/1/user/#{@username}/playing-now", @http.default_headers)
      payload = @http.parse_response(response)['payload']

      if payload['count'].zero?
        Overhear.logger.info("No track currently playing for user: #{@username}")
        return nil
      end

      metadata = payload['listens'].first['track_metadata']
      Overhear.logger.debug('Found currently playing track metadata')

      song = Song.from_track_metadata(metadata)
      Overhear.logger.info("Currently playing: #{song.name} by #{song.artist_names.join(', ')}")
      song
    end
  end
end
