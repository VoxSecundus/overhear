# frozen_string_literal: true

module Overhear
  # Logger class for Overhear gem with configurable verbosity levels
  # @since 0.2.0
  class Logger
    # Available log levels in order of increasing verbosity
    # @return [Hash] the log levels with their numeric values
    LEVELS = {
      OFF: 0,
      ERROR: 1,
      WARN: 2,
      INFO: 3,
      DEBUG: 4,
      TRACE: 5
    }.freeze

    # Creates a new Logger instance
    # @return [Logger] a new instance of Logger
    # @example
    #   logger = Overhear::Logger.new
    def initialize
      @level = determine_log_level
    end

    # @return [Symbol] the current log level
    attr_reader :level

    # Sets the log level
    # @param level [Symbol, String] the log level to set
    # @return [Symbol] the new log level
    # @raise [ArgumentError] if the level is invalid
    # @example
    #   logger.level = :DEBUG
    def level=(level)
      level_sym = level.to_s.upcase.to_sym
      raise ArgumentError, "Invalid log level: #{level}" unless LEVELS.key?(level_sym)

      @level = level_sym
    end

    # Logs a message at ERROR level
    # @param message [String] the message to log
    # @return [nil]
    # @example
    #   logger.error("An error occurred")
    def error(message)
      log(:ERROR, message)
    end

    # Logs a message at WARN level
    # @param message [String] the message to log
    # @return [nil]
    # @example
    #   logger.warn("This is a warning")
    def warn(message)
      log(:WARN, message)
    end

    # Logs a message at INFO level
    # @param message [String] the message to log
    # @return [nil]
    # @example
    #   logger.info("Operation completed successfully")
    def info(message)
      log(:INFO, message)
    end

    # Logs a message at DEBUG level
    # @param message [String] the message to log
    # @return [nil]
    # @example
    #   logger.debug("Debug information")
    def debug(message)
      log(:DEBUG, message)
    end

    # Logs a message at TRACE level
    # @param message [String] the message to log
    # @return [nil]
    # @example
    #   logger.trace("Detailed trace information")
    def trace(message)
      log(:TRACE, message)
    end

    # Logs a message if the current level is sufficient
    # @param level [Symbol] the level to log at
    # @param message [String, Object] the message or object to log
    # @return [nil]
    # @api private
    def log(level, message)
      return unless should_log?(level)

      puts "[Overhear][#{level}] #{message}"
    end

    # Logs an object as JSON if the current level is sufficient
    # @param level [Symbol] the level to log at
    # @param object [Object] the object to log as JSON
    # @return [nil]
    # @example
    #   logger.log_json(:DEBUG, response_hash)
    def log_json(level, object)
      return unless should_log?(level)

      require 'json'
      formatted = JSON.pretty_generate(object)
      log(level, "\n#{formatted}")
    end

    private

    # Determines if a message at the given level should be logged
    # @param level [Symbol] the level to check
    # @return [Boolean] true if the message should be logged
    # @api private
    def should_log?(level)
      LEVELS[level] <= LEVELS[@level]
    end

    # Determines the log level from environment variables
    # @return [Symbol] the determined log level
    # @api private
    def determine_log_level
      env_level = ENV['overhear_DEBUG_LEVEL']&.upcase&.to_sym

      if env_level && LEVELS.key?(env_level)
        env_level
      elsif ENV['overhear_DEBUG']
        :INFO
      else
        :OFF
      end
    end
  end
end
