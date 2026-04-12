# frozen_string_literal: true

require 'test_helper'

class TestListensService < Minitest::Test
  TOKEN = 'valid_token'
  USERNAME = 'test_user'

  def setup
    @http = Overhear::HttpConnection.new(TOKEN)
    @service = Overhear::ListensService.new(@http, USERNAME)
  end

  def test_listen_count
    stub_listen_count(TOKEN, username: USERNAME)

    assert_equal 42, @service.listen_count
  end

  def test_submit_listens_single
    listen = {
      listened_at: Time.now.to_i,
      track_metadata: { artist_name: 'Test Artist', track_name: 'Test Track', release_name: 'Test Album' }
    }
    stub_submit_listens(TOKEN, listen_type: 'single', listens: [listen])
    result = @service.submit_listens('single', [listen])

    assert_equal 'ok', result['status']
  end

  def test_submit_listens_playing_now
    listen = {
      track_metadata: { artist_name: 'Test Artist', track_name: 'Test Track', release_name: 'Test Album' }
    }
    stub_submit_listens(TOKEN, listen_type: 'playing_now', listens: [listen])
    result = @service.submit_listens('playing_now', [listen])

    assert_equal 'ok', result['status']
  end

  def test_submit_listens_import
    listens = [
      { listened_at: Time.now.to_i - 3600,
        track_metadata: { artist_name: 'Test Artist 1', track_name: 'Test Track 1', release_name: 'Test Album 1' } },
      { listened_at: Time.now.to_i - 7200,
        track_metadata: { artist_name: 'Test Artist 2', track_name: 'Test Track 2', release_name: 'Test Album 2' } }
    ]
    stub_submit_listens(TOKEN, listen_type: 'import', listens: listens)
    result = @service.submit_listens('import', listens)

    assert_equal 'ok', result['status']
  end

  def test_submit_listens_failure
    listen = {
      listened_at: Time.now.to_i,
      track_metadata: { artist_name: 'Test Artist', track_name: 'Test Track', release_name: 'Test Album' }
    }
    stub_submit_listens(TOKEN, listen_type: 'single', listens: [listen], status: 400)
    assert_raises(StandardError) { @service.submit_listens('single', [listen]) }
  end

  def test_submit_listens_invalid_type
    assert_raises(ArgumentError) do
      @service.submit_listens('invalid_type', [{ track_metadata: { artist_name: 'Test', track_name: 'Test' } }])
    end
  end

  def test_submit_listens_empty_listens
    assert_raises(ArgumentError) { @service.submit_listens('single', []) }
  end

  def test_submit_listens_playing_now_with_timestamp
    assert_raises(ArgumentError) do
      @service.submit_listens('playing_now', [{
                                listened_at: Time.now.to_i,
                                track_metadata: { artist_name: 'Test Artist', track_name: 'Test Track' }
                              }])
    end
  end

  def test_listens_no_params
    stub_listens(TOKEN, username: USERNAME)
    result = @service.listens

    assert_instance_of Array, result
    assert_instance_of Overhear::Song, result.first if result.any?
  end

  def test_listens_with_max_ts
    stub_listens(TOKEN, username: USERNAME, query_params: { 'max_ts' => '1596234567' })

    assert_instance_of Array, @service.listens(max_ts: 1_596_234_567)
  end

  def test_listens_with_min_ts
    stub_listens(TOKEN, username: USERNAME, query_params: { 'min_ts' => '1596234567' })

    assert_instance_of Array, @service.listens(min_ts: 1_596_234_567)
  end

  def test_listens_with_count
    stub_listens(TOKEN, username: USERNAME, query_params: { 'count' => '10' })

    assert_instance_of Array, @service.listens(count: 10)
  end

  def test_listens_raises_on_both_ts_params
    assert_raises(ArgumentError) { @service.listens(max_ts: 1_596_234_567, min_ts: 1_596_234_567) }
  end

  def test_latest_import_default_user
    stub_latest_import_get(TOKEN, username: USERNAME, latest_import: 12_345)

    assert_equal 12_345, @service.latest_import
  end

  def test_update_latest_import
    timestamp = 1_700_000_000
    stub_latest_import_post(TOKEN, timestamp: timestamp, status: 200)

    assert @service.update_latest_import(timestamp)
  end

  def test_update_latest_import_unauthorized_raises
    timestamp = 1_700_000_001
    stub_latest_import_post(TOKEN, timestamp: timestamp, status: 401)
    assert_raises(Overhear::InvalidTokenError) { @service.update_latest_import(timestamp) }
  end

  def test_delete_listen_success
    listened_at = Time.now.to_i - 123
    recording_msid = 'd23f4719-9212-49f0-ad08-ddbfbfc50d6f'
    stub_delete_listen(TOKEN, listened_at: listened_at, recording_msid: recording_msid)
    result = @service.delete_listen(listened_at: listened_at, recording_msid: recording_msid)

    assert_equal 'ok', result['status']
  end

  def test_delete_listen_failure
    listened_at = Time.now.to_i - 456
    recording_msid = 'e33f4719-9212-49f0-ad08-ddbfbfc50d6f'
    stub_delete_listen(TOKEN, listened_at: listened_at, recording_msid: recording_msid, status: 400)
    assert_raises(StandardError) do
      @service.delete_listen(listened_at: listened_at, recording_msid: recording_msid)
    end
  end

  def test_delete_listen_invalid_args
    assert_raises(ArgumentError) { @service.delete_listen(listened_at: nil, recording_msid: 'abc') }
    assert_raises(ArgumentError) { @service.delete_listen(listened_at: Time.now.to_i, recording_msid: nil) }
    assert_raises(ArgumentError) { @service.delete_listen(listened_at: 'not-an-integer', recording_msid: 'abc') }
    assert_raises(ArgumentError) { @service.delete_listen(listened_at: Time.now.to_i, recording_msid: '') }
  end
end
