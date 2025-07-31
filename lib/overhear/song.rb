# frozen_string_literal: true

module Overhear
  # Class to represent a single song in the ListenBrainz database
  # @since 0.1.0
  class Song
    # Creates a new Song instance
    # @param artist_names [String, Array<String>] the name(s) of the artist(s)
    # @param name [String] the name of the song
    # @param release_name [String] the name of the album or release
    # @param isrc [String, nil] the International Standard Recording Code
    # @param duration [Integer, nil] the duration of the song in milliseconds
    # @return [Song] a new instance of Song
    def initialize(artist_names:, name:, release_name:, isrc:, duration:)
      @artist_names = artist_names
      @name = name
      @release_name = release_name
      @isrc = isrc
      @duration = duration
    end

    # Creates a Song instance from ListenBrainz track metadata
    # @param metadata [Hash] the track metadata from ListenBrainz API
    # @return [Song] a new instance of Song
    # @example
    #   metadata = { 'track_name' => 'Song Title', 'release_name' => 'Album Name',
    #                'additional_info' => { 'artist_names' => 'Artist Name', 
    #                                       'isrc' => 'USRC12345678', 
    #                                       'duration_ms' => 240000 } }
    #   song = Song.from_track_metadata(metadata)
    def self.from_track_metadata(metadata)
      new(
        artist_names: metadata.dig('additional_info', 'artist_names'),
        name: metadata['track_name'],
        release_name: metadata['release_name'],
        isrc: metadata.dig('additional_info', 'isrc'),
        duration: metadata.dig('additional_info', 'duration_ms')
      )
    end

    # @return [String, Array<String>] the name(s) of the artist(s)
    attr_reader :artist_names
    
    # @return [String] the name of the song
    attr_reader :name
    
    # @return [String] the name of the album or release
    attr_reader :release_name
    
    # @return [String, nil] the International Standard Recording Code
    attr_reader :isrc
    
    # @return [Integer, nil] the duration of the song in milliseconds
    attr_reader :duration
  end
end
