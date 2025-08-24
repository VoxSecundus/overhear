# frozen_string_literal: true

module Overhear
  # Base client class for authenticated ListenBrainz API actions
  # Handles token validation and authentication for API endpoints that require a user token
  # @abstract
  # @since 0.2.0
  class AuthenticatableClient < Client
    # @return [String] the ListenBrainz username associated with the token
    # @return [String] the ListenBrainz user token
    attr_reader :username, :token

    # Creates a new AuthenticatableClient instance
    # @param token [String] the ListenBrainz user token
    # @raise [InvalidTokenError] if the token is invalid
    # @return [AuthenticatableClient] a new instance of AuthenticatableClient
    # @example
    #   client = Overhear::AuthenticatableClient.new('your_listenbrainz_token')
    def initialize(token)
      super()
      Overhear.logger.info("Initializing #{self.class.name}")
      @token = token

      token_validation = validate_user_token
      raise InvalidTokenError unless token_validation['valid']

      Overhear.logger.info("#{self.class.name} initialized for user: #{@username}")
      @username = token_validation['user_name']
    end

    # Generates the default headers for API requests
    # @return [Hash] the headers hash with authorization token
    # @api private
    def default_headers
      {
        'Authorization' => "Token #{@token}"
      }
    end

    private

    # Validates the user's token by making an API request.
    # The method sends a request to the '/1/validate-token' endpoint with default headers
    # including the user's authentication token, and processes the server's response.
    #
    # @return [Object] the parsed response from the API
    def validate_user_token
      response = get('/1/validate-token', default_headers)
      parse_response(response)
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
  end
end
