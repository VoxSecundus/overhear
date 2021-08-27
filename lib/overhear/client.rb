require 'faraday'
require 'json'

module Overhear
  class Client
    API_ROOT = 'https://api.listenbrainz.org'

    def initialize(user_token = nil)
      @user_token = user_token

      token_validation = validate_user_token
      if !token_validation['valid']
        raise InvalidTokenError
      end

      @username = token_validation['user_name']
    end

    def user_token_valid?
      validate_user_token['valid']
    end

    def now_playing
      response = api_call("/1/user/#{@username}/playing-now", default_headers)
      payload = JSON.parse(response.body)['payload']

      return Song.new(payload)
    end

    private

    def default_headers
      {
        'Authorization' => "Token #{@user_token}"
      }
    end

    def validate_user_token
      response = api_call('/1/validate-token', default_headers)

      return JSON.parse(response.body)
    end

    def api_call(endpoint, headers)
      response = Faraday.get(API_ROOT + endpoint) do |req|
        req.headers = headers
      end

      return response
    end
  end
end
