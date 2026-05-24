import Foundation
import SwiftParser
import SwiftSyntax

struct PoliceSourceFile {
    let url: URL
    let relativePath: String
    let lines: [String]
    let syntax: SourceFileSyntax
    let locationConverter: SourceLocationConverter

    init(url: URL, rootURL: URL) throws {
        self.url = url
        relativePath = String(url.path.dropFirst(rootURL.path.count + 1))
        let text = try String(contentsOf: url, encoding: .utf8)
        lines = text.components(separatedBy: .newlines)
        syntax = Parser.parse(source: text)
        locationConverter = SourceLocationConverter(fileName: url.path, tree: syntax)
    }

    func hasAllowComment(at lineIndex: Int, token: String) -> Bool {
        let lowerBound = max(0, lineIndex - 2)
        for index in lowerBound...lineIndex {
            guard lines.indices.contains(index) else { continue }
            if lines[index].contains("police: \(token)")
                || lines[index].contains("swiftcast-police: \(token)") {
                return true
            }
        }
        return false
    }

    func failure(lineIndex: Int, title: String, text: String) -> PoliceFailure {
        PoliceFailure(
            relativePath: relativePath,
            lineNumber: lineIndex + 1,
            title: title,
            text: text
        )
    }

    func failure(node: some SyntaxProtocol, title: String, text: String? = nil) -> PoliceFailure {
        let location = node.startLocation(converter: locationConverter)
        let lineNumber = max(location.line, 1)
        return PoliceFailure(
            relativePath: relativePath,
            lineNumber: lineNumber,
            title: title,
            text: text ?? node.trimmedDescription
        )
    }

    func hasAllowComment(node: some SyntaxProtocol, token: String) -> Bool {
        let location = node.startLocation(converter: locationConverter)
        return hasAllowComment(at: max(location.line - 1, 0), token: token)
    }
}
