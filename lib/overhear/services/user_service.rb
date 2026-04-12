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

    # Searches for ListenBrainz-registered users matching a search term
    # @param search_term [String] the term to search for
    # @return [Array<String>] matched usernames
    def search_users(search_term)
      Overhear.logger.info("Searching for users matching: #{search_term}")
      response = @http.get('/1/search/users', @http.default_headers, { search_term: search_term })
      users = @http.parse_response(response)['users']
      Overhear.logger.info("Found #{users.size} matching users")
      users.map { |u| u['user_name'] }
    end

    # Gets users with similar listening taste to the authenticated user
    # @return [Array<Hash>] list of similar users, each with 'user_name' and 'similarity' keys
    def similar_users
      Overhear.logger.info("Fetching similar users for: #{@username}")
      response = @http.get("/1/user/#{@username}/similar-users", @http.default_headers)
      @http.parse_response(response)['payload']
    end

    # Gets the similarity score between the authenticated user and another user
    # @param other_username [String] the other user's username
    # @return [Hash] a hash with 'user_name' and 'similarity' keys
    def similarity_with(other_username)
      Overhear.logger.info("Fetching similarity between #{@username} and #{other_username}")
      response = @http.get("/1/user/#{@username}/similar-to/#{other_username}", @http.default_headers)
      @http.parse_response(response)['payload']
    end

    # Gets external services connected to the authenticated user's account
    # @return [Array<String>] list of connected service names
    def services
      Overhear.logger.info("Fetching connected services for: #{@username}")
      response = @http.get("/1/user/#{@username}/services", @http.default_headers)
      @http.parse_response(response)['services']
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
