import Foundation

/// A letter grade on the common US high school 4.0 scale.
enum LetterGrade: String, CaseIterable, Identifiable {
    case aPlus = "A+", a = "A", aMinus = "A-"
    case bPlus = "B+", b = "B", bMinus = "B-"
    case cPlus = "C+", c = "C", cMinus = "C-"
    case dPlus = "D+", d = "D", dMinus = "D-"
    case f = "F"

    var id: String { rawValue }

    /// Unweighted grade points. Schools differ on A+: some cap it at 4.0, some give 4.3.
    func points(aPlusValue: Double) -> Double {
        switch self {
        case .aPlus: aPlusValue
        case .a: 4.0
        case .aMinus: 3.7
        case .bPlus: 3.3
        case .b: 3.0
        case .bMinus: 2.7
        case .cPlus: 2.3
        case .c: 2.0
        case .cMinus: 1.7
        case .dPlus: 1.3
        case .d: 1.0
        case .dMinus: 0.7
        case .f: 0.0
        }
    }
}

/// Course level, which decides the bonus added for the weighted GPA.
enum CourseLevel: String, CaseIterable, Identifiable {
    case regular = "Regular"
    case honors = "Honors"
    case advanced = "AP / IB"

    var id: String { rawValue }

    var bonus: Double {
        switch self {
        case .regular: 0.0
        case .honors: 0.5
        case .advanced: 1.0
        }
    }
}

struct GradeEntry: Equatable {
    var grade: LetterGrade
    var level: CourseLevel
    var credits: Double
}

struct GPAOptions: Equatable {
    /// 4.0 or 4.3.
    var aPlusValue: Double = 4.0
}

struct GPAResult: Equatable {
    /// `nil` when there are no credits to average over.
    var unweighted: Double?
    var weighted: Double?
    var credits: Double
}

enum GPA {
    /// Credit-weighted average. Honors and AP / IB bonuses only apply to the weighted GPA,
    /// and never to an F.
    static func calculate(_ entries: [GradeEntry], options: GPAOptions = GPAOptions()) -> GPAResult {
        let counted = entries.filter { $0.credits > 0 }
        let credits = counted.reduce(0) { $0 + $1.credits }
        guard credits > 0 else { return GPAResult(unweighted: nil, weighted: nil, credits: 0) }

        var unweightedPoints = 0.0
        var weightedPoints = 0.0
        for entry in counted {
            let points = entry.grade.points(aPlusValue: options.aPlusValue)
            let bonus = entry.grade == .f ? 0 : entry.level.bonus
            unweightedPoints += points * entry.credits
            weightedPoints += (points + bonus) * entry.credits
        }
        return GPAResult(
            unweighted: unweightedPoints / credits,
            weighted: weightedPoints / credits,
            credits: credits
        )
    }

    static func format(_ value: Double?) -> String {
        guard let value else { return "–" }
        return value.formatted(.number.precision(.fractionLength(2)))
    }
}
