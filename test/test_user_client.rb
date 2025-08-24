# frozen_string_literal: true

require 'test_helper'

class TestUserClient < Minitest::Test
  def test_invalid_token_raises_error
    assert_raises(Overhear::InvalidTokenError) do
      Overhear::UserClient.new('invalid_token')
    end
  end

  def test_now_playing_method
    # Skip the actual initialisation and token validation
    # by creating a mock class that inherits from UserClient
    mock_client_class = Class.new(Overhear::UserClient) do
      # Override initialize to skip token validation
      # rubocop:disable Lint/MissingSuper
      def initialize
        @username = 'test_user'
        @token = 'valid_token'
      end
      # rubocop:enable Lint/MissingSuper

      # Mock the get method
      def get(_endpoint, _headers, _params = {})
        # Return a mock response object with a body method
        Response.new(
          {
            payload: {
              count: 1,
              listens: [
                {
                  listened_at: Time.now.to_i,
                  track_metadata: {
                    track_name: 'Test Track',
                    release_name: 'Test Album',
                    additional_info: {
                      artist_names: ['Test Artist'],
                      isrc: 'USRC12345678',
                      duration_ms: 240_000
                    }
                  }
                }
              ]
            }
          }.to_json
        )
      end
    end

    # Create an instance of our mock class
    client = mock_client_class.new

    # Test now_playing method
    result = client.now_playing

    assert_instance_of Overhear::Song, result
    assert_equal 'Test Track', result.name
    assert_equal ['Test Artist'], result.artist_names
    assert_equal 'Test Album', result.release_name
  end
end
