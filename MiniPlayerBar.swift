import SwiftUI

struct MiniPlayerBar: View {
    @EnvironmentObject private var player: AudioPlayerManager

    var body: some View {
        if let item = player.currentItem {
            HStack(spacing: 10) {
                ArtworkView(data: item.artworkData, size: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(item.artist.isEmpty ? "Unknown Artist" : item.artist)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    player.togglePlayPause()
                } label: {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.thinMaterial)
        }
    }
}
