import SwiftSyntax

struct MainSyncRule: PoliceRule {
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
            guard node.calledExpression.trimmedDescription == "DispatchQueue.main.sync",
                  !file.hasAllowComment(node: node, token: "allow-main-sync")
            else { return .visitChildren }

            failures.append(file.failure(node: node, title: "main-sync"))
            return .visitChildren
        }
    }
}
