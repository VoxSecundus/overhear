# frozen_string_literal: true

require "faraday"
require "json"

module Overhear
  class Client
    API_ROOT = "https://api.listenbrainz.org"

    private

    def api_call(endpoint, headers)
      Faraday.get(API_ROOT + endpoint) do |req|
        req.headers = headers
      end
    end
  end
end
