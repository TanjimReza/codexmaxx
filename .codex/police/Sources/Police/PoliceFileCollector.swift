import Foundation

enum PoliceFileCollector {
    static func collect(from sourceRootURL: URL, rootURL: URL) throws -> [PoliceSourceFile] {
        guard FileManager.default.fileExists(atPath: sourceRootURL.path) else {
            return []
        }

        let urls = try collectSwiftFiles(from: sourceRootURL)
        return try urls
            .sorted { $0.path < $1.path }
            .map { url in
                try PoliceSourceFile(url: url, rootURL: rootURL)
            }
    }

    private static func collectSwiftFiles(from directoryURL: URL) throws -> [URL] {
        let entries = try FileManager.default.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        var files: [URL] = []
        for entry in entries {
            let values = try entry.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey])
            if values.isDirectory == true {
                files += try collectSwiftFiles(from: entry)
            } else if values.isRegularFile == true, entry.pathExtension == "swift" {
                files.append(entry)
            }
        }
        return files
    }
}
