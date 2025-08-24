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
    stub_listen_count('valid_token')

    # Create a real client instance
    client = Overhear::ListenClient.new('valid_token')

    # Test the listen_count method
    assert_equal 42, client.listen_count
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
