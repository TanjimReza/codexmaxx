protocol PoliceRule {
    func inspect(_ file: PoliceSourceFile) -> [PoliceFailure]
}
