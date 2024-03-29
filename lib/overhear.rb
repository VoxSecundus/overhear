# frozen_string_literal: true

module Overhear
  require 'overhear/clients/client'
  require 'overhear/clients/user_client'
  require 'overhear/song'

  class InvalidTokenError < StandardError; end
end
