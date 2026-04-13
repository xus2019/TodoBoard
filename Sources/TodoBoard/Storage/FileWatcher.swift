import Foundation
import CryptoKit

final class FileWatcher: @unchecked Sendable {
    var onFileChanged: ((URL) -> Void)?

    private let queue = DispatchQueue(label: "com.todoboard.filewatcher")
    private var source: DispatchSourceFileSystemObject?
    private var descriptor: CInt = -1
    private var lastHashes: [URL: String] = [:]
    private var debounceWorkItem: DispatchWorkItem?
    private var watchedDirectory: URL?

    func start(directory: URL) {
        stop()
        watchedDirectory = directory
        let watchedDescriptor = open(directory.path, O_EVTONLY)
        descriptor = watchedDescriptor
        guard watchedDescriptor >= 0 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: watchedDescriptor,
            eventMask: .write,
            queue: queue
        )

        source.setEventHandler { [weak self] in
            self?.scheduleScan()
        }

        source.setCancelHandler { [weak self] in
            if watchedDescriptor >= 0 {
                close(watchedDescriptor)
            }
            if self?.descriptor == watchedDescriptor {
                self?.descriptor = -1
            }
        }

        self.source = source
        source.resume()
        refreshHashes()
    }

    func stop() {
        debounceWorkItem?.cancel()
        debounceWorkItem = nil
        if let source {
            self.source = nil
            descriptor = -1
            source.cancel()
        } else if descriptor >= 0 {
            close(descriptor)
            descriptor = -1
        }
        watchedDirectory = nil
        lastHashes.removeAll()
    }

    private func scheduleScan() {
        debounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.scanChanges()
        }
        debounceWorkItem = workItem
        queue.asyncAfter(deadline: .now() + .milliseconds(100), execute: workItem)
    }

    private func refreshHashes() {
        guard let watchedDirectory else { return }
        let urls = trackedMarkdownURLs(in: watchedDirectory)
        lastHashes = urls.reduce(into: [:]) { result, url in
            result[url] = hash(for: url)
        }
    }

    private func scanChanges() {
        guard let watchedDirectory else { return }
        let urls = trackedMarkdownURLs(in: watchedDirectory)
        var newHashes: [URL: String] = [:]

        for url in urls {
            let newHash = hash(for: url)
            newHashes[url] = newHash
            if lastHashes[url] != newHash {
                let callback = onFileChanged
                DispatchQueue.main.async {
                    callback?(url)
                }
            }
        }

        lastHashes = newHashes
    }

    private func hash(for url: URL) -> String {
        guard let data = try? Data(contentsOf: url) else { return "" }
        return contentHash(for: data)
    }

    func trackedMarkdownURLs(in directory: URL) -> [URL] {
        ((try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? [])
            .filter { $0.pathExtension.lowercased() == "md" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    func contentHash(for data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
