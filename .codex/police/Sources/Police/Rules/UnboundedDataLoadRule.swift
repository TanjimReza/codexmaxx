import SwiftSyntax

struct UnboundedDataLoadRule: PoliceRule {
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

        override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
            guard node.calledExpression.trimmedDescription == "Data",
                  node.arguments.first?.label?.text == "contentsOf",
                  !file.hasAllowComment(node: node, token: "allow-unbounded-data-load")
            else { return .visitChildren }

            failures.append(file.failure(node: node, title: "unbounded-data-load"))
            return .visitChildren
        }
    }
}
