# frozen_string_literal: true

require 'httparty'

module Overhear
  require 'overhear/client'

  class InvalidTokenError < StandardError; end
end
