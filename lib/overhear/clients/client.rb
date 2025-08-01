# frozen_string_literal: true

require 'faraday'
require 'json'

module Overhear
  # Abstract base class for all API client implementations
  # @abstract Subclass and override methods to implement different API endpoints
  # @since 0.1.0
  class Client
    # Base URL for the ListenBrainz API
    # @return [String] the API root URL, defaults to 'https://api.listenbrainz.org'
    API_ROOT = ENV['overhear_API_ROOT'] || 'https://api.listenbrainz.org'

    private

    # Makes an HTTP GET request to the ListenBrainz API
    # @param endpoint [String] the API endpoint to call
    # @param headers [Hash] HTTP headers to include in the request
    # @return [Faraday::Response] the HTTP response
    # @api private
    def api_call(endpoint, headers)
      url = API_ROOT + endpoint
      Overhear.logger.info("Making API request to: #{url}")
      Overhear.logger.debug("Request headers: #{headers.reject { |k, _| k == 'Authorization' }}")
      
      response = Faraday.get(url) do |req|
        req.headers = headers
      end
      
      Overhear.logger.info("Response status: #{response.status}")
      Overhear.logger.trace("Response headers: #{response.headers}")
      
      response
    end
  end
end
