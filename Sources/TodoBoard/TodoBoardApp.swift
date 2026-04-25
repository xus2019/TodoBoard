import SwiftUI

@main
struct TodoBoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var storage: WorkspaceStorage
    @StateObject private var themeManager: ThemeManager
    @StateObject private var workspaceViewModel: WorkspaceViewModel

    init() {
        let config = AppConfig.default
        let storage = WorkspaceStorage(dataDirectory: URL(fileURLWithPath: config.dataDirectory))
        let themeManager = ThemeManager(config: storage.loadConfig())
        _storage = StateObject(wrappedValue: storage)
        _themeManager = StateObject(wrappedValue: themeManager)
        _workspaceViewModel = StateObject(
            wrappedValue: WorkspaceViewModel(storage: storage, themeManager: themeManager)
        )
    }

    var body: some Scene {
        WindowGroup {
            MainBoardView(viewModel: workspaceViewModel, themeManager: themeManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)

        Settings {
            SettingsView(themeManager: themeManager, storage: storage, workspaceViewModel: workspaceViewModel)
        }
    }
}
