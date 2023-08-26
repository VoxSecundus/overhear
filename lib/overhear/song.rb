# frozen_string_literal: true

module Overhear
  class Song
    def initialize(artist_names:, name:, release_name:, isrc:, duration:)
      @artist_names = artist_names
      @name = name
      @release_name = release_name
      @isrc = isrc
      @duration = duration
    end

    attr_reader :artist_names, :name, :release_name, :isrc, :duration
  end
end
