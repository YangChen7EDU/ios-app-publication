import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage(SettingsKey.aPlusIsFourPointThree) private var aPlusIsFourPointThree = false
    @State private var isConfirmingDelete = false

    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Count A+ as 4.3", isOn: $aPlusIsFourPointThree)
                } header: {
                    Text("Grading Scale")
                } footer: {
                    Text("Some schools cap A+ at 4.0, others give 4.3. Check your school's policy.")
                }

                Section("How It's Calculated") {
                    Text("Each grade's points are multiplied by the course credits, then averaged over all credits. The weighted GPA adds 0.5 for Honors and 1.0 for AP / IB courses (never for an F). The unweighted GPA ignores course level.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button("Delete All Data", role: .destructive) { isConfirmingDelete = true }
                } header: {
                    Text("Your Data")
                } footer: {
                    Text("Your grades are stored only on this device. Nothing is sent anywhere.")
                }

                Section {
                    LabeledContent("Version", value: version)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Delete all terms and courses?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button("Delete All", role: .destructive) {
                    // Delete one by one so the cascade to courses runs.
                    let terms = (try? modelContext.fetch(FetchDescriptor<Term>())) ?? []
                    terms.forEach(modelContext.delete)
                }
            } message: {
                Text("This can't be undone.")
            }
        }
    }
}
