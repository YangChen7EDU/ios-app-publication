import SwiftData
import SwiftUI

@main
struct GPACalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TermListView()
            }
        }
        .modelContainer(for: [Term.self, Course.self])
    }
}

/// Keys for settings kept in UserDefaults.
enum SettingsKey {
    static let aPlusIsFourPointThree = "aPlusIsFourPointThree"
}

extension GPAOptions {
    init(aPlusIsFourPointThree: Bool) {
        self.init(aPlusValue: aPlusIsFourPointThree ? 4.3 : 4.0)
    }
}
