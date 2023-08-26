# frozen_string_literal: true

module Overhear
  class UserClient < Client
    def initialize(token:)
      @user_token = token

      token_validation = validate_user_token
      raise InvalidTokenError unless token_validation["valid"]

      @username = token_validation["user_name"]
    end

    def user_token_valid?
      validate_user_token["valid"]
    end

    def now_playing
      response = api_call("/1/user/#{@username}/playing-now", default_headers)
      payload = JSON.parse(response.body)["payload"]

      Song.new(payload)
    end

    def listen_count
      response = api_call("/1/user/#{@username}/listen-count", default_headers)
      payload = JSON.parse(response.body)["payload"]

      payload["count"]
    end

    private

    def default_headers
      {
        "Authorization" => "Token #{@user_token}"
      }
    end

    def validate_user_token
      response = api_call("/1/validate-token", default_headers)

      JSON.parse(response.body)
    end
  end
end
