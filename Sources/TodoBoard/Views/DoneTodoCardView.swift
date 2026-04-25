import SwiftUI

struct DoneTodoCardView: View {
    @ObservedObject var todo: TodoItem
    let themeManager: ThemeManager
    let onToggleDone: () -> Void
    let onOpenEditor: () -> Void
    let onSave: () -> Void
    var isHighlighted: Bool = false

    @State private var isExpanded = false
    @State private var isHovered = false
    @State private var flashOpacity: Double = 0

    private var cornerRadius: CGFloat {
        themeManager.currentTheme.cardCornerRadius
    }

    private var shadowStyle: (color: Color, radius: CGFloat, y: CGFloat) {
        switch themeManager.cardStyle {
        case .flat:
            (.clear, 0, 0)
        case .shadow:
            (.black.opacity(isHovered ? 0.14 : 0.08), isHovered ? 10 : 6, isHovered ? 4 : 2)
        case .glass:
            (.black.opacity(0.03), 2, 1)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Button(action: onToggleDone) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green.opacity(0.7))
                }
                .buttonStyle(.plain)
                .padding(.top, 2)

                Text(todo.title)
                    .strikethrough()
                    .foregroundStyle(themeManager.textDone)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if todo.hasContent {
                    Image(systemName: "note.text")
                        .font(.system(size: 10))
                        .foregroundStyle(themeManager.textSecondary.opacity(0.5))
                        .padding(.top, 4)
                }

                if let doneAt = todo.doneAt {
                    Text(DateFormatters.relativeDone(for: doneAt))
                        .font(.caption)
                        .foregroundStyle(themeManager.textSecondary.opacity(0.6))
                        .padding(.top, 2)
                }
            }

            if isExpanded {
                doneContentEditor
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .background { doneCardBackground }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    themeManager.isDark
                        ? Color.white.opacity(0.04)
                        : Color.black.opacity(0.03),
                    lineWidth: 0.5
                )
        )
        .shadow(
            color: shadowStyle.color,
            radius: shadowStyle.radius,
            y: shadowStyle.y
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(themeManager.accentColor.opacity(flashOpacity))
        )
        .onAppear {
            if isHighlighted {
                triggerFlash()
            }
        }
        .onChange(of: isHighlighted) { _, highlighted in
            guard highlighted else { return }
            triggerFlash()
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                let willCollapse = isExpanded
                isExpanded.toggle()
                if willCollapse {
                    onSave()
                }
            }
        }
        .onHover { isHovered = $0 }
        .onDisappear {
            if isExpanded {
                onSave()
            }
        }
    }

    @ViewBuilder
    private var doneContentEditor: some View {
        TextEditor(text: $todo.content)
            .font(.system(size: themeManager.fontSize - 1))
            .foregroundStyle(themeManager.textDone)
            .scrollContentBackground(.hidden)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(themeManager.isDark ? Color.white.opacity(0.03) : Color.black.opacity(0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(themeManager.isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.04), lineWidth: 0.5)
            )
            .frame(minHeight: 96)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func triggerFlash() {
        flashOpacity = 0
        withAnimation(.easeInOut(duration: 0.3)) { flashOpacity = 0.3 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) { flashOpacity = 0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.3)) { flashOpacity = 0.3 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0.3)) { flashOpacity = 0 }
        }
    }

    @ViewBuilder
    private var doneCardBackground: some View {
        if themeManager.useGlassMaterial {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(themeManager.doneCardBackground.opacity(themeManager.glassOverlayOpacity))
                )
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(themeManager.doneCardBackground)
        }
    }
}
