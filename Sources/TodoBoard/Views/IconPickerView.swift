import SwiftUI

struct IconPickerView: View {
    let currentIcon: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private static let icons: [(category: String, icons: [String])] = [
        ("常用", [
            "folder.fill", "doc.fill", "book.fill", "star.fill",
            "heart.fill", "flag.fill", "bookmark.fill", "tag.fill",
        ]),
        ("工具", [
            "wrench.and.screwdriver.fill", "hammer.fill", "gearshape.fill", "cpu.fill",
            "terminal.fill", "externaldrive.fill", "network", "server.rack",
        ]),
        ("交通", [
            "airplane", "car.fill", "bus.fill", "tram.fill",
            "bicycle", "figure.walk", "sailboat.fill", "fuelpump.fill",
        ]),
        ("通讯", [
            "envelope.fill", "phone.fill", "bubble.left.fill", "video.fill",
            "antenna.radiowaves.left.and.right", "wifi", "globe", "link",
        ]),
        ("创意", [
            "paintbrush.fill", "pencil.and.outline", "camera.fill", "music.note",
            "film", "theatermasks.fill", "puzzlepiece.fill", "lightbulb.fill",
        ]),
        ("学习", [
            "graduationcap.fill", "books.vertical.fill", "brain.head.profile", "atom",
            "function", "chart.bar.fill", "flask.fill", "testtube.2",
        ]),
        ("生活", [
            "house.fill", "cart.fill", "cup.and.saucer.fill", "fork.knife",
            "gift.fill", "tshirt.fill", "leaf.fill", "pawprint.fill",
        ]),
        ("运动", [
            "sportscourt.fill", "figure.run", "dumbbell.fill", "trophy.fill",
            "medal.fill", "soccerball", "basketball.fill", "tennisball.fill",
        ]),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择图标")
                .font(.system(size: 14, weight: .semibold))

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Self.icons, id: \.category) { group in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(group.category)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)

                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(36), spacing: 6), count: 8), spacing: 6) {
                                ForEach(group.icons, id: \.self) { icon in
                                    Button {
                                        onSelect(icon)
                                        dismiss()
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.system(size: 16))
                                            .frame(width: 36, height: 36)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(icon == currentIcon ? Color.accentColor.opacity(0.2) : Color.clear)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .strokeBorder(icon == currentIcon ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 360, height: 400)
    }
}
