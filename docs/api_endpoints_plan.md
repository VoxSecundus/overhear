# ListenBrainz API Endpoints Plan for Overhear Library

This document organizes the ListenBrainz API endpoints by category to help implement them in the Overhear library.

## Authentication Requirements

Most ListenBrainz API endpoints require authentication using a user token. The token must be included in the request header as follows:

```
Authorization: Token <user_token>
```

### Endpoints requiring authentication:
- All POST endpoints (submit-listens, delete-listen, etc.)
- User-specific data modification endpoints
- Private user data access endpoints

### Endpoints that work without authentication:
- Public user data endpoints (public listens, statistics, etc.)
- Search endpoints
- Some metadata endpoints

## Special Considerations

1. **Rate Limiting**: The API may have rate limits that should be respected. Implement retry logic with exponential backoff.

2. **Error Handling**: Properly handle common error responses (401 Unauthorized, 404 Not Found, etc.) and provide meaningful error messages.

3. **Timestamps**: All timestamps used in ListenBrainz are UNIX epoch timestamps in UTC with no timezone adjustments.

4. **Pagination**: Many endpoints that return lists support pagination via `count` and `offset` parameters.

5. **Constants**:
   - Maximum listen payload size: 10240000 bytes
   - Maximum listen size: 10240 bytes
   - Maximum listens per request: 1000
   - Maximum items per GET: 1000
   - Default items per GET: 25

## 1. Core Listening Data

### 1.1 Listen Submission and Management
- **POST /1/submit-listens** - Submit listens to the server
- **POST /1/delete-listen** - Delete a particular listen from a user's listen history
- **GET /1/latest-import** - Get the timestamp of the newest listen submitted by a user
- **POST /1/latest-import** - Update the timestamp of the newest listen submitted

### 1.2 User Listening History
- **GET /1/user/(user_name)/listens** - Get listens for user (✓ implemented)
- **GET /1/user/(user_name)/listen-count** - Get the number of listens for a user (✓ implemented)
- **GET /1/user/(user_name)/playing-now** - Get the listen being played right now (✓ implemented)

## 2. User Data and Social Features

