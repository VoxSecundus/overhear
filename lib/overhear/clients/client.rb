# frozen_string_literal: true

require 'faraday'
require 'json'

module Overhear
  # Abstract class for all client subclasses
  class Client
    API_ROOT = ENV['overhear_API_ROOT'] || 'https://api.listenbrainz.org'

    private

    def api_call(endpoint, headers)
      Faraday.get(API_ROOT + endpoint) do |req|
        req.headers = headers
      end
    end
  end
end
