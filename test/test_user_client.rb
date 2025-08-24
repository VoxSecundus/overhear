# frozen_string_literal: true

require 'test_helper'

class TestUserClient < Minitest::Test
  # Define a Response struct to replace OpenStruct
  Response = Struct.new(:body)
  def test_invalid_token_raises_error
    assert_raises(Overhear::InvalidTokenError) do
      Overhear::UserClient.new('invalid_token')
    end
  end

  def test_listens_method
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

    # Test with no parameters
    result = client.listens
    assert_instance_of Array, result
    assert_instance_of Overhear::Song, result.first if result.any?

    # Test with max_ts parameter
    result = client.listens(max_ts: 1_596_234_567)
    assert_instance_of Array, result

    # Test with min_ts parameter
    result = client.listens(min_ts: 1_596_234_567)
    assert_instance_of Array, result

    # Test with count parameter
    result = client.listens(count: 10)
    assert_instance_of Array, result

    # Test that it raises an error when both max_ts and min_ts are provided
    assert_raises(ArgumentError) do
      client.listens(max_ts: 1_596_234_567, min_ts: 1_596_234_567)
    end
  end
end
