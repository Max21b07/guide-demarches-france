import XCTest
@testable import CivicFR

final class ScoringTests: XCTestCase {

    private func makeQuestion(id: String, category: Category, correct: Int) -> Question {
        Question(id: id, category: category, subcategory: nil, difficulty: .easy,
                 questionFr: "Q", questionVi: "Q", answersFr: ["a", "b", "c", "d"],
                 answersVi: ["a", "b", "c", "d"], correctAnswer: correct,
                 explanationFr: "", explanationVi: "", sourceUrl: nil,
                 sourceType: .educational, verifiedAt: nil)
    }

    func testPassThresholdStandard() {
        XCTAssertEqual(Scoring.passThreshold(total: 40), 32)
    }

    func testPassThresholdCustomRoundsUp() {
        // 80 % de 10 = 8 ; de 15 = 12 (arrondi au supérieur)
        XCTAssertEqual(Scoring.passThreshold(total: 10), 8)
        XCTAssertEqual(Scoring.passThreshold(total: 15), 12)
    }

    func testScoreCountsOnlyCorrect() {
        let qs = [
            makeQuestion(id: "1", category: .valeurs, correct: 0),
            makeQuestion(id: "2", category: .valeurs, correct: 1),
            makeQuestion(id: "3", category: .histoire, correct: 2)
        ]
        let answers: [Int?] = [0, 3, nil] // 1 bonne, 1 mauvaise, 1 non répondue
        XCTAssertEqual(Scoring.score(questions: qs, answers: answers), 1)
    }

    func testPerCategoryAggregation() {
        let qs = [
            makeQuestion(id: "1", category: .valeurs, correct: 0),
            makeQuestion(id: "2", category: .valeurs, correct: 1),
            makeQuestion(id: "3", category: .histoire, correct: 2)
        ]
        let answers: [Int?] = [0, 1, 0] // valeurs 2/2, histoire 0/1
        let perCat = Scoring.perCategory(questions: qs, answers: answers)
        XCTAssertEqual(perCat["valeurs"], [2, 2])
        XCTAssertEqual(perCat["histoire"], [0, 1])
    }

    func testPassedBoundary() {
        XCTAssertFalse(Scoring.passed(score: 31, total: 40))
        XCTAssertTrue(Scoring.passed(score: 32, total: 40))
    }

    func testExamResultPercentageAndPass() {
        let r = ExamResult(score: 36, total: 40, timeUsedSeconds: 600,
                           passThreshold: 32, perCategory: [:])
        XCTAssertEqual(r.percentage, 90)
        XCTAssertTrue(r.passed)
    }

    func testLevelProgression() {
        XCTAssertEqual(Levels.current(for: 0).id, 0)
        XCTAssertEqual(Levels.current(for: 250).nameFr, "Apprentie")
        XCTAssertEqual(Levels.current(for: 5000).id, 5)
        XCTAssertNil(Levels.next(for: 5000))
    }

    func testBadgeFirstQuestion() {
        var data = UserData()
        data.totalAnswered = 1
        let badge = Badges.badge(id: "first_question")!
        XCTAssertTrue(badge.condition(data))
    }

    func testQuestionValidity() {
        let good = makeQuestion(id: "1", category: .valeurs, correct: 2)
        XCTAssertTrue(good.isValid)
        let bad = makeQuestion(id: "2", category: .valeurs, correct: 9)
        XCTAssertFalse(bad.isValid)
    }
}
