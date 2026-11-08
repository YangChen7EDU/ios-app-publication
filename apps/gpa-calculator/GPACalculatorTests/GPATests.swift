import XCTest
@testable import GPACalculator

final class GPATests: XCTestCase {
    func testEmptyHasNoGPA() {
        let result = GPA.calculate([])
        XCTAssertNil(result.unweighted)
        XCTAssertNil(result.weighted)
        XCTAssertEqual(result.credits, 0)
    }

    func testZeroCreditCoursesAreIgnored() {
        let result = GPA.calculate([
            GradeEntry(grade: .f, level: .regular, credits: 0),
            GradeEntry(grade: .a, level: .regular, credits: 1),
        ])
        XCTAssertEqual(result.unweighted, 4.0)
        XCTAssertEqual(result.credits, 1)
    }

    func testAveragesByCredits() {
        let result = GPA.calculate([
            GradeEntry(grade: .a, level: .regular, credits: 2),
            GradeEntry(grade: .c, level: .regular, credits: 1),
        ])
        XCTAssertEqual(result.unweighted!, 10.0 / 3.0, accuracy: 0.0001)
        XCTAssertEqual(result.weighted!, 10.0 / 3.0, accuracy: 0.0001)
    }

    func testLevelBonusOnlyAffectsWeighted() {
        let result = GPA.calculate([
            GradeEntry(grade: .a, level: .advanced, credits: 1),
            GradeEntry(grade: .b, level: .honors, credits: 1),
        ])
        XCTAssertEqual(result.unweighted!, 3.5, accuracy: 0.0001)
        XCTAssertEqual(result.weighted!, 4.25, accuracy: 0.0001)
    }

    func testNoBonusForF() {
        let result = GPA.calculate([GradeEntry(grade: .f, level: .advanced, credits: 1)])
        XCTAssertEqual(result.weighted, 0)
    }

    func testAPlusValueOption() {
        let entries = [GradeEntry(grade: .aPlus, level: .regular, credits: 1)]
        XCTAssertEqual(GPA.calculate(entries).unweighted, 4.0)
        XCTAssertEqual(GPA.calculate(entries, options: GPAOptions(aPlusValue: 4.3)).unweighted, 4.3)
    }

    func testFormat() {
        XCTAssertEqual(GPA.format(nil), "–")
        XCTAssertEqual(GPA.format(3.456), "3.46")
        XCTAssertEqual(GPA.format(4), "4.00")
    }
}
