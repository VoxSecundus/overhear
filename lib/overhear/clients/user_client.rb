# frozen_string_literal: true

module Overhear
  # Client class for user-specific ListenBrainz API actions
  # @since 0.1.0
  class UserClient < Client
    # Creates a new UserClient instance
    # @param token [String] the ListenBrainz user token
    # @raise [InvalidTokenError] if the token is invalid
    # @return [UserClient] a new instance of UserClient
    # @example
    #   client = Overhear::UserClient.new('your_listenbrainz_token')
    def initialize(token)
      super()
      Overhear.logger.info("Initializing UserClient")
      @user_token = token

      Overhear.logger.debug("Validating user token")
      token_validation = validate_user_token
      
      unless token_validation['valid']
        Overhear.logger.error("Invalid token provided")
        raise InvalidTokenError
      end

      @username = token_validation['user_name']
      Overhear.logger.info("UserClient initialized for user: #{@username}")
    end

    # @return [String] the ListenBrainz username associated with the token
    attr_reader :username

    # @return [String] the ListenBrainz user token
    attr_reader :user_token

    # Gets the user's currently playing track
    # @return [Song, nil] the currently playing song or nil if nothing is playing
    # @example
    #   song = client.now_playing
    #   puts "Now playing: #{song.name}" if song
    def now_playing
      Overhear.logger.info("Fetching currently playing track for user: #{@username}")
      response = api_call("/1/user/#{@username}/playing-now", default_headers)
      payload = parse_response(response)['payload']

      if payload['count'].zero?
        Overhear.logger.info("No track currently playing for user: #{@username}")
        return nil
      end

      metadata = payload['listens'].first['track_metadata']
      Overhear.logger.debug("Found currently playing track metadata")
      
      song = Song.from_track_metadata(metadata)
      Overhear.logger.info("Currently playing: #{song.name} by #{song.artist_names.join(', ')}")
      song
    end

    # Gets the total number of listens for the user
    # @return [Integer] the total number of listens
    # @example
    #   count = client.listen_count
    #   puts "Total listens: #{count}"
    def listen_count
      Overhear.logger.info("Fetching listen count for user: #{@username}")
      response = api_call("/1/user/#{@username}/listen-count", default_headers)
      payload = parse_response(response)['payload']

      count = payload['count']
      Overhear.logger.info("Total listen count for #{@username}: #{count}")
      count
    end

    private

    # Checks if the user token is valid
    # @return [Boolean] true if the token is valid, false otherwise
    # @api private
    def user_token_valid?
      validate_user_token['valid']
    end

    # Parses the API response and logs debug information if enabled
    # @param response [Faraday::Response] the API response
    # @return [Hash] the parsed JSON response
    # @api private
    def parse_response(response)
      JSON.parse(response.body).tap do |resp|
        Overhear.logger.log_json(:DEBUG, resp)
      end
    end

    # Generates the default headers for API requests
    # @return [Hash] the headers hash with authorization token
    # @api private
    def default_headers
      {
        'Authorization' => "Token #{@user_token}"
      }
    end

    # Validates the user token with the ListenBrainz API
    # @return [Hash] the validation response
    # @api private
    def validate_user_token
      response = api_call('/1/validate-token', default_headers)

      parse_response(response)
    end
  end
end
