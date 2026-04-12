# frozen_string_literal: true

require 'test_helper'

class TestHttpConnection < Minitest::Test
  TOKEN = 'test_token'

  def setup
    @http = Overhear::HttpConnection.new(TOKEN)
  end

  def test_api_root_constant_exists
    assert_equal 'https://api.listenbrainz.org', Overhear::HttpConnection::API_ROOT
  end

  def test_default_headers_returns_authorization_header
    expected = { 'Authorization' => "Token #{TOKEN}" }

    assert_equal expected, @http.default_headers
  end

  def test_parse_response_returns_parsed_json
    body = { 'foo' => 'bar', 'count' => 42 }.to_json
    response = Response.new(body)
    result = @http.parse_response(response)

    assert_equal({ 'foo' => 'bar', 'count' => 42 }, result)
  end

  def test_get_makes_http_request_and_returns_response
    stub_request(:get, "#{Overhear::HttpConnection::API_ROOT}/1/some-endpoint")
      .with(headers: @http.default_headers)
      .to_return(status: 200, body: { 'ok' => true }.to_json, headers: json_headers)

    response = @http.get('/1/some-endpoint', @http.default_headers)

    assert_equal 200, response.status
  end

  def test_get_passes_query_params
    stub_request(:get, "#{Overhear::HttpConnection::API_ROOT}/1/some-endpoint")
      .with(headers: @http.default_headers, query: { 'foo' => 'bar' })
      .to_return(status: 200, body: {}.to_json, headers: json_headers)

    response = @http.get('/1/some-endpoint', @http.default_headers, { foo: 'bar' })

    assert_equal 200, response.status
  end

  def test_post_makes_http_request_and_returns_response
    body = { 'key' => 'value' }
    stub_request(:post, "#{Overhear::HttpConnection::API_ROOT}/1/some-endpoint")
      .with(
        headers: @http.default_headers.merge('Content-Type' => 'application/json'),
        body: body.to_json
      )
      .to_return(status: 200, body: { 'status' => 'ok' }.to_json, headers: json_headers)

    response = @http.post('/1/some-endpoint', @http.default_headers, body)

    assert_equal 200, response.status
  end
end
