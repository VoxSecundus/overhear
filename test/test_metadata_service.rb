# frozen_string_literal: true

require 'test_helper'

class TestMetadataService < Minitest::Test
  TOKEN = 'valid_token'
  USERNAME = 'test_user'
  RECORDING_MBID = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
  RELEASE_GROUP_MBID = 'bbbbbbbb-cccc-dddd-eeee-ffffffffffff'
  ARTIST_MBID = 'cccccccc-dddd-eeee-ffff-000000000000'
  RECORDING_MSID = 'dddddddd-eeee-ffff-0000-111111111111'

  def setup
    @http = Overhear::HttpConnection.new(TOKEN)
    @service = Overhear::MetadataService.new(@http, USERNAME)
  end

  def test_recording_returns_hash
    stub_metadata_recording(TOKEN, recording_mbids: [RECORDING_MBID], inc: 'artist')
    result = @service.recording(recording_mbids: [RECORDING_MBID], inc: 'artist')

    assert_instance_of Hash, result
    assert result.key?(RECORDING_MBID)
  end

  def test_recording_multiple_mbids
    mbids = [RECORDING_MBID, 'ffffffff-eeee-dddd-cccc-bbbbbbbbbbbb']
    stub_metadata_recording(TOKEN, recording_mbids: mbids, inc: 'artist tag')
    result = @service.recording(recording_mbids: mbids, inc: 'artist tag')

    assert_instance_of Hash, result
  end

  def test_release_group_returns_hash
    stub_metadata_release_group(TOKEN, release_group_mbids: [RELEASE_GROUP_MBID], inc: 'artist')
    result = @service.release_group(release_group_mbids: [RELEASE_GROUP_MBID], inc: 'artist')

    assert_instance_of Hash, result
    assert result.key?(RELEASE_GROUP_MBID)
  end

  def test_lookup_returns_hash
    stub_metadata_lookup(TOKEN, artist_name: 'Test Artist', recording_name: 'Test Track', inc: 'artist')
    result = @service.lookup(artist_name: 'Test Artist', recording_name: 'Test Track', inc: 'artist')

    assert_instance_of Hash, result
    assert_equal 'Test Artist', result['artist_credit_name']
    assert_equal 'Test Track', result['recording_name']
  end

  def test_lookup_with_release_name
    stub_metadata_lookup(TOKEN, artist_name: 'Test Artist', recording_name: 'Test Track',
                                inc: 'artist', release_name: 'Test Album')
    result = @service.lookup(artist_name: 'Test Artist', recording_name: 'Test Track',
                             inc: 'artist', release_name: 'Test Album')

    assert_instance_of Hash, result
  end

  def test_lookup_with_metadata_flag
    stub_metadata_lookup(TOKEN, artist_name: 'Test Artist', recording_name: 'Test Track',
                                inc: 'artist', metadata: true)
    result = @service.lookup(artist_name: 'Test Artist', recording_name: 'Test Track',
                             inc: 'artist', metadata: true)

    assert_instance_of Hash, result
  end

  def test_artist_returns_array
    stub_metadata_artist(TOKEN, artist_mbids: [ARTIST_MBID], inc: 'tag')
    result = @service.artist(artist_mbids: [ARTIST_MBID], inc: 'tag')

    assert_instance_of Array, result
    assert_equal ARTIST_MBID, result.first['artist_mbid']
  end

  def test_submit_manual_mapping_returns_ok
    stub_submit_manual_mapping(TOKEN, recording_mbid: RECORDING_MBID, recording_msid: RECORDING_MSID)
    result = @service.submit_manual_mapping(recording_mbid: RECORDING_MBID, recording_msid: RECORDING_MSID)

    assert_equal 'ok', result['status']
  end

  def test_submit_manual_mapping_raises_on_unauthorized
    stub_submit_manual_mapping(TOKEN, recording_mbid: RECORDING_MBID, recording_msid: RECORDING_MSID, status: 401)
    assert_raises(Overhear::InvalidTokenError) do
      @service.submit_manual_mapping(recording_mbid: RECORDING_MBID, recording_msid: RECORDING_MSID)
    end
  end

  def test_submit_manual_mapping_raises_on_error
    stub_submit_manual_mapping(TOKEN, recording_mbid: RECORDING_MBID, recording_msid: RECORDING_MSID, status: 400)
    assert_raises(StandardError) do
      @service.submit_manual_mapping(recording_mbid: RECORDING_MBID, recording_msid: RECORDING_MSID)
    end
  end

  def test_get_manual_mapping_returns_hash
    stub_get_manual_mapping(TOKEN, recording_msid: RECORDING_MSID)
    result = @service.get_manual_mapping(recording_msid: RECORDING_MSID)

    assert_instance_of Hash, result
    assert_equal 'ok', result['status']
    assert_equal RECORDING_MSID, result.dig('mapping', 'recording_msid')
  end

  def test_get_manual_mapping_raises_on_unauthorized
    stub_get_manual_mapping(TOKEN, recording_msid: RECORDING_MSID, status: 401)
    assert_raises(Overhear::InvalidTokenError) do
      @service.get_manual_mapping(recording_msid: RECORDING_MSID)
    end
  end

  def test_get_manual_mapping_raises_on_not_found
    stub_get_manual_mapping(TOKEN, recording_msid: RECORDING_MSID, status: 404)
    assert_raises(StandardError) do
      @service.get_manual_mapping(recording_msid: RECORDING_MSID)
    end
  end
end
