# frozen_string_literal: true

require 'faraday'
require 'json'

module Overhear
  # Wraps Faraday HTTP primitives and authentication headers for the ListenBrainz API.
  # Injected into service objects rather than inherited from.
  # @since 0.1.0
  class HttpConnection
    # Base URL for the ListenBrainz API
    # @return [String] the API root URL, defaults to 'https://api.listenbrainz.org'
    API_ROOT = ENV['overhear_API_ROOT'] || 'https://api.listenbrainz.org'

    # @param token [String] the ListenBrainz user token, used to build auth headers
    def initialize(token)
      @token = token
    end

    # Returns the Authorization header for authenticated requests
    # @return [Hash{String => String}]
    def default_headers
      { 'Authorization' => "Token #{@token}" }
    end

    # Parses a Faraday response body as JSON and logs it at DEBUG level
    # @param response [Faraday::Response]
    # @return [Hash{String => untyped}]
    def parse_response(response)
      JSON.parse(response.body).tap do |resp|
        Overhear.logger.log_json(:DEBUG, resp)
      end
    end

    # Makes an HTTP GET request to the ListenBrainz API
    # @param endpoint [String] the API endpoint path
    # @param headers [Hash] HTTP headers to include
    # @param params [Hash] query parameters
    # @return [Faraday::Response]
    def get(endpoint, headers, params = {})
      url = URI.join(API_ROOT, endpoint)
      Overhear.logger.info("Making API request to: #{url}")
      Overhear.logger.debug("Request headers: #{headers.except('Authorization')}")
      Overhear.logger.debug("Request params: #{params}") unless params.empty?

      response = Faraday.get(url) do |req|
        req.headers = headers
        req.params = params unless params.empty?
      end

      Overhear.logger.info("Response status: #{response.status}")
      Overhear.logger.trace("Response headers: #{response.headers}")

      response
    end

    # Makes an HTTP POST request to the ListenBrainz API
    # @param endpoint [String] the API endpoint path
    # @param headers [Hash] HTTP headers to include
    # @param body [Hash] the request body, serialised as JSON
    # @return [Faraday::Response]
    def post(endpoint, headers, body)
      url = URI.join(API_ROOT, endpoint)
      Overhear.logger.info("Making API POST request to: #{url}")
      Overhear.logger.debug("Request headers: #{headers.except('Authorization')}")
      Overhear.logger.debug("Request body: #{body}")

      headers = headers.merge('Content-Type' => 'application/json')

      response = Faraday.post(url) do |req|
        req.headers = headers
        req.body = JSON.generate(body)
      end

      Overhear.logger.info("Response status: #{response.status}")
      Overhear.logger.trace("Response headers: #{response.headers}")

      response
    end
  end
end
