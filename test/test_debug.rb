# frozen_string_literal: true

require 'test_helper'
require 'stringio'

# Tests for the debug functionality of the Overhear gem
class TestDebug < Minitest::Test
  def setup
    # Save original stdout to restore after test
    @original_stdout = $stdout
    # Create a StringIO object to capture output
    @captured_output = StringIO.new
    $stdout = @captured_output

    # Save original environment variables
    @original_debug_level = ENV.fetch('overhear_DEBUG_LEVEL', nil)
    @original_debug = ENV.fetch('overhear_DEBUG', nil)

    # Reset environment variables
    ENV.delete('overhear_DEBUG_LEVEL')
    ENV.delete('overhear_DEBUG')
  end

  def teardown
    # Restore original stdout
    $stdout = @original_stdout

    # Restore original environment variables
    ENV['overhear_DEBUG_LEVEL'] = @original_debug_level
    ENV['overhear_DEBUG'] = @original_debug
  end

  def test_default_log_level
    # Create a new logger with default settings
    logger = Overhear::Logger.new

    # Default level should be OFF
    assert_equal :OFF, logger.level

    # Test that messages are not logged at default level
    logger.error('Test error message')
    logger.info('Test info message')
    logger.debug('Test debug message')

    # No output should be captured
    assert_empty @captured_output.string
  end

  def test_error_level
    logger = Overhear::Logger.new
    logger.level = :ERROR

    # Test that only ERROR messages are logged
    logger.error('Test error message')
    logger.info('Test info message')
    logger.debug('Test debug message')

    output = @captured_output.string

    assert_includes output, '[Overhear][ERROR] Test error message'
    refute_includes output, '[Overhear][INFO] Test info message'
    refute_includes output, '[Overhear][DEBUG] Test debug message'
  end

  def test_info_level
    logger = Overhear::Logger.new
    logger.level = :INFO

    # Test that ERROR and INFO messages are logged
    logger.error('Test error message')
    logger.info('Test info message')
    logger.debug('Test debug message')

    output = @captured_output.string

    assert_includes output, '[Overhear][ERROR] Test error message'
    assert_includes output, '[Overhear][INFO] Test info message'
    refute_includes output, '[Overhear][DEBUG] Test debug message'
  end

  def test_debug_level
    logger = Overhear::Logger.new
    logger.level = :DEBUG

    # Test that ERROR, INFO, and DEBUG messages are logged
    logger.error('Test error message')
    logger.info('Test info message')
    logger.debug('Test debug message')
    logger.trace('Test trace message')

    output = @captured_output.string

    assert_includes output, '[Overhear][ERROR] Test error message'
    assert_includes output, '[Overhear][INFO] Test info message'
    assert_includes output, '[Overhear][DEBUG] Test debug message'
    refute_includes output, '[Overhear][TRACE] Test trace message'
  end

  def test_trace_level
    logger = Overhear::Logger.new
    logger.level = :TRACE

    # Test that all messages are logged
    logger.error('Test error message')
    logger.info('Test info message')
    logger.debug('Test debug message')
    logger.trace('Test trace message')

    output = @captured_output.string

    assert_includes output, '[Overhear][ERROR] Test error message'
    assert_includes output, '[Overhear][INFO] Test info message'
    assert_includes output, '[Overhear][DEBUG] Test debug message'
    assert_includes output, '[Overhear][TRACE] Test trace message'
  end

  def test_environment_variable_configuration
    # Set environment variable
    ENV['overhear_DEBUG_LEVEL'] = 'WARN'

    # Create a new logger that should pick up the environment variable
    logger = Overhear::Logger.new

    # Check that the level was set correctly
    assert_equal :WARN, logger.level

    # Test that WARN and ERROR messages are logged
    logger.error('Test error message')
    logger.warn('Test warn message')
    logger.info('Test info message')

    output = @captured_output.string

    assert_includes output, '[Overhear][ERROR] Test error message'
    assert_includes output, '[Overhear][WARN] Test warn message'
    refute_includes output, '[Overhear][INFO] Test info message'
  end

  def test_backward_compatibility
    # Clear debug level and set legacy debug flag
    ENV.delete('overhear_DEBUG_LEVEL')
    ENV['overhear_DEBUG'] = 'true'

    # Create a new logger that should pick up the environment variable
    logger = Overhear::Logger.new

    # Check that the level was set to INFO for backward compatibility
    assert_equal :INFO, logger.level
  end

  def test_invalid_log_level
    logger = Overhear::Logger.new

    # Test that setting an invalid level raises an error
    assert_raises(ArgumentError) do
      logger.level = :INVALID_LEVEL
    end
  end

  def test_should_log_method
    logger = Overhear::Logger.new
    logger.level = :INFO

    # Use send to access private method
    assert logger.send(:should_log?, :ERROR)
    assert logger.send(:should_log?, :INFO)
    refute logger.send(:should_log?, :DEBUG)
    refute logger.send(:should_log?, :TRACE)
  end
end
