# frozen_string_literal: true

require_relative 'overhear/version'

# @author VoxSecundus
# @since 0.1.0
# @example Basic usage with a user token
#   client = Overhear::UserClient.new('your_listenbrainz_token')
#   now_playing = client.now_playing
#   puts "Currently playing: #{now_playing.name} by #{now_playing.artist_names}"
#
# @example Getting listen count
#   client = Overhear::UserClient.new('your_listenbrainz_token')
#   count = client.listen_count
#   puts "Total listens: #{count}"
#
# @example Using debug mode with configurable verbosity
#   # Set debug level via environment variable
#   # ENV['overhear_DEBUG_LEVEL'] = 'DEBUG'
#
#   # Or configure programmatically
#   Overhear.logger.level = :DEBUG
#
#   client = Overhear::UserClient.new('your_listenbrainz_token')
#   # Debug output will be shown based on configured level
module Overhear
  require 'overhear/clients/client'
  require 'overhear/clients/user_client'
  require 'overhear/song'
  require 'overhear/logger'

  @logger = Logger.new

  class << self
    # @return [Overhear::Logger] the global logger instance
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
