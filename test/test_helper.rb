# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'overhear'

require 'minitest/autorun'

# Simple Response class for testing
class Response
  attr_reader :body

  def initialize(body)
    @body = body
  end
end
