import SwiftUI

struct AlbumListView: View {
    @EnvironmentObject private var library: MusicLibrary

    var body: some View {
        List(library.albums, id: \.self) { album in
            NavigationLink {
                AlbumSongsView(album: album)
            } label: {
                HStack(spacing: 12) {
                    if let item = library.songs(forAlbum: album).first {
                        ArtworkView(data: item.artworkData, size: 48)
                    }
                    Text(album)
                }
            }
        }
        .navigationTitle("Albums")
    }
}

struct AlbumSongsView: View {
    let album: String
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var player: AudioPlayerManager

    var body: some View {
        List(library.songs(forAlbum: album)) { item in
            Button {
                player.play(item: item, library: library, queue: library.songs(forAlbum: album))
            } label: {
                SongRow(item: item)
            }
            .buttonStyle(.plain)
        }
        .navigationTitle(album)
    }
}
