import SwiftUI

enum IPodSection: String, CaseIterable, Identifiable {
    case nowPlaying = "Now Playing"
    case music = "Music"
    case artists = "Artists"
    case albums = "Albums"
    case playlists = "Playlists"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .nowPlaying: return "play.circle"
        case .music: return "music.note.list"
        case .artists: return "person.2"
        case .albums: return "square.stack"
        case .playlists: return "list.bullet"
        case .settings: return "gearshape"
        }
    }
}

struct IPodMenuView: View {
    @EnvironmentObject private var settings: PlayerSettings
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var audio: AudioPlayerManager

    @Binding var selected: IPodSection

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("iPod")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                if audio.isPlaying {
                    Image(systemName: "play.fill")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(IPodSection.allCases) { item in
                            Button {
                                selected = item
                            } label: {
                                HStack {
                                    Image(systemName: item.icon)
                                        .frame(width: 24)
                                    Text(item.rawValue)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .font(.system(size: 15, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .foregroundStyle(item == selected ? .white : settings.textColor)
                                .background(item == selected ? settings.highlightColor : .clear)
                            }
                            .id(item.id)
                        }
                    }
                }
            }
        }
        .background(settings.screenColor)
        .foregroundStyle(settings.textColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.3), lineWidth: 2))
    }
}
