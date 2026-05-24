import SwiftSyntax

struct APIIconRenderingRule: PoliceRule {
    func inspect(_ file: PoliceSourceFile) -> [PoliceFailure] {
        guard file.relativePath.localizedCaseInsensitiveContains("api")
            || file.relativePath.localizedCaseInsensitiveContains("route")
            || file.relativePath.localizedCaseInsensitiveContains("server")
        else { return [] }

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

        override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
            guard node.calledExpression.trimmedDescription == "NSWorkspace.shared.icon",
                  node.arguments.first?.label?.text == "forFile",
                  !file.hasAllowComment(node: node, token: "allow-api-icon-rendering")
            else { return .visitChildren }

            failures.append(file.failure(node: node, title: "api-icon-rendering"))
            return .visitChildren
        }
    }
}
