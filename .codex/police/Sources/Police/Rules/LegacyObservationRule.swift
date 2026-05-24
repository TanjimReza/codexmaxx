import SwiftSyntax

struct LegacyObservationRule: PoliceRule {
    private let legacyWrappers = ["Published", "StateObject", "ObservedObject", "EnvironmentObject"]
    private let legacyConstructors = ["StateObject", "ObservedObject", "EnvironmentObject"]

    func inspect(_ file: PoliceSourceFile) -> [PoliceFailure] {
        let visitor = Visitor(rule: self, file: file)
        visitor.walk(file.syntax)
        return visitor.failures
    }

    private func isLegacyWrapper(_ attribute: AttributeSyntax) -> Bool {
        legacyWrappers.contains(attribute.attributeName.trimmedDescription)
    }

    private func isObservableObjectInheritance(_ inheritedType: InheritedTypeSyntax) -> Bool {
        inheritedType.type.trimmedDescription == "ObservableObject"
    }

    private func isLegacyConstructor(_ call: FunctionCallExprSyntax) -> Bool {
        legacyConstructors.contains(call.calledExpression.trimmedDescription)
    }

    private final class Visitor: SyntaxVisitor {
        let rule: LegacyObservationRule
        let file: PoliceSourceFile
        var failures: [PoliceFailure] = []

        init(rule: LegacyObservationRule, file: PoliceSourceFile) {
            self.rule = rule
            self.file = file
            super.init(viewMode: .sourceAccurate)
        }

        override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
            if rule.isLegacyWrapper(node),
               !file.hasAllowComment(node: node, token: "allow-legacy-observation") {
                failures.append(file.failure(node: node, title: "legacy-observation"))
            }
            return .skipChildren
        }

        override func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
            if rule.isObservableObjectInheritance(node),
               !file.hasAllowComment(node: node, token: "allow-legacy-observation") {
                failures.append(file.failure(node: node, title: "legacy-observation"))
            }
            return .skipChildren
        }

        override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
            if rule.isLegacyConstructor(node),
               !file.hasAllowComment(node: node, token: "allow-legacy-observation") {
                failures.append(file.failure(node: node, title: "legacy-observation-constructor"))
            }
            return .visitChildren
        }
    }
}
