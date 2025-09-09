# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'overhear'

require 'minitest/autorun'
require 'webmock/minitest'

# Configure WebMock to disable all real HTTP connections
# This ensures that all HTTP requests in tests must be explicitly stubbed
WebMock.disable_net_connect!

# Helper method to stub token validation requests
# @param token [String] the token to validate
# @param valid [Boolean] whether the token is valid
# @param username [String] the username to return if valid
# @return [WebMock::StubRegistry::Stub] the created stub
def stub_token_validation(token, valid: true, username: 'test_user')
  stub_request(:get, "#{Overhear::Client::API_ROOT}/1/validate-token")
    .with(
      headers: {
        'Authorization' => "Token #{token}"
      }
    )
    .to_return(
      status: valid ? 200 : 401,
      body: valid ? { 'valid' => true, 'user_name' => username }.to_json : { 'valid' => false }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
end

# Helper method to stub invalid token responses
# @param token [String] the invalid token
# @return [WebMock::StubRegistry::Stub] the created stub
def stub_invalid_token(token)
  stub_token_validation(token, valid: false)
end

# Helper method to create standard authorization headers
# @param token [String] the token to use for authorization
# @return [Hash] headers hash with Authorization
def auth_headers(token)
  {
    'Authorization' => "Token #{token}"
  }
end

# Helper to stub GET /1/latest-import
# @param token [String]
# @param username [String]
# @param latest_import [Integer]
# @return [WebMock::StubRegistry::Stub]
def stub_latest_import_get(token, username: 'test_user', latest_import: 0)
  stub_request(:get, "#{Overhear::Client::API_ROOT}/1/latest-import")
    .with(headers: auth_headers(token), query: { 'user_name' => username })
    .to_return(
      status: 200,
      body: {
        musicbrainz_id: username,
        latest_import: latest_import
      }.to_json,
      headers: json_headers
    )
end

# Helper to stub POST /1/latest-import
# @param token [String]
# @param timestamp [Integer]
# @param status [Integer]
# @return [WebMock::StubRegistry::Stub]
def stub_latest_import_post(token, timestamp:, status: 200)
  stub_request(:post, "#{Overhear::Client::API_ROOT}/1/latest-import")
    .with(
      headers: auth_headers(token).merge('Content-Type' => 'application/json'),
      body: { ts: timestamp }.to_json
    )
    .to_return(
      status: status,
      body: (status == 200 ? { status: 'ok' } : { status: 'error' }).to_json,
      headers: json_headers
    )
end

# Helper method to create standard JSON response headers
# @return [Hash] headers hash with Content-Type
def json_headers
  { 'Content-Type' => 'application/json' }
end

# Helper method to stub listen count API request
# @param token [String] the token to use for authorization
# @param username [String] the username to get listen count for
# @param count [Integer] the count to return in the response
# @return [WebMock::StubRegistry::Stub] the created stub
def stub_listen_count(token, username: 'test_user', count: 42)
  stub_request(:get, "#{Overhear::Client::API_ROOT}/1/user/#{username}/listen-count")
    .with(headers: auth_headers(token))
    .to_return(
      status: 200,
      body: {
        payload: {
          count: count
        }
      }.to_json,
      headers: json_headers
    )
end

# Helper method to create a standard listen response body
# @param track_name [String] the name of the track
# @param artist_names [Array<String>] the names of the artists
# @param release_name [String] the name of the release/album
# @param isrc [String] the ISRC code
# @param duration_ms [Integer] the duration in milliseconds
# @return [String] JSON string of the response body
def listen_response_body(track_name: 'Test Track', artist_names: ['Test Artist'],
                         release_name: 'Test Album', isrc: 'USRC12345678', duration_ms: 240_000)
  {
    payload: {
      count: 1,
      listens: [
        {
          listened_at: Time.now.to_i,
          track_metadata: {
            track_name: track_name,
            release_name: release_name,
            additional_info: {
              artist_names: artist_names,
              isrc: isrc,
              duration_ms: duration_ms
            }
          }
        }
      ]
    }
  }.to_json
end

# Helper method to stub listens API request
# @param token [String] the token to use for authorization
# @param username [String] the username to get listens for
# @param query_params [Hash] optional query parameters
# @param response_body [String] optional custom response body
# @return [WebMock::StubRegistry::Stub] the created stub
def stub_listens(token, username: 'test_user', query_params: {}, response_body: nil)
  request = stub_request(:get, "#{Overhear::Client::API_ROOT}/1/user/#{username}/listens")
            .with(headers: auth_headers(token))

  # Add query parameters if provided
  request = request.with(query: query_params) unless query_params.empty?

  # Return the response
  request.to_return(
    status: 200,
    body: response_body || listen_response_body,
    headers: json_headers
  )
end

# Helper method to stub now playing API request
# @param token [String] the token to use for authorization
# @param username [String] the username to get now playing for
# @param response_body [String] optional custom response body
# @return [WebMock::StubRegistry::Stub] the created stub
def stub_now_playing(token, username: 'test_user', response_body: nil)
  stub_request(:get, "#{Overhear::Client::API_ROOT}/1/user/#{username}/playing-now")
    .with(headers: auth_headers(token))
    .to_return(
      status: 200,
      body: response_body || listen_response_body,
      headers: json_headers
    )
end

# Helper method to stub submit-listens API request
# @param token [String] the token to use for authorization
# @param listen_type [String] the type of listen submission ('single', 'playing_now', or 'import')
# @param listens [Array<Hash>] array of listen data being submitted
# @param status [Integer] the HTTP status code to return
# @return [WebMock::StubRegistry::Stub] the created stub
def stub_submit_listens(token, listen_type: 'single', listens: [], status: 200)
  expected_body = {
    listen_type: listen_type,
    payload: listens
  }

  stub_request(:post, "#{Overhear::Client::API_ROOT}/1/submit-listens")
    .with(
      headers: auth_headers(token).merge('Content-Type' => 'application/json'),
      body: expected_body.to_json
    )
    .to_return(
      status: status,
      body: { status: status == 200 ? 'ok' : 'error' }.to_json,
      headers: json_headers
    )
end

# Helper method to stub delete-listen API request
# @param token [String] the token to use for authorisation
# @param listened_at [Integer] the UNIX timestamp of the listen to delete
# @param recording_msid [String] the recording MSID of the listen to delete
# @param status [Integer] the HTTP status code to return
# @return [WebMock::StubRegistry::Stub] the created stub
def stub_delete_listen(token, listened_at:, recording_msid:, status: 200)
  expected_body = {
    listened_at: listened_at,
    recording_msid: recording_msid
  }

  stub_request(:post, "#{Overhear::Client::API_ROOT}/1/delete-listen")
    .with(
      headers: auth_headers(token).merge('Content-Type' => 'application/json'),
      body: expected_body.to_json
    )
    .to_return(
      status: status,
      body: { status: status == 200 ? 'ok' : 'error' }.to_json,
      headers: json_headers
    )
end

# Simple Response class for testing
class Response
  attr_reader :body

  def initialize(body)
    @body = body
  end
end
