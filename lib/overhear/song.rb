module Overhear
  class Song
    def initialize(payload)
      if payload['count'] == 0
        return nil
      end

      track_metadata = payload['listens'].first['track_metadata']
      @artist_names = track_metadata['additional_info']['artist_names']
      @name = track_metadata['track_name']
      @release_name = track_metadata['release_name']
      @isrc = track_metadata['additional_info']['isrc']
      @duration = track_metadata['additional_info']['duration_ms']
    end

    attr_reader :artist_names, :name, :release_name, :isrc, :duration

  end
end
