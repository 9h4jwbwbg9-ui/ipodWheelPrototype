import SwiftUI

struct PlaylistView: View {
    @EnvironmentObject var playlists: PlaylistManager
    @EnvironmentObject var library: MusicLibrary
    @EnvironmentObject var player: AudioPlayerManager
    @State private var showingNew = false
    @State private var newName = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(playlists.playlists) { playlist in
                    NavigationLink {
                        PlaylistDetailView(playlist: playlist)
                    } label: {
                        Label("\(playlist.name) (\(playlists.items(in: playlist, library: library).count))",
                              systemImage: "music.note.list")
                    }
                }
                .onDelete(perform: playlists.delete)
            }
            .navigationTitle("Playlists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNew = true } label: { Image(systemName: "plus") }
                }
            }
            .alert("New Playlist", isPresented: $showingNew) {
                TextField("Playlist Name", text: $newName)
                Button("Create") {
                    playlists.create(name: newName)
                    newName = ""
                }
                Button("Cancel", role: .cancel) { newName = "" }
            }
        }
    }
}

struct PlaylistDetailView: View {
    @EnvironmentObject var playlists: PlaylistManager
    @EnvironmentObject var library: MusicLibrary
    @EnvironmentObject var player: AudioPlayerManager

    let playlist: MusicPlaylist

    var songs: [MusicItem] {
        playlists.items(in: playlist, library: library)
    }

    var body: some View {
        List(songs) { item in
            SongRow(item: item) {
                player.play(item: item, library: library, queue: songs)
            }
        }
        .navigationTitle(playlist.name)
    }
}
