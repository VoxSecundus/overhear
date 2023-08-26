# frozen_string_literal: true

require_relative "overhear/version"

module Overhear
  require "overhear/clients/client"
  require "overhear/clients/user_client"
  require "overhear/song"

  class InvalidTokenError < StandardError
    def initialize(msg="Invalid token passed")
      super
    end
  end
end
