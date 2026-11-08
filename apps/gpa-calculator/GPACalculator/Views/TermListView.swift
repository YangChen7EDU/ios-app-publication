import SwiftData
import SwiftUI

/// Home screen: cumulative GPA across all terms, and the list of terms.
struct TermListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Term.createdAt) private var terms: [Term]
    @AppStorage(SettingsKey.aPlusIsFourPointThree) private var aPlusIsFourPointThree = false

    @State private var isAddingTerm = false
    @State private var newTermName = ""
    @State private var isShowingSettings = false

    private var options: GPAOptions { GPAOptions(aPlusIsFourPointThree: aPlusIsFourPointThree) }

    var body: some View {
        Group {
            if terms.isEmpty {
                ContentUnavailableView {
                    Label("No Terms Yet", systemImage: "graduationcap")
                } description: {
                    Text("Add a term, like “9th Grade · Fall”, then add your courses and grades.")
                } actions: {
                    Button("Add Term") { startAddingTerm() }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    Section {
                        GPASummaryView(
                            title: "Cumulative GPA",
                            result: GPA.calculate(terms.flatMap { $0.courses.map(\.entry) }, options: options)
                        )
                    }
                    Section("Terms") {
                        ForEach(terms) { term in
                            NavigationLink(value: term) {
                                TermRow(term: term, result: term.result(options: options))
                            }
                        }
                        .onDelete(perform: deleteTerms)
                    }
                }
            }
        }
        .navigationTitle("GPA")
        .navigationDestination(for: Term.self) { term in
            TermDetailView(term: term)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Settings", systemImage: "gearshape") { isShowingSettings = true }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add Term", systemImage: "plus") { startAddingTerm() }
            }
        }
        .alert("New Term", isPresented: $isAddingTerm) {
            TextField("e.g. 10th Grade · Spring", text: $newTermName)
            Button("Cancel", role: .cancel) {}
            Button("Add") { addTerm() }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }

    private func startAddingTerm() {
        newTermName = ""
        isAddingTerm = true
    }

    private func addTerm() {
        let name = newTermName.trimmingCharacters(in: .whitespacesAndNewlines)
        modelContext.insert(Term(name: name.isEmpty ? "Term \(terms.count + 1)" : name))
    }

    private func deleteTerms(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(terms[index])
        }
    }
}

private struct TermRow: View {
    let term: Term
    let result: GPAResult

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(term.name)
                    .font(.headline)
                Text(term.courses.count == 1 ? "1 course" : "\(term.courses.count) courses")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(GPA.format(result.weighted))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                Text("weighted")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
