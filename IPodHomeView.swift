import SwiftUI

enum IPodDestination: Hashable {
    case nowPlaying
    case music
    case playlists
    case artists
    case albums
    case settings
}

struct IPodHomeView: View {
    @State private var path: [IPodDestination] = []

    @StateObject private var library = MusicLibrary()
    @StateObject private var player = AudioPlayerManager()
    @StateObject private var settings = PlayerSettings()
    @StateObject private var playlists = PlaylistManager()

    var body: some View {
        NavigationStack(path: $path) {
            PlayerView(navigate: navigate)
                .navigationDestination(for: IPodDestination.self) { destination in
                    destinationView(destination)
                }
        }
        .environmentObject(library)
        .environmentObject(player)
        .environmentObject(settings)
        .environmentObject(playlists)
        .onAppear {
            player.configure(library: library)
        }
    }

    private func navigate(_ destination: IPodDestination) {
        if destination == .nowPlaying {
            path.removeAll()
        } else {
            path.append(destination)
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: IPodDestination) -> some View {
        switch destination {
        case .nowPlaying:
            PlayerView(navigate: navigate)
        case .music:
            LibraryView()
        case .playlists:
            PlaylistView()
        case .artists:
            ArtistListView()
        case .albums:
            AlbumListView()
        case .settings:
            CustomizationView()
        }
    }
}
