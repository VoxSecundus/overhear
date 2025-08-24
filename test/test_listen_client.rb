# frozen_string_literal: true

require 'test_helper'

class TestListenClient < Minitest::Test
  def test_invalid_token_raises_error
    # Mock the invalid token response
    stub_invalid_token('invalid_token')
    
    assert_raises(Overhear::InvalidTokenError) do
      Overhear::ListenClient.new('invalid_token')
    end
  end

  def test_listen_count
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Mock the listen count API request
    stub_request(:get, "#{Overhear::Client::API_ROOT}/1/user/test_user/listen-count")
      .with(
        headers: {
          'Authorization' => 'Token valid_token'
        }
      )
      .to_return(
        status: 200,
        body: {
          payload: {
            count: 42
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Create a real client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test the listen_count method
    assert_equal 42, client.listen_count
  end

  def test_listens
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create a standard response body for listens
    listen_response = {
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

    # Mock the listens API request with no parameters
    stub_request(:get, "#{Overhear::Client::API_ROOT}/1/user/test_user/listens")
      .with(
        headers: {
          'Authorization' => 'Token valid_token'
        }
      )
      .to_return(
        status: 200,
        body: listen_response,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Mock the listens API request with max_ts parameter
    stub_request(:get, "#{Overhear::Client::API_ROOT}/1/user/test_user/listens")
      .with(
        headers: {
          'Authorization' => 'Token valid_token'
        },
        query: { 'max_ts' => '1596234567' }
      )
      .to_return(
        status: 200,
        body: listen_response,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Mock the listens API request with min_ts parameter
    stub_request(:get, "#{Overhear::Client::API_ROOT}/1/user/test_user/listens")
      .with(
        headers: {
          'Authorization' => 'Token valid_token'
        },
        query: { 'min_ts' => '1596234567' }
      )
      .to_return(
        status: 200,
        body: listen_response,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Mock the listens API request with count parameter
    stub_request(:get, "#{Overhear::Client::API_ROOT}/1/user/test_user/listens")
      .with(
        headers: {
          'Authorization' => 'Token valid_token'
        },
        query: { 'count' => '10' }
      )
      .to_return(
        status: 200,
        body: listen_response,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Create a real client instance
    client = Overhear::ListenClient.new('valid_token')

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
