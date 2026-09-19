import Foundation
import AVFoundation
import SwiftUI

@MainActor
final class MusicLibrary: ObservableObject {
    @Published private(set) var items: [MusicItem] = []

    private let metadataFile = "music-library.json"

    init() {
        load()
    }

    var artists: [String] {
        Array(Set(items.map(\.artist))).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var albums: [String] {
        Array(Set(items.map(\.album))).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    func songs(forArtist artist: String) -> [MusicItem] {
        items.filter { $0.artist == artist }.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func songs(forAlbum album: String) -> [MusicItem] {
        items.filter { $0.album == album }.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func importAudio(from url: URL) {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
        }

        do {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let ext = url.pathExtension.isEmpty ? "mp3" : url.pathExtension
            let destination = documents.appendingPathComponent("\(UUID().uuidString).\(ext)")

            try FileManager.default.copyItem(at: url, to: destination)

            let asset = AVURLAsset(url: destination)
            let metadata = asset.commonMetadata

            let title = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierTitle)
                .first?.stringValue ?? url.deletingPathExtension().lastPathComponent

            let artist = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierArtist)
                .first?.stringValue ?? "Unknown Artist"

            let album = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierAlbumName)
                .first?.stringValue ?? "Unknown Album"

            let duration = asset.duration.seconds.isFinite ? asset.duration.seconds : 0
            let artworkData = extractArtwork(from: asset)

            let item = MusicItem(
                title: title,
                artist: artist,
                album: album,
                fileName: destination.lastPathComponent,
                duration: duration,
                artworkData: artworkData
            )

            items.append(item)
            items.sort {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
            save()
        } catch {
            print("Import failed:", error)
        }
    }

    func url(for item: MusicItem) -> URL? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(item.fileName)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    private func extractArtwork(from asset: AVAsset) -> Data? {
        for item in asset.metadata {
            guard let key = item.commonKey?.rawValue,
                  key == "artwork",
                  let value = item.value else { continue }

            if let data = value as? Data {
                return data
            }
        }
        return nil
    }

    private func load() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(metadataFile)

        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([MusicItem].self, from: data) else {
            items = []
            return
        }
        items = decoded
    }

    private func save() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(metadataFile)

        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
