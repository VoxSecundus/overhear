# Overhear

Overhear is a Ruby gem for the ListenBrainz Web API. It lets you get/submit data from/to the API easily and quickly.

## Installation

Install the gem and add to the application's Gemfile by executing:

And then execute:

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install overhear

## Usage

### Authentication

To interact with the ListenBrainz Web API, you need a user token. Fetch one from your [account settings](https://listenbrainz.org/settings/) page.

```ruby
require 'overhear'

# Create a client with your ListenBrainz token
client = Overhear::UserClient.new("your_listenbrainz_token")
```

### Getting Currently Playing Track

```ruby
# Get the currently playing track
now_playing = client.now_playing

if now_playing
  puts "Currently playing: #{now_playing.name} by #{now_playing.artist_names.join(', ')}"
  puts "Album: #{now_playing.release_name}"
  puts "Duration: #{now_playing.duration} ms" if now_playing.duration
else
  puts "No track currently playing"
end
```

### Getting Listen Count

```ruby
# Get the total listen count for the user
count = client.listen_count
puts "Total listens: #{count}"
```

### Getting Listen History

```ruby
# Get recent listens
listens = client.listens

# Get listens with a limit
listens = client.listens(count: 10)

# Get listens before a specific timestamp
listens = client.listens(max_ts: 1596234567)

# Get listens after a specific timestamp
listens = client.listens(min_ts: 1596234567)

# Process the listens
listens.each do |song|
  puts "#{song.name} by #{song.artist_names.join(', ')} from #{song.release_name}"
end
```

## Configuration

### API Endpoint

By default, Overhear uses the official ListenBrainz API endpoint (`https://api.listenbrainz.org`). You can override this by setting the `overhear_API_ROOT` environment variable:

```bash
export overhear_API_ROOT="https://your-custom-listenbrainz-instance.com"
```

### Debugging

Overhear includes a configurable debug system with multiple verbosity levels:

- `OFF` - No debug output (default)
- `ERROR` - Only error messages
- `WARN` - Warnings and errors
- `INFO` - Basic information, warnings, and errors
- `DEBUG` - Detailed debug information
- `TRACE` - Very detailed trace information

#### Setting Debug Level

You can set the debug level in two ways:

1. Using environment variables:

```bash
# Set specific debug level
export overhear_DEBUG_LEVEL=DEBUG

# For backward compatibility, this enables INFO level
export overhear_DEBUG=true
```

2. Programmatically:

```ruby
# Set debug level
Overhear.logger.level = :DEBUG

# Check current level
puts Overhear.logger.level
```

#### Logging Examples

```ruby
# Configure debug level
Overhear.logger.level = :DEBUG

# Create client - will output debug information
client = Overhear::UserClient.new("your_listenbrainz_token")

# API calls will include debug information
now_playing = client.now_playing
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/voxsecundus/overhear.
