# frozen_string_literal: true

module Overhear
  class UserClient < Client
    def initialize(token)
      super
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
      payload = parse_response(response)["payload"]

      return nil if payload["count"].zero?

      metadata = payload["listens"].first["track_metadata"]
      Song.new(
        artist_names: metadata.dig("additional_info", "artist_names"),
        name: metadata["track_name"],
        release_name: metadata["release_name"],
        isrc: metadata.dig("additional_info", "isrc"),
        duration: metadata.dig("additional_info", "duration_ms")
      )
    end

    def listen_count
      response = api_call("/1/user/#{@username}/listen-count", default_headers)
      payload = parse_response(response)["payload"]

      payload["count"]
    end

    private

    def parse_response(response)
      JSON.parse(response.body).tap do |resp|
        puts resp if ENV["overhear_DEBUG"]
      end
    end

    def default_headers
      {
        "Authorization" => "Token #{@user_token}"
      }
    end

    def validate_user_token
      response = api_call("/1/validate-token", default_headers)

      parse_response(response)
    end
  end
end
