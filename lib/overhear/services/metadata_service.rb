# frozen_string_literal: true

module Overhear
  # Service for metadata-related ListenBrainz API actions.
  # @since 0.1.0
  class MetadataService
    # @param http [Overhear::HttpConnection]
    # @param username [String] the authenticated user's ListenBrainz username
    def initialize(http, username)
      @http = http
      @username = username
    end

    # Gets recording metadata for one or more MusicBrainz recording IDs
    # @param recording_mbids [Array<String>] list of recording MBIDs
    # @param inc [String] space-separated list of 'artist', 'tag', and/or 'release'
    # @return [Hash] recording metadata keyed by MBID
    def recording(recording_mbids:, inc:)
      Overhear.logger.info("Fetching recording metadata for #{recording_mbids.size} MBIDs")
      params = { recording_mbids: recording_mbids.join(','), inc: inc }
      response = @http.get('/1/metadata/recording/', @http.default_headers, params)
      raise StandardError, "Recording metadata failed with status #{response.status}" unless response.status == 200

      @http.parse_response(response)
    end

    # Gets release group metadata for one or more MusicBrainz release group IDs
    # @param release_group_mbids [Array<String>] list of release group MBIDs
    # @param inc [String] space-separated list of 'artist', 'tag', and/or 'release'
    # @return [Hash] release group metadata keyed by MBID
    def release_group(release_group_mbids:, inc:)
      Overhear.logger.info("Fetching release group metadata for #{release_group_mbids.size} MBIDs")
      params = { release_group_mbids: release_group_mbids.join(','), inc: inc }
      response = @http.get('/1/metadata/release_group/', @http.default_headers, params)
      raise StandardError, "Release group metadata failed with status #{response.status}" unless response.status == 200

      @http.parse_response(response)
    end

    # Looks up MusicBrainz metadata by artist and recording name
    # @param artist_name [String] artist name of the listen
    # @param recording_name [String] track name of the listen
    # @param inc [String] space-separated list of 'artist', 'tag', and/or 'release'
    # @param release_name [String, nil] optional release name
    # @param metadata [Boolean] whether to return extra metadata if a match is found
    # @return [Hash] lookup result
    def lookup(artist_name:, recording_name:, inc:, release_name: nil, metadata: false)
      Overhear.logger.info("Looking up metadata for '#{recording_name}' by '#{artist_name}'")
      params = { artist_name: artist_name, recording_name: recording_name, inc: inc, metadata: metadata }
      params[:release_name] = release_name if release_name
      response = @http.get('/1/metadata/lookup/', @http.default_headers, params)
      raise StandardError, "Metadata lookup failed with status #{response.status}" unless response.status == 200

      @http.parse_response(response)
    end

    # Gets artist metadata for one or more MusicBrainz artist IDs
    # @param artist_mbids [Array<String>] list of artist MBIDs
    # @param inc [String] space-separated list of 'artist', 'tag', and/or 'release'
    # @return [Array] list of artist metadata hashes
    def artist(artist_mbids:, inc:)
      Overhear.logger.info("Fetching artist metadata for #{artist_mbids.size} MBIDs")
      params = { artist_mbids: artist_mbids.join(','), inc: inc }
      response = @http.get('/1/metadata/artist/', @http.default_headers, params)
      raise StandardError, "Artist metadata failed with status #{response.status}" unless response.status == 200

      @http.parse_response(response)
    end

    # Submits a manual recording-to-MusicBrainz mapping
    # @param recording_mbid [String] the MusicBrainz recording ID
    # @param recording_msid [String] the MessyBrainz recording ID
    # @return [Hash] parsed response body
    # @raise [InvalidTokenError] on 401
    # @raise [StandardError] on other non-200 responses
    def submit_manual_mapping(recording_mbid:, recording_msid:)
      Overhear.logger.info("Submitting manual mapping: #{recording_msid} -> #{recording_mbid}")
      body = { recording_mbid: recording_mbid, recording_msid: recording_msid }
      response = @http.post('/1/metadata/submit_manual_mapping/', @http.default_headers, body)
      handle_auth_response(response, 'Submit manual mapping')
    end

    # Gets a user's manual recording mapping
    # @param recording_msid [String] the MessyBrainz recording ID
    # @return [Hash] mapping data
    # @raise [InvalidTokenError] on 401
    # @raise [StandardError] on other non-200 responses
    def get_manual_mapping(recording_msid:)
      Overhear.logger.info("Fetching manual mapping for #{recording_msid}")
      response = @http.get('/1/metadata/get_manual_mapping/', @http.default_headers, { recording_msid: recording_msid })
      handle_auth_response(response, 'Get manual mapping')
    end

    private

    def handle_auth_response(response, operation)
      case response.status
      when 200
        @http.parse_response(response)
      when 401
        Overhear.logger.error("Unauthorized during: #{operation}")
        raise InvalidTokenError
      else
        Overhear.logger.error("#{operation} failed with status #{response.status}")
        raise StandardError, "#{operation} failed with status #{response.status}"
      end
    end
  end
end
