# Overhear Development Guidelines

This document provides specific information for developers working on the Overhear gem, which is a Ruby library for the ListenBrainz Web API.

## Build/Configuration Instructions

### Setup

1. Clone the repository and run the setup script:
   ```bash
   bin/setup
   ```
   This will install all dependencies using Bundler.

2. Environment Variables:
   - `overhear_API_ROOT`: Override the default ListenBrainz API URL (default: https://api.listenbrainz.org)
   - `overhear_DEBUG`: When set to any value, enables debug output of API responses

### Development Workflow

1. Use the console for interactive development:
   ```bash
   bin/console
   ```
   This loads an IRB session with the Overhear gem already required.

2. Install the gem locally for testing:
   ```bash
   bundle exec rake install
   ```

3. Release process:
   - Update version in `lib/overhear/version.rb`
   - Run `bundle exec rake release`

## Testing Information

### Running Tests

Run the test suite with:
```bash
rake test
```

The default Rake task runs both tests and RuboCop:
```bash
rake
```

### Adding New Tests

1. Create test files in the `test` directory with names matching the pattern `test_*.rb`
2. All test classes should inherit from `Minitest::Test`
3. Test methods should start with `test_`

### Test Example

Here's a simple test example for the UserClient class:

```ruby
# test/test_user_client.rb
require 'test_helper'

class TestUserClient < Minitest::Test
  def test_invalid_token_raises_error
    assert_raises(Overhear::InvalidTokenError) do
      Overhear::UserClient.new("invalid_token")
    end
  end
end
```

## Code Style and Development Information

1. This project uses RuboCop for code style enforcement:
   ```bash
   rake rubocop
   ```


2. Code Style Guidelines:
   - Follow the standard Ruby style guide
   - Use frozen_string_literal comments
   - Use two-space indentation
   - Include YARD documentation for all classes and methods (see Documentation section below)
   - Update `sig/overhear.rbs` with RBS style signatures
   - Always run RuboCop autocorrect on file save

3. API Integration:
   - The gem is structured around client classes that handle different aspects of the ListenBrainz API
   - The base `Client` class provides common functionality
   - Specific clients like `UserClient` handle domain-specific API endpoints
   - The `Song` class represents track data returned from the API

4. Error Handling:
   - Use `InvalidTokenError` for authentication issues
   - API responses are parsed with error handling in the client classes

## Documentation

### YARD Documentation

This project uses [YARD](https://yardoc.org/) for documentation. All classes and methods must be documented using YARD tags.

1. Installing and Running YARD:
   ```bash
   # Generate documentation
   yard doc
   
   # Start a local server to view documentation
   yard server --reload
   ```

2. YARD Tag Guidelines:
   - Every class and module must include a description and `@since` tag
   - Every method must include a description
   - Document all parameters with `@param [Type] name description`
   - Document return values with `@return [Type] description`
   - Document exceptions raised with `@raise [ExceptionClass] description`
   - Include usage examples with `@example` where appropriate
   - Use `@api private` for internal methods not intended for public use

3. Example YARD Documentation:
   ```ruby
   # A class that represents a song in the ListenBrainz database
   # @since 0.1.0
   class Song
     # Creates a new Song instance
     # @param name [String] the name of the song
     # @param artist [String] the artist name
     # @return [Song] a new instance of Song
     # @example
     #   song = Song.new(name: "Song Title", artist: "Artist Name")
     def initialize(name:, artist:)
       # implementation
     end
   end
   ```