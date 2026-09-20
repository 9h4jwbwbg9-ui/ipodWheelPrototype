import SwiftUI

struct ArtistListView: View {
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var player: AudioPlayerManager

    var body: some View {
        List(library.artists, id: \.self) { artist in
            NavigationLink(artist) {
                ArtistSongsView(artist: artist)
            }
        }
        .navigationTitle("Artists")
    }
}

struct ArtistSongsView: View {
    let artist: String
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var player: AudioPlayerManager

    var body: some View {
        List(library.songs(forArtist: artist)) { item in
            Button {
                player.play(item: item, library: library, queue: library.songs(forArtist: artist))
            } label: {
                SongRow(item: item) {
    player.play(item: item, library: library, queue: library.songs(forArtist: artist))
}
            }
            .buttonStyle(.plain)
        }
        .navigationTitle(artist)
    }
}
