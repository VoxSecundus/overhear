# frozen_string_literal: true

require_relative 'overhear/version'

# @author VoxSecundus
# @since 0.1.0
# @example Basic usage
#   client = Overhear::Client.new('your_listenbrainz_token')
#   puts client.user.now_playing&.name
#   puts client.listens.listen_count
#
# @example Using debug mode with configurable verbosity
#   # Set debug level via environment variable
#   # ENV['overhear_DEBUG_LEVEL'] = 'DEBUG'
#
#   # Or configure programmatically
#   Overhear.logger.level = :DEBUG
#   client = Overhear::Client.new('your_listenbrainz_token')
module Overhear
  require 'overhear/http_connection'
  require 'overhear/services/listens_service'
  require 'overhear/services/user_service'
  require 'overhear/client'
  require 'overhear/song'
  require 'overhear/logger'

  @logger = Logger.new

  class << self
    # The global logger instance used throughout the gem for logging messages
    # with configurable verbosity levels.
    #
    # The logger can be configured either through environment variables or
    # programmatically. By default, logging is turned off (level: OFF).
    #
    # @return [Overhear::Logger] the global logger instance
    # @see Overhear::Logger
    # @example Setting log level programmatically
    #   Overhear.logger.level = :DEBUG
    # @example Setting log level via environment variable
    #   # ENV['overhear_DEBUG_LEVEL'] = 'DEBUG'
    # @example Logging messages at different levels
    #   Overhear.logger.info("Operation completed")
    #   Overhear.logger.debug("Debug information")
    #   Overhear.logger.error("An error occurred")
    # @since 0.1.0
    attr_reader :logger
  end

  # Error raised when an invalid ListenBrainz API token is provided
  # @since 0.1.0
  class InvalidTokenError < StandardError
    # Creates a new InvalidTokenError
    # @param msg [String] the error message
    # @return [InvalidTokenError] a new instance of InvalidTokenError
    def initialize(msg = 'Invalid token passed')
      super
    end
  end
end
