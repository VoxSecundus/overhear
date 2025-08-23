# frozen_string_literal: true

require 'test_helper'

class TestSong < Minitest::Test
  def setup
    @artist_names = ['Test Artist']
    @name = 'Test Track'
    @release_name = 'Test Album'
    @isrc = 'USRC12345678'
    @duration = 240_000

    @song = Overhear::Song.new(
      artist_names: @artist_names,
      name: @name,
      release_name: @release_name,
      isrc: @isrc,
      duration: @duration
    )
  end

  def test_initialization
    assert_equal @artist_names, @song.artist_names
    assert_equal @name, @song.name
    assert_equal @release_name, @song.release_name
    assert_equal @isrc, @song.isrc
    assert_equal @duration, @song.duration
  end

  def test_from_track_metadata
    metadata = {
      'track_name' => 'Song Title',
      'release_name' => 'Album Name',
      'additional_info' => {
        'artist_names' => ['Artist Name'],
        'isrc' => 'USRC87654321',
        'duration_ms' => 180_000
      }
    }

    song = Overhear::Song.from_track_metadata(metadata)

    assert_instance_of Overhear::Song, song
    assert_equal ['Artist Name'], song.artist_names
    assert_equal 'Song Title', song.name
    assert_equal 'Album Name', song.release_name
    assert_equal 'USRC87654321', song.isrc
    assert_equal 180_000, song.duration
  end

  def test_from_track_metadata_with_missing_fields
    metadata = {
      'track_name' => 'Song Title',
      'release_name' => 'Album Name',
      'additional_info' => {
        'artist_names' => ['Artist Name']
        # Missing isrc and duration_ms
      }
    }

    song = Overhear::Song.from_track_metadata(metadata)

    assert_instance_of Overhear::Song, song
    assert_equal ['Artist Name'], song.artist_names
    assert_equal 'Song Title', song.name
    assert_equal 'Album Name', song.release_name
    assert_nil song.isrc
    assert_nil song.duration
  end

  def test_from_track_metadata_with_string_artist
    # Test when artist_names is a string instead of an array
    metadata = {
      'track_name' => 'Song Title',
      'release_name' => 'Album Name',
      'additional_info' => {
        'artist_names' => 'Single Artist',
        'isrc' => 'USRC87654321',
        'duration_ms' => 180_000
      }
    }

    song = Overhear::Song.from_track_metadata(metadata)

    assert_instance_of Overhear::Song, song
    assert_equal 'Single Artist', song.artist_names
    assert_equal 'Song Title', song.name
    assert_equal 'Album Name', song.release_name
  end
end
