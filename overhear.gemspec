# frozen_string_literal: true

require_relative 'lib/overhear/version'

Gem::Specification.new do |spec|
  spec.name = 'overhear'
  spec.version = Overhear::VERSION
  spec.authors = ['Jack Millard']
  spec.email = ['millard64@hotmail.co.uk']

  spec.summary = 'A Ruby library for the ListenBrainz Web API'
  spec.homepage = 'https://github.com/VoxSecundus/overhear'
  spec.required_ruby_version = '>= 3.4.5'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/VoxSecundus/overhear'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob('lib/**/*', File::FNM_DOTMATCH)

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'faraday', '~> 1.0'

  spec.license = 'MIT'
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
