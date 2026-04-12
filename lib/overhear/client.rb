# frozen_string_literal: true

module Overhear
  # Top-level entry point for the Overhear gem.
  # Validates the user token once on initialisation and exposes lazily-initialised
  # service objects for each API group.
  #
  # @example
  #   client = Overhear::Client.new('your_listenbrainz_token')
  #   client.listens.listen_count
  #   client.user.now_playing
  #
  # @since 0.1.0
  class Client
    # @return [String] the authenticated user's ListenBrainz username
    attr_reader :username

    # @return [String] the ListenBrainz user token
    attr_reader :token

    # Creates a new Client, validating the token against the ListenBrainz API
    # @param token [String] the ListenBrainz user token
    # @raise [InvalidTokenError] if the token is invalid
    def initialize(token)
      Overhear.logger.info('Initializing Overhear::Client')
      @token = token
      @http = HttpConnection.new(token)

      result = validate_token
      raise InvalidTokenError unless result['valid']

      @username = result['user_name']
      Overhear.logger.info("Overhear::Client initialized for user: #{@username}")
    end

    # Returns the listens service, lazily initialised
    # @return [Overhear::ListensService]
    def listens
      @listens ||= ListensService.new(@http, @username)
    end

    # Returns the user service, lazily initialised
    # @return [Overhear::UserService]
    def user
      @user ||= UserService.new(@http, @username)
    end

    private

    # Validates the token against /1/validate-token
    # @return [Hash] parsed response
    def validate_token
      response = @http.get('/1/validate-token', @http.default_headers)
      @http.parse_response(response)
    end
  end
end
