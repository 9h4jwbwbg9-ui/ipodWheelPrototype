import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject var library: MusicLibrary
    @EnvironmentObject var player: AudioPlayerManager
    @State private var showingImporter = false
    @State private var searchText = ""

    var filteredSongs: [MusicItem] {
        guard !searchText.isEmpty else { return library.items }
        return library.items.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.artist.localizedCaseInsensitiveContains(searchText) ||
            $0.album.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if library.items.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 44))
                                .foregroundStyle(.secondary)
                            Text("No Music Yet")
                                .font(.headline)
                            Text("Import MP3s from the Files app to build your iPod library.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }
                }

                Section("Library") {
                    NavigationLink {
                        SongListView(title: "Songs", songs: filteredSongs)
                    } label: {
                        Label("Songs", systemImage: "music.note")
                    }

                    NavigationLink {
                        ArtistListView()
                    } label: {
                        Label("Artists", systemImage: "person.2")
                    }

                    NavigationLink {
                        AlbumListView()
                    } label: {
                        Label("Albums", systemImage: "square.stack")
                    }
                }

                if !filteredSongs.isEmpty {
                    Section("Recently Imported") {
                        ForEach(filteredSongs.prefix(10)) { item in
                            SongRow(item: item) {
                                player.play(item: item, library: library)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search music")
            .navigationTitle("Music")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingImporter = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Import Music")
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.audio, .mp3],
                allowsMultipleSelection: true
            ) { result in
                if case .success(let urls) = result {
                    for url in urls {
                        library.importAudio(from: url)
                    }
                }
            }
        }
    }
}

struct ArtistListView: View {
    @EnvironmentObject var library: MusicLibrary

    var body: some View {
        List(library.artists, id: \.self) { artist in
            NavigationLink(artist) {
                SongListView(title: artist, songs: library.songs(forArtist: artist))
            }
        }
        .navigationTitle("Artists")
    }
}

struct AlbumListView: View {
    @EnvironmentObject var library: MusicLibrary

    var body: some View {
        List(library.albums, id: \.self) { album in
            NavigationLink {
                SongListView(title: album, songs: library.songs(forAlbum: album))
            } label: {
                HStack(spacing: 12) {
                    let song = library.songs(forAlbum: album).first
                    ArtworkView(data: song?.artworkData, size: 52)
                    VStack(alignment: .leading) {
                        Text(album)
                        Text(song?.artist ?? "Unknown Artist")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Albums")
    }
}

struct SongListView: View {
    @EnvironmentObject var library: MusicLibrary
    @EnvironmentObject var player: AudioPlayerManager

    let title: String
    let songs: [MusicItem]

    var body: some View {
        List(songs) { item in
            SongRow(item: item) {
                player.play(item: item, library: library)
            }
        }
        .navigationTitle(title)
    }
}

struct SongRow: View {
    let item: MusicItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ArtworkView(data: item.artworkData, size: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .lineLimit(1)
                    Text("\(item.artist) • \(item.album)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "play.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary)
    }
}
