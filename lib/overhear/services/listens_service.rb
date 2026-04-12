# frozen_string_literal: true

module Overhear
  # rubocop:disable Metrics/ClassLength
  # Service for listen-related ListenBrainz API actions.
  # Receives an HttpConnection and username rather than inheriting auth behaviour.
  # @since 0.3.0
  class ListensService
    # @param http [Overhear::HttpConnection]
    # @param username [String] the authenticated user's ListenBrainz username
    def initialize(http, username)
      @http = http
      @username = username
    end

    # Gets the total number of listens for the user
    # @return [Integer]
    def listen_count
      Overhear.logger.info("Fetching listen count for user: #{@username}")
      response = @http.get("/1/user/#{@username}/listen-count", @http.default_headers)
      payload = @http.parse_response(response)['payload']
      count = payload['count']
      Overhear.logger.info("Total listen count for #{@username}: #{count}")
      count
    end

    # Gets the user's listen history
    # @param max_ts [Integer, nil] return listens with timestamp less than this value
    # @param min_ts [Integer, nil] return listens with timestamp greater than this value
    # @param count [Integer, nil] number of listens to return
    # @return [Array<Song>]
    # @raise [ArgumentError] if both max_ts and min_ts are specified
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

      response = @http.get("/1/user/#{@username}/listens", @http.default_headers, params)
      payload = @http.parse_response(response)['payload']

      listen_list = payload['listens'] || []
      Overhear.logger.info("Retrieved #{listen_list.size} listens for #{@username}")

      listen_list.map { |listen| Song.from_track_metadata(listen['track_metadata']) }
    end

    # Submits listens to the ListenBrainz server
    # @param listen_type [String] 'single', 'playing_now', or 'import'
    # @param listens [Array<Hash>] listen data to submit
    # @return [Hash] parsed response body
    # @raise [ArgumentError] if listen_type is invalid or listens is empty
    # @raise [StandardError] if the API returns a non-success status
    def submit_listens(listen_type, listens)
      Overhear.logger.info("Submitting #{listen_type} listens")
      validate_listen_submission(listen_type, listens)

      body = { listen_type: listen_type, payload: listens }
      response = @http.post('/1/submit-listens', @http.default_headers, body)

      if response.status == 200
        Overhear.logger.info("Successfully submitted #{listens.size} listens")
        @http.parse_response(response)
      else
        Overhear.logger.error("Failed to submit listens: #{response.status}")
        raise StandardError, "Submit listens failed with status #{response.status}"
      end
    end

    # Gets the timestamp of the newest listen from previous imports
    # @param user_name [String, nil] defaults to the authenticated user
    # @return [Integer] UNIX timestamp
    def latest_import(user_name: nil)
      uname = user_name || @username
      Overhear.logger.info("Fetching latest import timestamp for user: #{uname}")
      response = @http.get('/1/latest-import', @http.default_headers, { user_name: uname })
      body = @http.parse_response(response)
      (body['latest_import'] || 0).to_i
    end

    # Updates the latest import timestamp for the authenticated user
    # @param timestamp [Integer] UNIX epoch timestamp
    # @return [Boolean] true on success
    # @raise [ArgumentError] if timestamp is not a non-negative Integer
    # @raise [Overhear::InvalidTokenError] on 401
    # @raise [StandardError] on other non-success statuses
    def update_latest_import(timestamp)
      Overhear.logger.info("Updating latest import timestamp to #{timestamp} for user: #{@username}")
      unless timestamp.is_a?(Integer) && timestamp >= 0
        Overhear.logger.error('Invalid timestamp provided for update_latest_import')
        raise ArgumentError, 'timestamp must be a non-negative Integer UNIX timestamp'
      end

      response = @http.post('/1/latest-import', @http.default_headers, { ts: timestamp })

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

    # Deletes a particular listen from the user's history
    # @param listened_at [Integer] UNIX timestamp of the listen
    # @param recording_msid [String] recording MSID of the listen
    # @return [Hash] parsed response body
    # @raise [ArgumentError] if parameters are invalid
    # @raise [StandardError] if the API returns a non-success status
    def delete_listen(listened_at:, recording_msid:)
      Overhear.logger.info('Deleting listen')
      validate_delete_listen_params(listened_at, recording_msid)

      body = { listened_at: listened_at, recording_msid: recording_msid }
      response = @http.post('/1/delete-listen', @http.default_headers, body)

      if response.status == 200
        Overhear.logger.info('Listen deletion scheduled successfully')
        @http.parse_response(response)
      else
        Overhear.logger.error("Failed to delete listen: #{response.status}")
        raise StandardError, "Delete listen failed with status #{response.status}"
      end
    end

    private

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

      return unless listen_type == 'playing_now'

      listens.each do |listen|
        next unless listen.key?('listened_at') || listen.key?(:listened_at)

        Overhear.logger.error('Playing_now submission contains timestamp')
        raise ArgumentError, 'Playing_now submissions must not contain timestamps'
      end
    end

    def validate_delete_listen_params(listened_at, recording_msid)
      validate_listened_at(listened_at)
      validate_recording_msid(recording_msid)
    end

    def validate_listened_at(listened_at)
      return unless listened_at.nil? || !listened_at.is_a?(Integer) || listened_at <= 0

      Overhear.logger.error('Invalid listened_at for delete_listen')
      raise ArgumentError, 'listened_at must be a positive Integer'
    end

    def validate_recording_msid(recording_msid)
      return unless recording_msid.nil? || !recording_msid.is_a?(String) || recording_msid.strip.empty?

      Overhear.logger.error('Invalid recording_msid for delete_listen')
      raise ArgumentError, 'recording_msid must be a non-empty String'
    end
  end
  # rubocop:enable Metrics/ClassLength
end
