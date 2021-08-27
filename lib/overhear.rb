# frozen_string_literal: true

module Overhear
  require 'overhear/client'
  require 'overhear/song'

  class InvalidTokenError < StandardError; end
  class NotListeningError < StandardError; end
end
