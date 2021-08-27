require 'faraday'
require 'json'

module Overhear
  class Client
    API_ROOT = 'https://api.listenbrainz.org'

    def initialize(user_token = nil)
      @user_token = user_token
      @headers = {
        'Authorization' => "Token #{@user_token}"
      }

      token_validation = validate_user_token
      if !token_validation['valid']
        raise InvalidTokenError
      end

      @username = token_validation['user_name']
    end

    def user_token_valid?
      validate_user_token['valid']
    end

    private

    def validate_user_token
      response = Faraday.get(API_ROOT + '/1/validate-token') do |req|
        req.headers = @headers
      end

      return JSON.parse(response.body)
    end
  end
end
