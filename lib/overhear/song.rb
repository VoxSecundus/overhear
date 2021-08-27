module Overhear
  class Song
    def initialize(payload)
      if payload['count'] == 0
        raise NotListeningError
      end

      track_metadata = payload['listens'].first['track_metadata']
      @artist_names = track_metadata['additional_info']['artist_names']
      @name = track_metadata['track_name']
      @release_name = track_metadata['release_name']
      @isrc = track_metadata['isrc']
      @duration = track_metadata['duration_ms']
    end
  end
end
