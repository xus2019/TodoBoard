import Foundation

@MainActor
final class UpdateChecker: ObservableObject {

    enum State: Equatable {
        case idle
        case checking
        case upToDate
        case updateAvailable(latestVersion: String, releaseURL: URL)
        case failed(message: String)
    }

    @Published private(set) var state: State = .idle

    let currentVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }()

    private let apiURL = URL(string: "https://api.github.com/repos/xus2019/TodoBoard/releases/latest")!

    func checkForUpdates() async {
        guard state != .checking else { return }
        state = .checking

        do {
            var request = URLRequest(url: apiURL)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                state = .failed(message: "服务器返回错误，请稍后重试")
                return
            }

            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            let latestVersion = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "v"))

            if isNewerVersion(latestVersion, than: currentVersion),
               let releaseURL = URL(string: release.htmlURL) {
                state = .updateAvailable(latestVersion: latestVersion, releaseURL: releaseURL)
            } else {
                state = .upToDate
            }
        } catch {
            state = .failed(message: "检查失败：\(error.localizedDescription)")
        }
    }

    // MARK: - Semantic Version Comparison

    /// Returns true if `newer` is strictly greater than `current`.
    private func isNewerVersion(_ newer: String, than current: String) -> Bool {
        let lhs = versionComponents(newer)
        let rhs = versionComponents(current)
        let count = max(lhs.count, rhs.count)
        for i in 0..<count {
            let l = i < lhs.count ? lhs[i] : 0
            let r = i < rhs.count ? rhs[i] : 0
            if l != r { return l > r }
        }
        return false
    }

    private func versionComponents(_ version: String) -> [Int] {
        version.split(separator: ".").compactMap { Int($0) }
    }
}

// MARK: - GitHub API Models

private struct GitHubRelease: Decodable {
    let tagName: String
    let htmlURL: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
    }
}
