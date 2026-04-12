# frozen_string_literal: true

require 'test_helper'

class TestUserService < Minitest::Test
  TOKEN = 'valid_token'
  USERNAME = 'test_user'

  def setup
    @http = Overhear::HttpConnection.new(TOKEN)
    @service = Overhear::UserService.new(@http, USERNAME)
  end

  def test_now_playing_returns_song
    stub_now_playing(TOKEN, username: USERNAME)
    result = @service.now_playing

    assert_instance_of Overhear::Song, result
    assert_equal 'Test Track', result.name
    assert_equal ['Test Artist'], result.artist_names
    assert_equal 'Test Album', result.release_name
  end

  def test_now_playing_returns_nil_when_nothing_playing
    stub_now_playing(TOKEN, username: USERNAME, response_body: {
      payload: { count: 0, listens: [] }
    }.to_json)

    assert_nil @service.now_playing
  end
end
