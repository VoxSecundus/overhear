Gem::Specification.new do |s|
  s.name = 'overhear'
  s.version = '0.0.0'
  s.summary = "What's that?"
  s.description = "A ListenBrainz API wrapper for Ruby"
  s.authors = ['Jack Millard']
  s.email = 'millard64@hotmail.co.uk'
  s.files = ['lib/overhear.rb', 'lib/overhear/client.rb', 'lib/overhear/song.rb']
  s.license = 'MIT'
  s.add_runtime_dependency 'faraday', '~> 1.0'
end
