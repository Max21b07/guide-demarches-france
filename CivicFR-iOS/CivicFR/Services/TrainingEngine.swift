import Foundation
import Combine

/// Type de séance d'entraînement.
enum TrainingKind {
    case quick            // tirage pondéré
    case category(Category)
    case review           // uniquement les erreurs / non maîtrisées
}

/// Moteur d'entraînement : feedback immédiat, animations, XP, sons.
@MainActor
final class TrainingEngine: ObservableObject {
    @Published private(set) var questions: [Question] = []
    @Published var index = 0
    @Published var selected: Int? = nil
    @Published var revealed = false
    @Published var correctCount = 0
    @Published var finished = false
    @Published private(set) var lastAnswerCorrect = false

    private var consecutiveCorrect = 0
    private var elapsedStart = Date()
    private let bank: QuestionBank
    private let store: Store

    init(bank: QuestionBank, store: Store) {
        self.bank = bank
        self.store = store
    }

    func startQuick(count: Int) {
        questions = bank.weighted(count: count, stats: store.data.questionStats)
        reset()
    }

    func startCategory(_ category: Category, count: Int) {
        questions = bank.weighted(count: count, stats: store.data.questionStats, in: category)
        reset()
    }

    func startReview(count: Int = 20) {
        let pool = bank.toReview(stats: store.data.questionStats)
        questions = Array(pool.shuffled().prefix(count))
        reset()
    }

    private func reset() {
        index = 0; selected = nil; revealed = false
        correctCount = 0; finished = false; consecutiveCorrect = 0
        elapsedStart = Date()
    }

    var current: Question? { questions.indices.contains(index) ? questions[index] : nil }
    var total: Int { questions.count }
    var isEmpty: Bool { questions.isEmpty }

    func select(_ i: Int) { if !revealed { selected = i } }

    /// Valide la réponse choisie : révèle la correction et met à jour les stats.
    func validate() {
        guard let q = current, let s = selected, !revealed else { return }
        revealed = true
        let correct = s == q.correctAnswer
        lastAnswerCorrect = correct
        if correct {
            correctCount += 1
            consecutiveCorrect += 1
            if consecutiveCorrect == 5 { store.addXP(AppConfig.xpStreakBonus) }
        } else {
            consecutiveCorrect = 0
        }
        store.recordAnswer(question: q, correct: correct)
    }

    func advance() {
        selected = nil
        revealed = false
        if index < questions.count - 1 {
            index += 1
        } else {
            complete()
        }
    }

    private func complete() {
        store.addXP(AppConfig.xpSessionComplete)
        store.addLearningTime(Int(Date().timeIntervalSince(elapsedStart)))
        store.registerDailyActivity()
        finished = true
    }

    var accuracy: Double { total == 0 ? 0 : Double(correctCount) / Double(total) }
}
