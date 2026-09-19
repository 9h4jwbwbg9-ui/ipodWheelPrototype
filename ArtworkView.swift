import SwiftUI

struct ArtworkView: View {
    let data: Data?
    var size: CGFloat = 180

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Rectangle()
                        .fill(.secondary.opacity(0.16))
                    Image(systemName: "music.note")
                        .font(.system(size: size * 0.28))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.06))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.06)
                .stroke(.primary.opacity(0.12), lineWidth: 1)
        )
    }
}
