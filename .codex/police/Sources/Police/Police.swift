import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

@main
enum Police {
    static func main() {
        let rules: [PoliceRule] = [
            LegacyObservationRule(),
            UncheckedSendableRule(),
            MainSyncRule(),
            BlockingProcessRule(),
            UnboundedDataLoadRule(),
            APIIconRenderingRule()
        ]

        do {
            let config = try PoliceConfig(arguments: CommandLine.arguments)
            let files = try PoliceFileCollector.collect(from: config.sourceRootURL, rootURL: config.rootURL)
            let failures = rules.flatMap { rule in
                files.flatMap { file in rule.inspect(file) }
            }

            guard failures.isEmpty else {
                print("police found issues:")
                failures.forEach { failure in
                    print("- \(failure.description)")
                }
                exit(EXIT_FAILURE)
            }

            print("police: zero issues")
        } catch {
            print("police failed: \(error.localizedDescription)")
            exit(EXIT_FAILURE)
        }
    }
}
