import Foundation
import AVFoundation
import MediaPlayer
import UIKit
import Combine

@MainActor
final class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var currentItem: MusicItem?
    @Published private(set) var isPlaying = false
    @Published private(set) var progress: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var shuffleEnabled = false
    @Published var repeatMode: RepeatMode = .off

    private var player: AVAudioPlayer?
    private var queue: [MusicItem] = []
    private var currentIndex = 0
    private weak var library: MusicLibrary?
    private var timer: Timer?

    override init() {
        super.init()
        configureAudioSession()
        configureRemoteCommands()
    }

    func play(item: MusicItem, library: MusicLibrary, queue: [MusicItem]? = nil) {
        self.library = library
        self.queue = queue ?? library.items
        if let idx = self.queue.firstIndex(of: item) {
            currentIndex = idx
        } else {
            self.queue = [item]
            currentIndex = 0
        }
        startCurrent()
    }

    func togglePlayPause() {
        guard let player else { return }
        if player.isPlaying { pause() } else { resume() }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlaying()
    }

    func resume() {
        guard player != nil else { return }
        try? AVAudioSession.sharedInstance().setActive(true)
        player?.play()
        isPlaying = true
        updateNowPlaying()
    }

    func next() {
        guard !queue.isEmpty else { return }
        if shuffleEnabled {
            currentIndex = Int.random(in: 0..<queue.count)
        } else if currentIndex + 1 < queue.count {
            currentIndex += 1
        } else if repeatMode == .all {
            currentIndex = 0
        } else {
            pause()
            return
        }
        startCurrent()
    }

    func previous() {
        guard !queue.isEmpty else { return }
        if progress > 3 {
            player?.currentTime = 0
            progress = 0
            updateNowPlaying()
            return
        }
        currentIndex = max(0, currentIndex - 1)
        startCurrent()
    }

    func seek(to value: TimeInterval) {
        player?.currentTime = max(0, min(value, duration))
        progress = player?.currentTime ?? 0
        updateNowPlaying()
    }

    private func startCurrent() {
        guard queue.indices.contains(currentIndex),
              let url = library?.url(for: queue[currentIndex]) else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            currentItem = queue[currentIndex]
            duration = player?.duration ?? currentItem?.duration ?? 0
            progress = 0
            isPlaying = true
            updateNowPlaying()
            startTimer()
        } catch {
            print("Playback failed:", error)
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.player else { return }
                self.progress = player.currentTime
                self.duration = player.duration
                self.updateNowPlaying()
            }
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if repeatMode == .one {
            startCurrent()
        } else {
            next()
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Audio session:", error)
        }
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.isEnabled = true
        center.pauseCommand.isEnabled = true
        center.nextTrackCommand.isEnabled = true
        center.previousTrackCommand.isEnabled = true
        center.changePlaybackPositionCommand.isEnabled = true

        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.resume() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.next() }
            return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.previous() }
            return .success
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            Task { @MainActor in self?.seek(to: event.positionTime) }
            return .success
        }
    }

    private func updateNowPlaying() {
        guard let item = currentItem else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: item.title,
            MPMediaItemPropertyArtist: item.artist,
            MPMediaItemPropertyAlbumTitle: item.album,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: progress,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        if let data = item.artworkData, let image = UIImage(data: data) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
