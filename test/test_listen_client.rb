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

  def test_submit_listens_single
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

    assert_equal 'ok', result['status'], 'Expected submit_listens to return parsed response with status ok'
  end

  def test_submit_listens_playing_now
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

    assert_equal 'ok', result['status'], 'Expected submit_listens to return parsed response with status ok'
  end

  def test_submit_listens_import
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

    assert_equal 'ok', result['status'], 'Expected submit_listens to return parsed response with status ok'
  end

  def test_submit_listens_failure
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
    assert_raises(StandardError) do
      client.submit_listens('single', [listen])
    end
  end

  def test_submit_listens_invalid_type
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create a client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test with invalid listen_type
    assert_raises(ArgumentError) do
      client.submit_listens('invalid_type', [{ track_metadata: { artist_name: 'Test', track_name: 'Test' } }])
    end
  end

  def test_submit_listens_empty_listens
    # Mock the token validation request
    stub_token_validation('valid_token')

    # Create a client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test with empty listens array
    assert_raises(ArgumentError) do
      client.submit_listens('single', [])
    end
  end

  def test_submit_listens_playing_now_with_timestamp
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

  def test_latest_import_get_default_user
    stub_token_validation('valid_token')
    stub_latest_import_get('valid_token', username: 'test_user', latest_import: 12_345)

    client = Overhear::ListenClient.new('valid_token')

    assert_equal 12_345, client.latest_import
  end

  def test_update_latest_import_post
    stub_token_validation('valid_token')
    timestamp = 1_700_000_000
    stub_latest_import_post('valid_token', timestamp: timestamp, status: 200)

    client = Overhear::ListenClient.new('valid_token')

    assert client.update_latest_import(timestamp)
  end

  def test_update_latest_import_unauthorized_raises
    stub_token_validation('valid_token')
    timestamp = 1_700_000_001
    stub_latest_import_post('valid_token', timestamp: timestamp, status: 401)

    client = Overhear::ListenClient.new('valid_token')

    assert_raises(Overhear::InvalidTokenError) { client.update_latest_import(timestamp) }
  end

  # Tests for delete-listen endpoint
  def test_delete_listen_success
    stub_token_validation('valid_token')

    listened_at = Time.now.to_i - 123
    recording_msid = 'd23f4719-9212-49f0-ad08-ddbfbfc50d6f'

    stub_delete_listen('valid_token', listened_at: listened_at, recording_msid: recording_msid)

    client = Overhear::ListenClient.new('valid_token')

    result = client.delete_listen(listened_at: listened_at, recording_msid: recording_msid)

    assert_equal 'ok', result['status'], 'Expected delete_listen to return parsed response with status ok'
  end

  def test_delete_listen_failure
    stub_token_validation('valid_token')

    listened_at = Time.now.to_i - 456
    recording_msid = 'e33f4719-9212-49f0-ad08-ddbfbfc50d6f'

    stub_delete_listen('valid_token', listened_at: listened_at, recording_msid: recording_msid, status: 400)

    client = Overhear::ListenClient.new('valid_token')

    assert_raises(StandardError) do
      client.delete_listen(listened_at: listened_at, recording_msid: recording_msid)
    end
  end

  def test_delete_listen_invalid_args
    stub_token_validation('valid_token')

    client = Overhear::ListenClient.new('valid_token')

    # Missing listened_at
    assert_raises(ArgumentError) do
      client.delete_listen(listened_at: nil, recording_msid: 'abc')
    end

    # Missing recording_msid
    assert_raises(ArgumentError) do
      client.delete_listen(listened_at: Time.now.to_i, recording_msid: nil)
    end

    # Wrong types
    assert_raises(ArgumentError) do
      client.delete_listen(listened_at: 'not-an-integer', recording_msid: 'abc')
    end
    assert_raises(ArgumentError) do
      client.delete_listen(listened_at: Time.now.to_i, recording_msid: '')
    end
  end
end
