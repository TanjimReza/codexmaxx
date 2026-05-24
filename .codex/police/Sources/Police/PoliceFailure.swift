import Foundation

struct PoliceFailure: CustomStringConvertible {
    let relativePath: String
    let lineNumber: Int
    let title: String
    let text: String

    var description: String {
        "\(relativePath):\(lineNumber): \(title): \(text.trimmingCharacters(in: .whitespacesAndNewlines))"
    }
}
