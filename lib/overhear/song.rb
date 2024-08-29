# frozen_string_literal: true

module Overhear
  # Class to represent a single song in the ListenBrainz database
  class Song
    def initialize(artist_names:, name:, release_name:, isrc:, duration:)
      @artist_names = artist_names
      @name = name
      @release_name = release_name
      @isrc = isrc
      @duration = duration
    end

    def self.from_track_metadata(metadata)
      new(
        artist_names: metadata.dig('additional_info', 'artist_names'),
        name: metadata['track_name'],
        release_name: metadata['release_name'],
        isrc: metadata.dig('additional_info', 'isrc'),
        duration: metadata.dig('additional_info', 'duration_ms')
      )
    end

    attr_reader :artist_names, :name, :release_name, :isrc, :duration
  end
end
