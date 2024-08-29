# frozen_string_literal: true

require_relative 'overhear/version'

# Top level module for gem
module Overhear
  require 'overhear/clients/client'
  require 'overhear/clients/user_client'
  require 'overhear/song'

  # Error class for invalid ListenBrainz API token
  class InvalidTokenError < StandardError
    def initialize(msg = 'Invalid token passed')
      super
    end
  end
end
