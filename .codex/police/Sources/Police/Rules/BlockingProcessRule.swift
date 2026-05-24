import SwiftSyntax

struct BlockingProcessRule: PoliceRule {
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
            let called = node.calledExpression.trimmedDescription
            guard (called.hasSuffix(".waitUntilExit")
                || called == "Thread.sleep"
                || called == "sleep"
                || called == "usleep"),
                !file.hasAllowComment(node: node, token: "allow-blocking-process")
            else { return .visitChildren }

            failures.append(file.failure(node: node, title: "blocking-process"))
            return .visitChildren
        }
    }
}
