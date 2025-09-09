# frozen_string_literal: true

module Overhear
  class ListenClient < AuthenticatableClient
    # Submits listens to the ListenBrainz server
    # @param listen_type [String] the type of listen submission ('single', 'playing_now', or 'import')
    # @param listens [Array<Hash>] array of listen data to submit
    # @return [Hash] the parsed response body from ListenBrainz on success
    # @raise [ArgumentError] if listen_type is invalid or listens is empty
    # @raise [StandardError] if the API returns a non-success status
    # @example Submit a single listen
    #   client.submit_listens('single', [{
    #     listened_at: Time.now.to_i,
    #     track_metadata: {
    #       artist_name: 'Rick Astley',
    #       track_name: 'Never Gonna Give You Up',
    #       release_name: 'Whenever You Need Somebody'
    #     }
    #   }])
    #
    # @example Submit a playing_now notification
    #   client.submit_listens('playing_now', [{
    #     track_metadata: {
    #       artist_name: 'Rick Astley',
    #       track_name: 'Never Gonna Give You Up',
    #       release_name: 'Whenever You Need Somebody'
    #     }
    #   }])
    def submit_listens(listen_type, listens)
      Overhear.logger.info("Submitting #{listen_type} listens")

      validate_listen_submission(listen_type, listens)

      body = {
        listen_type: listen_type,
        payload: listens
      }

      response = post('/1/submit-listens', default_headers, body)

      if response.status == 200
        Overhear.logger.info("Successfully submitted #{listens.size} listens")
        # Return parsed response instead of boolean to avoid predicate semantics
        parse_response(response)
      else
        Overhear.logger.error("Failed to submit listens: #{response.status}")
        # Raise an error to signal failure rather than returning false
        raise StandardError, "Submit listens failed with status #{response.status}"
      end
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

    # Gets the timestamp of the newest listen submitted by a user in previous imports.
    # Defaults to the authenticated user's username if none is provided.
    # @param user_name [String, nil] the MusicBrainz ID (username) to query; defaults to the authenticated user
    # @return [Integer] the latest import timestamp (UNIX epoch)
    # @example
    #   ts = client.latest_import
    #   ts_for_other = client.latest_import(user_name: 'other_user')
    # @since 0.2.0
    def latest_import(user_name: nil)
      uname = user_name || @username
      Overhear.logger.info("Fetching latest import timestamp for user: #{uname}")
      response = get('/1/latest-import', default_headers, { user_name: uname })
      body = parse_response(response)
      (body['latest_import'] || 0).to_i
    end

    # Updates the timestamp of the newest listen submitted by the authenticated user.
    # @param timestamp [Integer] the UNIX epoch timestamp to set as latest import
    # @return [Boolean] true if the update succeeded
    # @raise [ArgumentError] if timestamp is not a non-negative Integer
    # @raise [Overhear::InvalidTokenError] if the server returns 401 Unauthorized
    # @raise [StandardError] for other non-success HTTP statuses
    # @example
    #   client.update_latest_import(Time.now.to_i)
    # @since 0.2.0
    def update_latest_import(timestamp)
      Overhear.logger.info("Updating latest import timestamp to #{timestamp} for user: #{@username}")
      unless timestamp.is_a?(Integer) && timestamp >= 0
        Overhear.logger.error('Invalid timestamp provided for update_latest_import')
        raise ArgumentError, 'timestamp must be a non-negative Integer UNIX timestamp'
      end

      response = post('/1/latest-import', default_headers, { ts: timestamp })

      case response.status
      when 200
        Overhear.logger.info('Latest import timestamp updated successfully')
        true
      when 401
        Overhear.logger.error('Unauthorized when updating latest import timestamp')
        raise InvalidTokenError, 'Invalid authorization when updating latest import'
      else
        Overhear.logger.error("Failed to update latest import: #{response.status}")
        raise StandardError, "Update latest import failed with status #{response.status}"
      end
    end

    # Deletes a particular listen from the user's listen history
    # Schedules the listen for deletion as per ListenBrainz semantics
    # @param listened_at [Integer] the UNIX timestamp of the listen to delete
    # @param recording_msid [String] the recording MSID of the listen to delete
    # @return [Hash] the parsed response body from ListenBrainz on success
    # @raise [ArgumentError] if parameters are missing or invalid
    # @raise [StandardError] if the API returns a non-success status
    # @example
    #   client.delete_listen(listened_at: 1_696_000_000, recording_msid: "d23f4719-9212-49f0-ad08-ddbfbfc50d6f")
    def delete_listen(listened_at:, recording_msid:)
      Overhear.logger.info('Deleting listen')

      validate_delete_listen_params(listened_at, recording_msid)

      body = {
        listened_at: listened_at,
        recording_msid: recording_msid
      }

      response = post('/1/delete-listen', default_headers, body)

      if response.status == 200
        Overhear.logger.info('Listen deletion scheduled successfully')
        parse_response(response)
      else
        Overhear.logger.error("Failed to delete listen: #{response.status}")
        raise StandardError, "Delete listen failed with status #{response.status}"
      end
    end

    private

    # Validates parameters for delete_listen method
    # @param listened_at [Integer] the UNIX timestamp to validate
    # @param recording_msid [String] the recording MSID to validate
    # @raise [ArgumentError] if parameters are missing or invalid
    # @api private
    def validate_delete_listen_params(listened_at, recording_msid)
      validate_listened_at(listened_at)
      validate_recording_msid(recording_msid)
    end

    # Validates the listened_at parameter
    # @param listened_at [Integer] the UNIX timestamp to validate
    # @raise [ArgumentError] if listened_at is invalid
    # @api private
    def validate_listened_at(listened_at)
      return unless listened_at.nil? || !listened_at.is_a?(Integer) || listened_at <= 0

      Overhear.logger.error('Invalid listened_at for delete_listen')
      raise ArgumentError, 'listened_at must be a positive Integer'
    end

    # Validates the recording_msid parameter
    # @param recording_msid [String] the recording MSID to validate
    # @raise [ArgumentError] if recording_msid is invalid
    # @api private
    def validate_recording_msid(recording_msid)
      return unless recording_msid.nil? || !recording_msid.is_a?(String) || recording_msid.strip.empty?

      Overhear.logger.error('Invalid recording_msid for delete_listen')
      raise ArgumentError, 'recording_msid must be a non-empty String'
    end

    # Validates the listen submission parameters
    # @param listen_type [String] the type of listen submission
    # @param listens [Array<Hash>] array of listen data to submit
    # @raise [ArgumentError] if listen_type is invalid or listens is empty
    # @raise [ArgumentError] if playing_now submission contains timestamps
    # @api private
    def validate_listen_submission(listen_type, listens)
      valid_types = %w[single playing_now import]
      unless valid_types.include?(listen_type)
        Overhear.logger.error("Invalid listen_type: #{listen_type}")
        raise ArgumentError, "Invalid listen_type: #{listen_type}. Must be one of: #{valid_types.join(', ')}"
      end

      if listens.empty?
        Overhear.logger.error('Empty listens array')
        raise ArgumentError, 'Listens array cannot be empty'
      end

      if listen_type == 'playing_now'
        listens.each do |listen|
          if listen.key?('listened_at') || listen.key?(:listened_at)
            Overhear.logger.error('Playing_now submission contains timestamp')
            raise ArgumentError, 'Playing_now submissions must not contain timestamps'
          end
        end
      end

      Overhear.logger.info('Listen submission validation passed')
    end
  end
end
