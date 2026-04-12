# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle exec rake          # Run tests + RuboCop (default)
bundle exec rake test     # Run test suite only
bundle exec rake rubocop  # Lint only
bin/setup                 # Install dependencies
```

To run a single test file:
```bash
bundle exec ruby -Ilib:test test/test_listen_client.rb
```

## Architecture

Overhear is a Ruby gem providing a client library for the [ListenBrainz Web API](https://listenbrainz.readthedocs.io/en/latest/users/api/index.html). ListenBrainz is a music scrobbling/tracking service.

### Client Design

```
HttpConnection                 # Faraday GET/POST, default_headers, parse_response
Client                         # Validates token once; lazily exposes service objects
  ├─ client.listens            # → ListensService  (submit, history, delete, import)
  └─ client.user               # → UserService     (now_playing)
```

`Client.new(token)` validates the token against `/1/validate-token` and raises `Overhear::InvalidTokenError` on failure. Service objects (`ListensService`, `UserService`) are plain Ruby objects injected with an `HttpConnection` instance — they do not inherit from anything.

New API groups get a new service class under `lib/overhear/services/` and a corresponding accessor on `Client`.

### Data Flow

API responses are parsed by `HttpConnection#parse_response`, which logs raw JSON at TRACE level. `Song` objects are produced via the `Song.from_track_metadata` factory method from the nested `track_metadata` hash in ListenBrainz payloads.

### Configuration via Environment Variables

| Variable | Default | Purpose |
|---|---|---|
| `overhear_API_ROOT` | `https://api.listenbrainz.org` | API base URL |
| `overhear_DEBUG_LEVEL` | `ERROR` | Log level (OFF/ERROR/WARN/INFO/DEBUG/TRACE) |

Logger is accessible globally as `Overhear.logger`.

## Testing

Tests use Minitest with WebMock (real HTTP is disabled). `test/test_helper.rb` provides stub helpers (`stub_token_validation`, `stub_listens`, `stub_now_playing`, etc.) for mocking all ListenBrainz endpoints. Add new stubs there when adding new endpoints.

## Code Style

RuboCop with `rubocop-minitest` and `rubocop-rake` plugins. Key rules: single quotes, 120-char line limit, 20-line method max. Run `bundle exec rake rubocop` before committing.
