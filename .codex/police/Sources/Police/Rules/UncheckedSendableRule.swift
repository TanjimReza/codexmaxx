import SwiftSyntax

struct UncheckedSendableRule: PoliceRule {
    func inspect(_ file: PoliceSourceFile) -> [PoliceFailure] {
        let visitor = Visitor(file: file)
        visitor.walk(file.syntax)
        return visitor.failures
    }

    private final class Visitor: SyntaxVisitor {
        let file: PoliceSourceFile
        var failures: [PoliceFailure] = []

        init(file: PoliceSourceFile) {
            self.file = file
            super.init(viewMode: .sourceAccurate)
        }

        override func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
            guard node.type.trimmedDescription == "@unchecked Sendable",
                  !file.hasAllowComment(node: node, token: "allow-unchecked-sendable")
            else { return .skipChildren }

            failures.append(file.failure(node: node, title: "unchecked-sendable"))
            return .skipChildren
        }
    }
}
