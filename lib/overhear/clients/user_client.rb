# frozen_string_literal: true

module Overhear
  # Client class for user-specific ListenBrainz API actions
  # @since 0.1.0
  class UserClient < AuthenticatableClient
    # Gets the user's currently playing track
    # @return [Song, nil] the currently playing song or nil if nothing is playing
    # @example
    #   song = client.now_playing
    #   puts "Now playing: #{song.name}" if song
    def now_playing
      Overhear.logger.info("Fetching currently playing track for user: #{@username}")
      response = get("/1/user/#{@username}/playing-now", default_headers)
      payload = parse_response(response)['payload']

      if payload['count'].zero?
        Overhear.logger.info("No track currently playing for user: #{@username}")
        return nil
      end

      metadata = payload['listens'].first['track_metadata']
      Overhear.logger.debug('Found currently playing track metadata')

      song = Song.from_track_metadata(metadata)
      Overhear.logger.info("Currently playing: #{song.name} by #{song.artist_names.join(', ')}")
      song
    end

    # Gets the total number of listens for the user
    # @return [Integer] the total number of listens
    # @example
    #   count = client.listen_count
    #   puts "Total listens: #{count}"
    def listen_count
      Overhear.logger.info("Fetching listen count for user: #{@username}")
      response = get("/1/user/#{@username}/listen-count", default_headers)
      payload = parse_response(response)['payload']

      count = payload['count']
      Overhear.logger.info("Total listen count for #{@username}: #{count}")
      count
    end

    # Gets the user's listen history
    # @param max_ts [Integer, nil] if specified, returns listens with timestamp less than this value
    # @param min_ts [Integer, nil] if specified, returns listens with timestamp greater than this value
    # @param count [Integer, nil] number of listens to return (default: server default)
    # @return [Array<Song>] array of Song objects representing the user's listen history
    # @raise [ArgumentError] if both max_ts and min_ts are specified
    # @example
    #   # Get most recent listens
    #   songs = client.listens
    #
    #   # Get listens before a specific timestamp
    #   songs = client.listens(max_ts: 1596234567)
    #
    #   # Get listens after a specific timestamp
    #   songs = client.listens(min_ts: 1596234567)
    #
    #   # Limit the number of returned listens
    #   songs = client.listens(count: 10)
    def listens(max_ts: nil, min_ts: nil, count: nil)
      Overhear.logger.info("Fetching listens for user: #{@username}")

      if max_ts && min_ts
        Overhear.logger.error('Both max_ts and min_ts specified, which is not allowed')
        raise ArgumentError, 'Cannot specify both max_ts and min_ts'
      end

      params = {}
      params[:max_ts] = max_ts if max_ts
      params[:min_ts] = min_ts if min_ts
      params[:count] = count if count

      response = get("/1/user/#{@username}/listens", default_headers, params)
      payload = parse_response(response)['payload']

      listens = payload['listens'] || []
      Overhear.logger.info("Retrieved #{listens.size} listens for #{@username}")

      listens.map do |listen|
        metadata = listen['track_metadata']
        Song.from_track_metadata(metadata)
      end
    end
  end
end
