import SwiftUI

struct TodoCardView: View {
    @ObservedObject var todo: TodoItem
    let themeManager: ThemeManager
    let onToggleDone: () -> Void
    let onSave: () -> Void
    let availableTags: [TagDefinition]
    let onToggleTag: (String) -> Void
    var isHighlighted: Bool = false

    @State private var isExpanded = false
    @State private var isHovered = false
    @State private var showTagPicker = false
    @State private var showFullContent = false
    @State private var flashOpacity: Double = 0

    private var cornerRadius: CGFloat {
        themeManager.currentTheme.cardCornerRadius
    }

    private var shadowStyle: (color: Color, radius: CGFloat, y: CGFloat) {
        switch themeManager.cardStyle {
        case .flat:
            (.clear, 0, 0)
        case .shadow:
            (.black.opacity(isHovered ? 0.18 : 0.1), isHovered ? 14 : 8, isHovered ? 6 : 3)
        case .glass:
            (.black.opacity(isHovered ? 0.12 : 0.05), isHovered ? 8 : 3, isHovered ? 3 : 1)
        }
    }

    private var firstTagColor: Color? {
        guard let tag = todo.tags.first else { return nil }
        return themeManager.tagColor(for: tag)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left accent bar
            if let color = firstTagColor {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color)
                    .frame(width: 3)
                    .padding(.vertical, 6)
                    .padding(.leading, 4)
            }

            HStack(alignment: .top, spacing: 8) {
                Button(action: onToggleDone) {
                    Image(systemName: "circle")
                        .foregroundStyle(themeManager.textSecondary)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)

                VStack(alignment: .leading, spacing: 8) {
                    // Title row
                    titleRow

                    // Tags always visible below title (or "+" button when expanded)
                    if !todo.tags.isEmpty || isExpanded {
                        tagsRow
                    }

                    // Expanded content
                    if isExpanded {
                        expandedContent
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(12)
        }
        .background { cardBackground }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    themeManager.isDark
                        ? Color.white.opacity(isHovered ? 0.12 : 0.06)
                        : Color.black.opacity(isHovered ? 0.08 : 0.04),
                    lineWidth: 0.5
                )
        )
        .shadow(
            color: shadowStyle.color,
            radius: shadowStyle.radius,
            y: shadowStyle.y
        )
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .contentShape(Rectangle())
        .draggable(
            TodoDragData(
                todoId: todo.id,
                sourceProjectId: todo.project?.id.uuidString.lowercased() ?? ""
            )
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
                if !isExpanded {
                    showFullContent = false
                    onSave()
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(themeManager.accentColor.opacity(flashOpacity))
        )
        .onChange(of: isHighlighted) { _, highlighted in
            guard highlighted else { return }
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
        .onHover { isHovered = $0 }
        .onDisappear {
            if isExpanded {
                onSave()
            }
        }
        .sheet(isPresented: $showTagPicker) {
            TagPickerView(
                availableTags: availableTags,
                selected: Set(todo.tags),
                onToggle: onToggleTag
            )
        }
    }

    // MARK: - Title Row

    private var titleRow: some View {
        HStack(alignment: .top, spacing: 8) {
            WrappingTitleField(
                placeholder: "",
                text: $todo.title,
                font: themeManager.nsFont(size: themeManager.fontSize, weight: .medium),
                textColor: NSColor(themeManager.textPrimary),
                onSubmit: onSave
            )

            Spacer()

            if todo.hasContent {
                Image(systemName: "note.text")
                    .font(.system(size: 11))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.7))
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                    if !isExpanded {
                        showFullContent = false
                        onSave()
                    }
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(themeManager.textSecondary)
            }
            .buttonStyle(.plain)
            .opacity(isHovered || isExpanded ? 1 : 0)
            .animation(.easeOut(duration: 0.15), value: isHovered)
        }
    }

    // MARK: - Tags Row (always visible)

    private var tagsRow: some View {
        FlowLayout(spacing: 4) {
            ForEach(todo.tags.prefix(isExpanded ? todo.tags.count : 3), id: \.self) { tag in
                if isExpanded {
                    Button {
                        onToggleTag(tag)
                    } label: {
                        TagBadgeView(tag: TagDefinition(name: tag, color: themeManager.tagColor(for: tag).hexString ?? "#4A90D9"), showRemove: true)
                    }
                    .buttonStyle(.plain)
                } else {
                    TagBadgeView(tag: TagDefinition(name: tag, color: themeManager.tagColor(for: tag).hexString ?? "#4A90D9"), showRemove: false)
                }
            }
            if isExpanded {
                Button {
                    showTagPicker = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(themeManager.textSecondary.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Inline content editor
            contentEditor
        }
    }

    @ViewBuilder
    private var contentEditor: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextEditor(text: $todo.content)
                .font(.system(size: themeManager.fontSize - 1))
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
                .frame(minHeight: 116, maxHeight: showFullContent ? .infinity : 116)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            if !showFullContent && todo.content.count > 200 {
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showFullContent = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("查看更多")
                            .font(.system(size: 11, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(themeManager.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Card Background

    @ViewBuilder
    private var cardBackground: some View {
        if themeManager.useGlassMaterial {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill((isHovered ? themeManager.cardHoverBackground : themeManager.cardBackground).opacity(themeManager.glassOverlayOpacity))
                )
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isHovered ? themeManager.cardHoverBackground : themeManager.cardBackground)
        }
    }
}
