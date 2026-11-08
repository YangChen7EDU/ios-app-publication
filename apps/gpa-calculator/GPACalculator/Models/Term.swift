import Foundation
import SwiftData

/// A school term, e.g. "9th Grade · Fall", holding its courses.
@Model
final class Term {
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Course.term)
    var courses: [Course] = []

    init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }

    var sortedCourses: [Course] {
        courses.sorted { $0.createdAt < $1.createdAt }
    }

    func result(options: GPAOptions) -> GPAResult {
        GPA.calculate(courses.map(\.entry), options: options)
    }
}

@Model
final class Course {
    var name: String
    // Enums are stored as their raw values so a renamed case can't break saved data.
    var gradeRaw: String
    var levelRaw: String
    var credits: Double
    var createdAt: Date
    var term: Term?

    init(name: String, grade: LetterGrade, level: CourseLevel, credits: Double, createdAt: Date = .now) {
        self.name = name
        self.gradeRaw = grade.rawValue
        self.levelRaw = level.rawValue
        self.credits = credits
        self.createdAt = createdAt
    }

    var grade: LetterGrade {
        get { LetterGrade(rawValue: gradeRaw) ?? .a }
        set { gradeRaw = newValue.rawValue }
    }

    var level: CourseLevel {
        get { CourseLevel(rawValue: levelRaw) ?? .regular }
        set { levelRaw = newValue.rawValue }
    }

    var entry: GradeEntry {
        GradeEntry(grade: grade, level: level, credits: credits)
    }
}
