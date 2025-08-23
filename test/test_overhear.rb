# frozen_string_literal: true

require 'test_helper'

class TestOverhear < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Overhear::VERSION
  end

  def test_logger_accessor
    # Test that the logger accessor returns a Logger instance
    assert_instance_of Overhear::Logger, Overhear.logger
  end

  def test_invalid_token_error
    # Test that InvalidTokenError can be raised with default message
    error = assert_raises(Overhear::InvalidTokenError) do
      raise Overhear::InvalidTokenError
    end
    assert_equal 'Invalid token passed', error.message

    # Test that InvalidTokenError can be raised with custom message
    custom_message = 'Custom error message'
    error = assert_raises(Overhear::InvalidTokenError) do
      raise Overhear::InvalidTokenError, custom_message
    end
    assert_equal custom_message, error.message
  end
end
