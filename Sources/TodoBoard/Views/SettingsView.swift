import SwiftUI

private enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case appearance
    case ambience
    case tags
    case data

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:    "通用"
        case .appearance: "外观"
        case .ambience:   "氛围"
        case .tags:       "标签"
        case .data:       "数据"
        }
    }

    var icon: String {
        switch self {
        case .general:    "gearshape"
        case .appearance: "paintbrush.fill"
        case .ambience:   "sparkles"
        case .tags:       "tag.fill"
        case .data:       "folder.fill"
        }
    }
}

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var storage: WorkspaceStorage
    @ObservedObject var workspaceViewModel: WorkspaceViewModel

    @State private var config = AppConfig.default
    @State private var selectedSection: SettingsSection = .general
    @StateObject private var updateChecker = UpdateChecker()

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            detailPanel
        }
        .frame(width: 720, height: 520)
        .onAppear {
            config = storage.loadConfig()
        }
        .onDisappear {
            save()
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("设置")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

            ForEach(SettingsSection.allCases) { section in
                sidebarItem(section)
            }

            Spacer()
        }
        .frame(width: 180)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }

    private func sidebarItem(_ section: SettingsSection) -> some View {
        Button {
            selectedSection = section
        } label: {
            HStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.system(size: 13))
                    .frame(width: 18)
                    .foregroundStyle(selectedSection == section ? .primary : .secondary)
                Text(section.title)
                    .font(.system(size: 13))
                    .foregroundStyle(selectedSection == section ? .primary : .secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(selectedSection == section
                          ? Color.accentColor.opacity(0.12)
                          : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }

    // MARK: - Detail Panel

    private var detailPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(selectedSection.title)
                    .font(.title2.bold())
                    .padding(.bottom, 20)

                Group {
                    switch selectedSection {
                    case .general:    generalSection
                    case .appearance: appearanceSection
                    case .ambience:   ambienceSection
                    case .tags:       tagsSection
                    case .data:       dataSection
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - General Section

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            settingsRow("外观模式") {
                Picker("", selection: $themeManager.appearance) {
                    Text("浅色").tag(Appearance.light)
                    Text("深色").tag(Appearance.dark)
                    Text("跟随系统").tag(Appearance.system)
                }
                .labelsHidden()
                .frame(width: 160)
            }

            Divider()

            settingsRow("主题") {
                Picker("", selection: Binding(
                    get: { themeManager.currentTheme.name },
                    set: { themeManager.applyTheme($0) }
                )) {
                    Text("Moonlight").tag("moonlight")
                    Text("Daylight").tag("daylight")
                    Text("Solarized").tag("solarized")
                    Text("Minimal").tag("minimal")
                }
                .labelsHidden()
                .frame(width: 160)
            }

            Divider()

            settingsRow("强调色") {
                ColorPicker("", selection: $themeManager.customAccentColor, supportsOpacity: false)
                    .labelsHidden()
            }

            Divider()

            updateSection
        }
    }

    // MARK: - Update Section

    private var updateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("检查更新")
                        .font(.system(size: 13, weight: .medium))
                    Text("当前版本 \(updateChecker.currentVersion)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    Task { await updateChecker.checkForUpdates() }
                } label: {
                    if updateChecker.state == .checking {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text("检查中...")
                        }
                    } else {
                        Text("检查更新")
                    }
                }
                .disabled(updateChecker.state == .checking)
                .frame(width: 96)
            }

            switch updateChecker.state {
            case .idle:
                EmptyView()
            case .checking:
                EmptyView()
            case .upToDate:
                Label("已是最新版本", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.green)
            case .updateAvailable(let version, let url):
                HStack(spacing: 8) {
                    Label("发现新版本 \(version)", systemImage: "arrow.down.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.accentColor)
                    Spacer()
                    Button("前往下载") {
                        NSWorkspace.shared.open(url)
                    }
                    .controlSize(.small)
                }
            case .failed(let message):
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            settingsRow("卡片风格") {
                Picker("", selection: $themeManager.cardStyle) {
                    Text("毛玻璃").tag(CardStyle.glass)
                    Text("扁平").tag(CardStyle.flat)
                    Text("投影").tag(CardStyle.shadow)
                }
                .labelsHidden()
                .frame(width: 160)
            }

            if themeManager.cardStyle == .glass {
                Divider()
                settingsSlider("毛玻璃透明度", value: $themeManager.materialOpacity, range: 0...1, format: "%d%%") { Int($0 * 100) }
            }

            Divider()

            settingsRow("字体") {
                Picker("", selection: $themeManager.fontFamily) {
                    Text("SF Pro").tag("SF Pro")
                    Text("SF Mono").tag("SF Mono")
                    Text("Menlo").tag("Menlo")
                    Text("系统默认").tag("System")
                }
                .labelsHidden()
                .frame(width: 160)
            }

            Divider()

            settingsSlider("字号", value: $themeManager.fontSize, range: 12...20, format: "%.0f pt") { $0 }

            Divider()

            settingsSlider("列宽", value: $themeManager.columnWidth, range: 240...400, format: "%d pt") { Int($0) }
        }
    }

    // MARK: - Ambience Section

    private var ambienceSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            settingsRow("氛围效果") {
                Picker("", selection: $themeManager.ambience) {
                    ForEach(AmbienceEffect.allCases, id: \.self) { effect in
                        Text(effect.displayName).tag(effect)
                    }
                }
                .labelsHidden()
                .frame(width: 160)
            }

            if themeManager.ambience != .none {
                Divider()
                settingsSlider("粒子密度", value: $themeManager.ambienceDensity, range: 0.2...2.0, format: "%d%%") { Int($0 * 100) }
            }

            Text("切换后主窗口会实时预览。")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(tagEntries, id: \.name) { entry in
                HStack(spacing: 12) {
                    TextField("标签名", text: Binding(
                        get: { entry.name },
                        set: { newValue in
                            renameTag(from: entry.name, to: newValue)
                        }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)

                    ColorPicker("", selection: Binding(
                        get: { Color(hex: config.tagColors[entry.name] ?? "#4A90D9") },
                        set: { newColor in
                            config.tagColors[entry.name] = newColor.hexString ?? "#4A90D9"
                        }
                    ), supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 44)

                    Button(role: .destructive) {
                        config.tagColors.removeValue(forKey: entry.name)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red.opacity(0.7))
                    }
                    .buttonStyle(.borderless)

                    Spacer()
                }
            }

            Button {
                config.tagColors["新标签\(config.tagColors.count + 1)"] = "#4A90D9"
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                    Text("新增标签")
                }
                .font(.system(size: 13))
            }
            .buttonStyle(.borderless)
            .padding(.top, 4)
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("数据目录")
                    .font(.system(size: 13, weight: .medium))
                Text(config.dataDirectory)
                    .font(.system(size: 12).monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                Button("选择目录") {
                    chooseDataDirectory()
                }
                .controlSize(.small)
            }

            Divider()

            settingsRow("默认归档分组") {
                Picker("", selection: $config.defaultArchiveGroupBy) {
                    Text("按周").tag(ArchiveGroupBy.week)
                    Text("按月").tag(ArchiveGroupBy.month)
                    Text("全部").tag(ArchiveGroupBy.all)
                }
                .labelsHidden()
                .frame(width: 160)
            }
        }
    }

    // MARK: - Shared Components

    private func settingsRow<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Spacer()
            content()
        }
    }

    private func settingsSlider<V: Numeric>(_ title: String, value: Binding<Double>, range: ClosedRange<Double>, format: String, display: @escaping (Double) -> V) -> some View where V: CVarArg {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text(String(format: format, display(value.wrappedValue)))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .font(.system(size: 12))
            }
            Slider(value: value, in: range)
        }
    }

    private func settingsSlider(_ title: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, format: String, display: @escaping (CGFloat) -> any CVarArg) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text(String(format: format, display(value.wrappedValue)))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .font(.system(size: 12))
            }
            Slider(value: value, in: range)
        }
    }

    // MARK: - Actions

    private func save() {
        var updatedConfig = themeManager.saveToConfig()
        updatedConfig.tagColors = config.tagColors
        updatedConfig.defaultArchiveGroupBy = config.defaultArchiveGroupBy
        updatedConfig.dataDirectory = config.dataDirectory
        storage.saveConfig(updatedConfig)
        themeManager.applySavedConfig(updatedConfig)
        workspaceViewModel.updateAppConfig(updatedConfig)
        config = updatedConfig
    }

    private var tagEntries: [(name: String, color: String)] {
        config.tagColors.keys.sorted().map { ($0, config.tagColors[$0] ?? "#4A90D9") }
    }

    private func renameTag(from oldName: String, to newName: String) {
        let trimmedName = newName.trimmed
        guard !trimmedName.isEmpty, trimmedName != oldName, let value = config.tagColors[oldName] else {
            return
        }
        config.tagColors.removeValue(forKey: oldName)
        config.tagColors[trimmedName] = value
    }

    private func chooseDataDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        config.dataDirectory = url.path
    }
}
