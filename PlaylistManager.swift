import Foundation
import Combine

@MainActor
final class PlaylistManager: ObservableObject {
    @Published private(set) var playlists: [MusicPlaylist] = []

    private let key = "ipod.playlists"

    init() { load() }

    func create(name: String) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        playlists.append(MusicPlaylist(name: clean))
        save()
    }

    func delete(at offsets: IndexSet) {
        playlists.remove(atOffsets: offsets)
        save()
    }

    func add(_ item: MusicItem, to playlist: MusicPlaylist) {
        guard let index = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        guard !playlists[index].trackIDs.contains(item.id) else { return }
        playlists[index].trackIDs.append(item.id)
        save()
    }

    func remove(_ item: MusicItem, from playlist: MusicPlaylist) {
        guard let index = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        playlists[index].trackIDs.removeAll { $0 == item.id }
        save()
    }

    func items(in playlist: MusicPlaylist, library: MusicLibrary) -> [MusicItem] {
        playlist.trackIDs.compactMap { id in library.items.first(where: { $0.id == id }) }
    }

    private func load() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(key + ".json")
        guard let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode([MusicPlaylist].self, from: data) else { return }
        playlists = value
    }

    private func save() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(key + ".json")
        if let data = try? JSONEncoder().encode(playlists) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
