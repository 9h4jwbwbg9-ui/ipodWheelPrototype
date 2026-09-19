import SwiftUI

struct PlayerView: View {
    var navigate: (IPodDestination) -> Void = { _ in }
    @EnvironmentObject var settings: PlayerSettings
    @EnvironmentObject var library: MusicLibrary
    @EnvironmentObject var player: AudioPlayerManager

    @State private var menuOpen = false
    @State private var selectedIndex = 0
    @State private var lastAngle: Double?
    @State private var accumulatedAngle = 0.0
    @State private var wheelRotation = 0.0

    private let menuItems = ["Now Playing", "Music", "Playlists", "Artists", "Albums", "Settings"]

    var body: some View {
        ZStack {
            settings.bodyColor.ignoresSafeArea()
            VStack(spacing: 16) {
                screen
                wheel
            }
            .padding(20)
        }
    }

    private var screen: some View {
        VStack(spacing: 0) {
            HStack {
                Text(menuOpen ? "iPod" : "Now Playing")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: player.isPlaying ? "play.fill" : "pause.fill")
                    .font(.caption2)
            }
            .padding(10)
            Divider().opacity(0.25)

            if menuOpen {
                VStack(spacing: 0) {
                    ForEach(menuItems.indices, id: \.self) { i in
                        HStack {
                            Text(menuItems[i])
                            Spacer()
                            if i == selectedIndex { Image(systemName: "chevron.right") }
                        }
                        .font(.system(size: 17, weight: i == selectedIndex ? .bold : .regular, design: .rounded))
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(i == selectedIndex ? settings.highlightColor : .clear)
                        .foregroundStyle(settings.textColor)
                    }
                }
                .padding(.vertical, 5)
            } else {
                VStack(spacing: 7) {
                    ArtworkView(data: player.currentItem?.artworkData, size: 130)
                    Text(player.currentItem?.title ?? "No Song Selected")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .lineLimit(1)
                    Text(player.currentItem?.artist ?? "Import MP3s from Files")
                        .font(.system(size: 13, design: .rounded))
                        .lineLimit(1)
                    HStack {
                        Text(clock(player.progress)); Spacer(); Text(clock(player.duration))
                    }
                    .font(.system(size: 9, design: .monospaced))
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule().fill(settings.textColor.opacity(0.15))
                            Capsule().fill(settings.highlightColor)
                                .frame(width: g.size.width * CGFloat(player.duration > 0 ? player.progress / player.duration : 0))
                        }
                    }.frame(height: 5)
                }
                .padding(10)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 305)
        .background(settings.screenColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(settings.textColor.opacity(0.3)))
    }

    private func clock(_ t: TimeInterval) -> String {
        guard t.isFinite else { return "0:00" }
        return String(format: "%d:%02d", Int(t)/60, Int(t)%60)
    }

    private var wheel: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, 320)
            ZStack {
                Circle().fill(settings.wheelColor)
                    .shadow(radius: 4, y: 2)
                    .overlay(Circle().stroke(.black.opacity(0.12)))

                VStack {
                    Button("SELECT") { select() }
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(settings.textColor)
                        .frame(width: s*0.24, height: s*0.24)
                        .background(settings.wheelColor)
                        .clipShape(Circle())
                    Spacer()
                    HStack {
                        Button { menuOpen ? step(-1) : player.previous() } label: {
                            Image(systemName:"backward.fill")
                        }
                        Spacer()
                        Button("MENU") { menuOpen.toggle(); resetTouch(); soft() }
                        Spacer()
                        Button { menuOpen ? step(1) : player.next() } label: {
                            Image(systemName:"forward.fill")
                        }
                    }
                    .padding(.horizontal, s*0.13)
                    Spacer()
                    Button {
                        player.togglePlayPause()
                        soft()
                    } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    }
                }
                .font(.system(size: s*0.06, weight: .bold, design: .rounded))
                .foregroundStyle(settings.textColor)
                .padding(s*0.08)
            }
            .frame(width:s,height:s)
            .rotationEffect(.degrees(wheelRotation * 0.12))
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        let center = CGPoint(x:s/2,y:s/2)
                        let dx = value.location.x-center.x
                        let dy = value.location.y-center.y
                        let a = atan2(Double(dy),Double(dx))
                        if let last = lastAngle {
                            var d = a-last
                            if d > .pi { d -= 2 * .pi }
                            if d < -.pi { d += 2 * .pi }
                            wheelRotation += d
                            accumulatedAngle += d * settings.wheelSensitivity
                            let detent = 2 * Double.pi / 24
                            var n = 0
                            while accumulatedAngle >= detent { accumulatedAngle -= detent; n += 1 }
                            while accumulatedAngle <= -detent { accumulatedAngle += detent; n -= 1 }
                            if n != 0 { step(n) }
                        }
                        lastAngle = a
                    }
                    .onEnded { _ in resetTouch() }
            )
        }
        .frame(height:330)
    }

    private func step(_ n: Int) {
        guard menuOpen, n != 0 else {
            if !menuOpen { soft() }
            return
        }
        selectedIndex = (selectedIndex + n).modulo(menuItems.count)
        HapticManager().click(intensity: Float(settings.hapticIntensity * 0.7))
    }

    private func select() {
        guard menuOpen else {
            player.togglePlayPause()
            return
        }

        let destination: IPodDestination
        switch menuIndex {
        case 0: destination = .nowPlaying
        case 1: destination = .music
        case 2: destination = .playlists
        case 3: destination = .artists
        case 4: destination = .albums
        default: destination = .settings
        }

        menuOpen = false
        haptic.click(intensity: settings.hapticIntensity)
        navigate(destination)
    }

    private func soft() {
        HapticManager().softClick(intensity: Float(settings.hapticIntensity * 0.45))
    }

    private func resetTouch() {
        lastAngle = nil
        accumulatedAngle = 0
    }
}

private extension Int {
    func modulo(_ n: Int) -> Int {
        guard n > 0 else { return 0 }
        return ((self % n) + n) % n
    }
}
