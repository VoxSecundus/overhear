# frozen_string_literal: true

require 'test_helper'

class TestUserClient < Minitest::Test
  def test_invalid_token_raises_error
    # Mock the invalid token response
    stub_invalid_token('invalid_token')
    
    assert_raises(Overhear::InvalidTokenError) do
      Overhear::UserClient.new('invalid_token')
    end
  end

  def test_now_playing_method
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Mock the now_playing API request
    stub_request(:get, "#{Overhear::Client::API_ROOT}/1/user/test_user/playing-now")
      .with(
        headers: {
          'Authorization' => 'Token valid_token'
        }
      )
      .to_return(
        status: 200,
        body: {
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
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Create a real client instance
    client = Overhear::UserClient.new('valid_token')

    # Test now_playing method
    result = client.now_playing

    assert_instance_of Overhear::Song, result
    assert_equal 'Test Track', result.name
    assert_equal ['Test Artist'], result.artist_names
    assert_equal 'Test Album', result.release_name
  end
end