### 2.1 User Authentication and Information
- **GET /1/validate-token** - Check whether a User Token is valid (✓ implemented)
- **GET /1/search/users/** - Search for a ListenBrainz-registered user
- **GET /1/user/(user_name)/services** - Get list of services connected to a user's account

### 2.2 Social Connections
- **GET /1/user/(user_name)/similar-users** - Get list of users with similar music tastes
- **GET /1/user/(user_name)/similar-to/(other_user_name)** - Get similarity between two users
- **GET /1/user/(user_name)/followers** - Get a user's followers
- **GET /1/user/(user_name)/following** - Get users that a user is following
- **POST /1/user/(user_name)/follow** - Follow a user
- **POST /1/user/(user_name)/unfollow** - Unfollow a user

### 2.3 Feed and Timeline
- **GET /1/user/(user_name)/feed/events** - Get feed events for a user
- **GET /1/user/(user_name)/feed/events/(event_id)** - Get a specific feed event
- **GET /1/user/(user_name)/feed/events/listens/following** - Get listens from users being followed
- **GET /1/user/(user_name)/feed/events/listens/similar** - Get listens from similar users
- **POST /1/user/(user_name)/feed/events/delete** - Delete feed events
- **POST /1/user/(user_name)/feed/events/hide** - Hide feed events
- **POST /1/user/(user_name)/feed/events/unhide** - Unhide feed events
- **POST /1/user/(user_name)/timeline-event/create/recording** - Create a recording timeline event
- **POST /1/user/(user_name)/timeline-event/create/notification** - Create a notification timeline event
- **POST /1/user/(user_name)/timeline-event/create/review** - Create a review timeline event
- **POST /1/user/(user_name)/timeline-event/create/recommendation** - Create a recommendation timeline event
- **POST /1/user/(user_name)/timeline-event/create/thanks** - Create a thanks timeline event

## 3. Playlists

### 3.1 Playlist Management
- **GET /1/user/(playlist_user_name)/playlists** - Fetch user's playlists
- **GET /1/user/(playlist_user_name)/playlists/createdfor** - Fetch playlists created for a user
- **GET /1/user/(playlist_user_name)/playlists/collaborator** - Fetch playlists where user is a collaborator
- **GET /1/user/(playlist_user_name)/playlists/recommendations** - Fetch recommendation playlists
- **GET /1/user/(playlist_user_name)/playlists/search** - Search for a playlist by name
- **GET /1/playlist/search** - Search for playlists
- **GET /1/playlist/(playlist_mbid)** - Get a specific playlist
- **GET /1/playlist/(playlist_mbid)/xspf** - Get a playlist in XSPF format
- **POST /1/playlist/create** - Create a new playlist
- **POST /1/playlist/edit/(playlist_mbid)** - Edit a playlist
- **POST /1/playlist/(playlist_mbid)/delete** - Delete a playlist
- **POST /1/playlist/(playlist_mbid)/copy** - Copy a playlist

### 3.2 Playlist Items
- **POST /1/playlist/(playlist_mbid)/item/add** - Add an item to a playlist
- **POST /1/playlist/(playlist_mbid)/item/add/(offset)** - Add an item at a specific position
- **POST /1/playlist/(playlist_mbid)/item/move** - Move items within a playlist
- **POST /1/playlist/(playlist_mbid)/item/delete** - Delete items from a playlist

### 3.3 Playlist Import/Export
- **GET /1/playlist/import/(service)** - Import playlists from a service
- **GET /1/playlist/spotify/(playlist_id)/tracks** - Get tracks from a Spotify playlist
- **GET /1/playlist/apple_music/(playlist_id)/tracks** - Get tracks from an Apple Music playlist
- **GET /1/playlist/soundcloud/(playlist_id)/tracks** - Get tracks from a SoundCloud playlist
- **POST /1/playlist/(playlist_mbid)/export/(service)** - Export a playlist to a service
- **POST /1/playlist/export-jspf/(service)** - Export a playlist in JSPF format

## 4. User Feedback and Pins

### 4.1 Recording Feedback
- **POST /1/feedback/recording-feedback** - Submit feedback for a recording
- **GET /1/feedback/user/(user_name)/get-feedback** - Get feedback for a user
- **GET /1/feedback/recording/(recording_mbid)/get-feedback-mbid** - Get feedback for a recording by MBID
- **GET /1/feedback/recording/(recording_msid)/get-feedback** - Get feedback for a recording by MSID
- **POST /1/feedback/user/(user_name)/get-feedback-for-recordings** - Get feedback for specific recordings
- **POST /1/feedback/import** - Import feedback

### 4.2 Pins
- **POST /1/pin** - Create a pin
- **POST /1/pin/unpin** - Unpin a recording
- **POST /1/pin/delete/(row_id)** - Delete a pin
- **POST /1/pin/update/(row_id)** - Update a pin
- **GET /1/(user_name)/pins** - Get pins for a user
- **GET /1/(user_name)/pins/following** - Get pins from users being followed
- **GET /1/(user_name)/pins/current** - Get current pin for a user

## 5. Statistics and Analytics

### 5.1 User Statistics
- **GET /1/stats/user/(user_name)/artists** - Get user's top artists
- **GET /1/stats/user/(user_name)/releases** - Get user's top releases
- **GET /1/stats/user/(user_name)/release-groups** - Get user's top release groups
- **GET /1/stats/user/(user_name)/recordings** - Get user's top recordings
- **GET /1/stats/user/(user_name)/listening-activity** - Get user's listening activity
- **GET /1/stats/user/(user_name)/artist-activity** - Get user's artist activity
- **GET /1/stats/user/(user_name)/daily-activity** - Get user's daily activity
- **GET /1/stats/user/(user_name)/artist-map** - Get user's artist map
- **GET /1/stats/user/(user_name)/year-in-music/(year)** - Get user's year in music
- **GET /1/stats/user/(user_name)/year-in-music** - Get user's year in music (current year)

### 5.2 Artist/Release Statistics
- **GET /1/stats/artist/(artist_mbid)/listeners** - Get listeners for an artist
- **GET /1/stats/release-group/(release_group_mbid)/listeners** - Get listeners for a release group

### 5.3 Sitewide Statistics
- **GET /1/stats/sitewide/artists** - Get sitewide top artists
- **GET /1/stats/sitewide/releases** - Get sitewide top releases
- **GET /1/stats/sitewide/release-groups** - Get sitewide top release groups
- **GET /1/stats/sitewide/recordings** - Get sitewide top recordings
- **GET /1/stats/sitewide/listening-activity** - Get sitewide listening activity
- **GET /1/stats/sitewide/artist-activity** - Get sitewide artist activity
- **GET /1/stats/sitewide/artist-map** - Get sitewide artist map

## 6. Recommendations

### 6.1 User Recommendations
- **GET /1/cf/recommendation/user/(user_name)/recording** - Get recording recommendations for a user
- **GET /1/user/(user_name)/fresh_releases** - Get fresh releases for a user

### 6.2 Recommendation Feedback
- **POST /1/recommendation/feedback/submit** - Submit feedback for a recommendation
- **POST /1/recommendation/feedback/delete** - Delete recommendation feedback
- **GET /1/recommendation/feedback/user/(user_name)** - Get recommendation feedback for a user
- **GET /1/recommendation/feedback/user/(user_name)/recordings** - Get recording recommendation feedback

### 6.3 Radio
- **GET /1/lb-radio/tags** - Get recordings for LB radio with specified tags
- **GET /1/lb-radio/artist/(seed_artist_mbid)** - Get recordings for LB radio with a seed artist
- **GET /1/explore/lb-radio** - Get LB radio information

## 7. Metadata and Popularity

### 7.1 Recording Metadata
- **GET /1/metadata/recording/** - Get recording metadata
- **POST /1/metadata/recording/** - Submit recording metadata
- **GET /1/metadata/release_group/** - Get release group metadata
- **GET /1/metadata/lookup/** - Lookup metadata
- **POST /1/metadata/lookup/** - Submit metadata lookup
- **GET /1/metadata/get_manual_mapping/** - Get manual mapping
- **POST /1/metadata/submit_manual_mapping/** - Submit manual mapping
- **GET /1/metadata/artist/** - Get artist metadata

### 7.2 Popularity Data
- **GET /1/popularity/top-recordings-for-artist/(artist_mbid)** - Get top recordings for an artist
- **GET /1/popularity/top-release-groups-for-artist/(artist_mbid)** - Get top release groups for an artist
- **POST /1/popularity/recording** - Submit recording popularity data
- **POST /1/popularity/artist** - Submit artist popularity data
- **POST /1/popularity/release** - Submit release popularity data
- **POST /1/popularity/release-group** - Submit release group popularity data

## 8. Miscellaneous

### 8.1 Art and Visualization
- **GET /1/art/grid-stats/(user_name)/** - Get grid stats for a user
- **GET /1/art/(custom_name)/** - Get custom art
- **GET /1/art/year-in-music/(year)/** - Get year in music art
- **POST /1/art/grid/** - Create grid art
- **POST /1/art/playlist/(playlist_mbid)/** - Create playlist art

### 8.2 Exploration
- **GET /1/explore/fresh-releases/** - Get fresh releases
- **GET /1/explore/color/(color)** - Get color-based exploration

### 8.3 User Settings
- **POST /1/settings/flair** - Update flair settings
- **POST /1/settings/timezone** - Update timezone settings
- **POST /1/settings/troi** - Update troi settings
- **POST /1/settings/brainzplayer** - Update BrainzPlayer settings

### 8.4 System Status
- **GET /1/donors/recent** - Get recent donors
- **GET /1/donors/biggest** - Get biggest donors
- **GET /1/donors/all-flairs** - Get all donor flairs
- **GET /1/status/get-dump-info** - Get dump info
- **GET /1/status/service-status** - Get service status
- **GET /1/status/playlist-status** - Get playlist status

## Implementation Priority

### High Priority
1. Core Listening Data (1.1, 1.2)
2. User Data and Authentication (2.1)
3. Statistics - User (5.1)
4. Recommendations (6.1)

### Medium Priority
1. Playlists - Basic Management (3.1)
2. User Feedback (4.1)
3. Metadata (7.1)
4. Social Connections (2.2)

### Low Priority
1. Playlists - Advanced Features (3.2, 3.3)
2. Pins (4.2)
3. Statistics - Sitewide (5.3)
4. Art and Visualization (8.1)
5. System Status (8.4)

## Implementation Recommendations

### Client Structure
1. **Base Client Class**: Extend the existing `Client` class with common functionality for all API interactions.
2. **Specialized Client Classes**: Create domain-specific client classes for each major category:
   - `ListenClient`: For listen submission and retrieval
     - Submit/delete listens
     - Retrieve listening history
     - Get currently playing
     - Import/export listens
   - `UserClient`: For user-related operations (already exists)
     - User authentication/validation
     - Profile information
     - User settings
     - Probably include social endpoints, too? Might belong in its own client
   - `StatisticsClient`: For statistics endpoints
     - User statistics
     - Listening activity (more bespoke stats than userclient/listenclient)
     - Non-user related ListenBrainz statistics
   - `PlaylistClient`: For playlist management
     - Exactly what you'd expect
   - `RecommendationClient`: For recommendations
     - Probably omit this for now
   - `MetadataClient`: For metadata operations
     - Also probably omit this, but:
     - Submitting metadata to ListenBrainz

### Implementation Approach
1. **Incremental Development**: Implement endpoints in priority order, starting with high-priority endpoints.
2. **Test-Driven Development**: Write tests for each endpoint before implementation.
3. **Documentation**: Document each method with YARD, following the project's documentation guidelines.
4. **Error Handling**: Implement consistent error handling across all client classes.
5. **Type Signatures**: Update the RBS type signatures in `sig/overhear.rbs` for each new method.

### Next Steps
1. Begin with extending the existing `UserClient` to add missing high-priority endpoints.
2. Create a new `ListenClient` for listen submission and management.
3. Implement the `StatisticsClient` for user statistics.
4. Add the `RecommendationClient` for personalized recommendations.

This implementation plan provides a structured approach to gradually enhance the Overhear library to support the full range of ListenBrainz API functionality while maintaining code quality and consistency.