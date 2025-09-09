# frozen_string_literal: true

require 'test_helper'

class TestListenClient < Minitest::Test
  def test_invalid_token_raises_error
    # Mock the invalid token response
    stub_token_validation('invalid_token', valid: false)

    assert_raises(Overhear::InvalidTokenError) do
      Overhear::ListenClient.new('invalid_token')
    end
  end

  def test_listen_count
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Mock the listen count API request
    stub_listen_count('valid_token')

    # Create a real client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test the listen_count method
    assert_equal 42, client.listen_count
  end

  def test_submit_listens_predicate_single
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create a listen payload
    listen = {
      listened_at: Time.now.to_i,
      track_metadata: {
        artist_name: 'Test Artist',
        track_name: 'Test Track',
        release_name: 'Test Album'
      }
    }

    # Mock the submit-listens API request
    stub_submit_listens('valid_token', listen_type: 'single', listens: [listen])

    # Create a client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test the submit_listens method
    result = client.submit_listens('single', [listen])

    assert result, 'Expected submit_listens to return true'
  end

  def test_submit_listens_predicate_playing_now
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create a playing_now listen payload (without timestamp)
    listen = {
      track_metadata: {
        artist_name: 'Test Artist',
        track_name: 'Test Track',
        release_name: 'Test Album'
      }
    }

    # Mock the submit-listens API request
    stub_submit_listens('valid_token', listen_type: 'playing_now', listens: [listen])

    # Create a client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test the submit_listens method
    result = client.submit_listens('playing_now', [listen])

    assert result, 'Expected submit_listens to return true'
  end

  def test_submit_listens_predicate_import
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create multiple listen payloads
    listens = [
      {
        listened_at: Time.now.to_i - 3600,
        track_metadata: {
          artist_name: 'Test Artist 1',
          track_name: 'Test Track 1',
          release_name: 'Test Album 1'
        }
      },
      {
        listened_at: Time.now.to_i - 7200,
        track_metadata: {
          artist_name: 'Test Artist 2',
          track_name: 'Test Track 2',
          release_name: 'Test Album 2'
        }
      }
    ]

    # Mock the submit-listens API request
    stub_submit_listens('valid_token', listen_type: 'import', listens: listens)

    # Create a client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test the submit_listens method
    result = client.submit_listens('import', listens)

    assert result, 'Expected submit_listens to return true'
  end

  def test_submit_listens_predicate_failure
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create a listen payload
    listen = {
      listened_at: Time.now.to_i,
      track_metadata: {
        artist_name: 'Test Artist',
        track_name: 'Test Track',
        release_name: 'Test Album'
      }
    }

    # Mock the submit-listens API request with a failure status
    stub_submit_listens('valid_token', listen_type: 'single', listens: [listen], status: 400)

    # Create a client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test the submit_listens method
    result = client.submit_listens('single', [listen])

    refute result, 'Expected submit_listens to return false'
  end

  def test_submit_listens_predicate_invalid_type
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create a client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test with invalid listen_type
    assert_raises(ArgumentError) do
      client.submit_listens('invalid_type', [{ track_metadata: { artist_name: 'Test', track_name: 'Test' } }])
    end
  end

  def test_submit_listens_predicate_empty_listens
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create a client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test with empty listens array
    assert_raises(ArgumentError) do
      client.submit_listens('single', [])
    end
  end

  def test_submit_listens_predicate_playing_now_with_timestamp
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create a client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test playing_now with timestamp (should raise error)
    assert_raises(ArgumentError) do
      client.submit_listens('playing_now', [{
                              listened_at: Time.now.to_i,
                              track_metadata: {
                                artist_name: 'Test Artist',
                                track_name: 'Test Track'
                              }
                            }])
    end
  end

  def test_listens
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Use the standard response body for listens from the helper

    # Mock the listens API requests with different parameters
    stub_listens('valid_token')
    stub_listens('valid_token', query_params: { 'max_ts' => '1596234567' })
    stub_listens('valid_token', query_params: { 'min_ts' => '1596234567' })
    stub_listens('valid_token', query_params: { 'count' => '10' })

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
