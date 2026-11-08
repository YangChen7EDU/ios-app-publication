import SwiftData
import SwiftUI

/// Sheet for adding a course to a term, or editing an existing course.
struct CourseEditorView: View {
    enum Mode: Identifiable {
        case add(Term)
        case edit(Course)

        var id: PersistentIdentifier {
            switch self {
            case .add(let term): term.persistentModelID
            case .edit(let course): course.persistentModelID
            }
        }
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var grade = LetterGrade.a
    @State private var level = CourseLevel.regular
    @State private var credits = 1.0

    private var isEditing: Bool {
        if case .edit = mode { true } else { false }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Course name, e.g. AP Biology", text: $name)
                        .textInputAutocapitalization(.words)
                }
                Section("Grade") {
                    Picker("Grade", selection: $grade) {
                        ForEach(LetterGrade.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }
                Section {
                    Picker("Level", selection: $level) {
                        ForEach(CourseLevel.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Level")
                } footer: {
                    Text("Honors adds 0.5 and AP / IB adds 1.0 to the weighted GPA.")
                }
                Section {
                    Stepper(value: $credits, in: 0.25...10, step: 0.25) {
                        LabeledContent("Credits", value: credits.formatted(.number.precision(.fractionLength(0...2))))
                    }
                } footer: {
                    Text("Most year-long classes are 1 credit; semester classes are often 0.5.")
                }
            }
            .navigationTitle(isEditing ? "Edit Course" : "New Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                }
            }
            .onAppear(perform: load)
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func load() {
        guard case .edit(let course) = mode else { return }
        name = course.name
        grade = course.grade
        level = course.level
        credits = course.credits
    }

    private func save() {
        switch mode {
        case .add(let term):
            let course = Course(
                name: trimmedName.isEmpty ? "Course \(term.courses.count + 1)" : trimmedName,
                grade: grade,
                level: level,
                credits: credits
            )
            term.courses.append(course)
        case .edit(let course):
            if !trimmedName.isEmpty { course.name = trimmedName }
            course.grade = grade
            course.level = level
            course.credits = credits
        }
    }
}
