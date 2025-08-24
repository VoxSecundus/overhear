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

# Simple Response class for testing
class Response
  attr_reader :body

  def initialize(body)
    @body = body
  end
end
