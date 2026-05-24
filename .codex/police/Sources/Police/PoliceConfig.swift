import Foundation

struct PoliceConfig {
    let rootURL: URL

    var sourceRootURL: URL {
        rootURL.appendingPathComponent("Sources")
    }

    init(arguments: [String]) throws {
        if let index = arguments.firstIndex(of: "--root"),
           arguments.indices.contains(index + 1) {
            rootURL = URL(fileURLWithPath: arguments[index + 1]).standardizedFileURL
        } else {
            rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).standardizedFileURL
        }
    }
}
