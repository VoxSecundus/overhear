# Overhear

Overhear is a Ruby gem for the ListenBrainz Web API. It lets you get/submit data from/to the API easily and quickly.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add overhear

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install overhear

## Usage

To interact with the ListenBrainz Web API, you need a user token. Fetch one from your [account settings](https://listenbrainz.org/settings/) page. Create a user client with:

```ruby
client = Overhear::UserClient.new("<token>")
```

`UserClient#listen_count` - Return the total listen count for a user

`UserClient#now_playing` - Return the currently playing song for a user. Returns nil if no song currently playing.

## Debugging

Overhear includes a configurable debug system with multiple verbosity levels:

- `OFF` - No debug output (default)
- `ERROR` - Only error messages
- `WARN` - Warnings and errors
- `INFO` - Basic information, warnings, and errors
- `DEBUG` - Detailed debug information
- `TRACE` - Very detailed trace information

### Setting Debug Level

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

### Logging Examples

```ruby
# Configure debug level
Overhear.logger.level = :DEBUG

# Create client - will output debug information
client = Overhear::UserClient.new("<token>")

# API calls will include debug information
now_playing = client.now_playing
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/voxsecundus/overhear.
