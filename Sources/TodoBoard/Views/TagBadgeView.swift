import SwiftUI

struct TagBadgeView: View {
    let tag: TagDefinition
    let showRemove: Bool

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: tag.color), Color(hex: tag.color).opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 7, height: 7)
            Text(tag.name)
                .font(.system(size: 11, weight: .medium))
            if showRemove {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color(hex: tag.color).opacity(0.12))
        .overlay(
            Capsule()
                .strokeBorder(Color(hex: tag.color).opacity(0.2), lineWidth: 0.5)
        )
        .clipShape(Capsule())
        .fixedSize()
    }
}
