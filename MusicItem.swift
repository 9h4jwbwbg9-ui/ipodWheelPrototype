import Foundation
import AVFoundation

struct MusicItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var artist: String
    var album: String
    var fileName: String
    var duration: TimeInterval
    var artworkData: Data?

    init(
        id: UUID = UUID(),
        title: String,
        artist: String = "Unknown Artist",
        album: String = "Unknown Album",
        fileName: String,
        duration: TimeInterval = 0,
        artworkData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.fileName = fileName
        self.duration = duration
        self.artworkData = artworkData
    }
}
