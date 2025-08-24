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
    stub_now_playing('valid_token')

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
