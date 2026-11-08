import SwiftData
import SwiftUI

/// One term: its GPA and its courses.
struct TermDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(SettingsKey.aPlusIsFourPointThree) private var aPlusIsFourPointThree = false
    @Bindable var term: Term

    @State private var editing: CourseEditorView.Mode?
    @State private var isRenaming = false
    @State private var newName = ""

    var body: some View {
        List {
            Section {
                GPASummaryView(title: "Term GPA", result: term.result(options: GPAOptions(aPlusIsFourPointThree: aPlusIsFourPointThree)))
            }
            Section("Courses") {
                if term.courses.isEmpty {
                    Text("No courses yet. Tap + to add one.")
                        .foregroundStyle(.secondary)
                }
                ForEach(term.sortedCourses) { course in
                    Button {
                        editing = .edit(course)
                    } label: {
                        CourseRow(course: course)
                    }
                    .tint(.primary)
                }
                .onDelete(perform: deleteCourses)
            }
        }
        .navigationTitle(term.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Course", systemImage: "plus") { editing = .add(term) }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Rename Term", systemImage: "pencil") {
                    newName = term.name
                    isRenaming = true
                }
            }
        }
        .sheet(item: $editing) { mode in
            CourseEditorView(mode: mode)
        }
        .alert("Rename Term", isPresented: $isRenaming) {
            TextField("Term name", text: $newName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty { term.name = name }
            }
        }
    }

    private func deleteCourses(at offsets: IndexSet) {
        let courses = term.sortedCourses
        for index in offsets {
            modelContext.delete(courses[index])
        }
    }
}

private struct CourseRow: View {
    let course: Course

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(.headline)
                Text("\(course.level.rawValue) · \(course.credits.formatted(.number.precision(.fractionLength(0...2)))) credits")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(course.grade.rawValue)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .frame(minWidth: 44)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.12), in: .rect(cornerRadius: 8))
                .foregroundStyle(Color.accentColor)
        }
        .contentShape(.rect)
    }
}
