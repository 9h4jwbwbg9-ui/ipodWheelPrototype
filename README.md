# iPod Wheel Prototype

A native SwiftUI iPhone prototype for the retro iPod-style MP3 player concept.

Included:
- Rotating click-wheel gesture
- Menu / previous / next / play-pause / center controls
- Adjustable haptic intensity
- Adjustable wheel sensitivity
- Body, wheel, screen, text, and highlight colors
- A simple Now Playing screen
- Placeholder library data

Next implementation step:
- Import MP3s through the iOS Files document picker
- Read ID3 metadata and album artwork
- Build the persistent music library
- Add background audio and lock-screen controls

Open `iPodWheelPrototype.xcodeproj` in Xcode on a Mac, select an iPhone simulator/device, and Run.


## v3 additions
- Classic iPod-style on-screen menu
- Wheel rotation moves through menu selections
- MENU opens the menu; SELECT returns to the player
- Previous/next wheel buttons operate on imported tracks
- Now Playing screen reflects the active imported track

## v4
- Persistent color, haptic, and wheel-sensitivity settings.
- Theme presets: Classic White, Classic Black, Blue, Green Screen, Amber.
- Background audio mode enabled.

## v5
- Embedded album artwork is extracted from imported audio metadata when available.
- Music browser now has Songs, Artists, Albums, and search.
- Multiple audio files can be imported at once.
- Album artwork thumbnails appear throughout the music library.
- Library metadata remains persistent between launches.

## v6
- Persistent playlists with create/delete/add/remove track support.
- Shuffle, repeat off/all/one, next/previous, and queue-aware playback engine.
- Lock Screen / Control Center play, pause, next, previous, and seek commands.
- Album artwork is supplied to the Now Playing info center.
- New PlaylistView and PlaylistDetailView screens.

## v7
- Detent-based wheel scrolling with 24 virtual click positions.
- Angular wrap-around handling for smooth circular gestures.
- Adjustable wheel sensitivity and haptic intensity remain supported.
- Stronger physical-style click feedback and integrated wheel controls.


## v8 navigation
The click-wheel menu now opens real sections:
- Now Playing
- Music / Songs
- Playlists
- Artists
- Albums
- Settings / Customization

Artist and album lists drill down to their songs, and selecting a song starts playback.

## v9 click-wheel refinement
- Shared circular click-wheel physics with 24 virtual detents.
- Proper angle wraparound and sensitivity scaling.
- Wheel accumulator resets cleanly between gestures.
- Added a reusable compact Now Playing control for later navigation polish.
