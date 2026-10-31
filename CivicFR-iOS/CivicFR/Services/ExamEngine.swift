import Foundation
import Combine

/// État persistable d'une simulation en cours (survit à la fermeture de l'app).
struct ExamSessionState: Codable {
    var questionIds: [String]
    var answers: [Int?]          // parallèle à questionIds ; nil = non répondue
    var currentIndex: Int
    var startDate: Date
    var durationSeconds: Int
    var strict: Bool
}

/// Moteur de la simulation d'examen : chronomètre fiable (basé sur une date),
/// sauvegarde automatique, reprise après interruption, notation.
@MainActor
final class ExamEngine: ObservableObject {
    @Published private(set) var questions: [Question] = []
    @Published var answers: [Int?] = []
    @Published var currentIndex: Int = 0
    @Published private(set) var isRunning = false
    @Published var remaining: Int = 0      // secondes restantes
    @Published var finished = false
    @Published private(set) var result: ExamResult?
    @Published var strict: Bool = false

    private var startDate = Date()
    private var duration = AppConfig.examDurationSeconds
    private var timer: Timer?
    private let bank: QuestionBank
    private let fileURL: URL

    init(bank: QuestionBank) {
        self.bank = bank
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("exam_session.json")
    }

    // MARK: - Reprise

    /// True s'il existe une simulation interrompue valide.
    var hasSavedSession: Bool { savedState() != nil }

    private func savedState() -> ExamSessionState? {
        guard let raw = try? Data(contentsOf: fileURL),
              let s = try? JSONDecoder().decode(ExamSessionState.self, from: raw) else { return nil }
        // Session expirée si le temps est écoulé depuis longtemps ? on la garde pour affichage résultat.
        return s
    }

    func resumeIfAvailable() -> Bool {
        guard let s = savedState() else { return false }
        let resolved = s.questionIds.compactMap { bank.question(id: $0) }
        guard resolved.count == s.questionIds.count else { clearSaved(); return false }
        questions = resolved
        answers = s.answers
        currentIndex = min(s.currentIndex, max(0, resolved.count - 1))
        startDate = s.startDate
        duration = s.durationSeconds
        strict = s.strict
        isRunning = true
        finished = false
        result = nil
        startTimer()
        return true
    }

    // MARK: - Démarrage

    func start(strict: Bool) {
        let set = bank.examSet()
        questions = set
        answers = Array(repeating: nil, count: set.count)
        currentIndex = 0
        startDate = Date()
        duration = AppConfig.examDurationSeconds
        self.strict = strict
        isRunning = true
        finished = false
        result = nil
        persist()
        startTimer()
    }

    // MARK: - Chronomètre (basé sur une date, fiable même en arrière-plan)

    private func startTimer() {
        timer?.invalidate()
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    /// Recalcule le temps restant à partir des dates (appeler aussi au retour au premier plan).
    func tick() {
        guard isRunning else { return }
        let elapsed = Int(Date().timeIntervalSince(startDate))
        remaining = max(0, duration - elapsed)
        if remaining == 0 { finish(auto: true) }
    }

    var timeText: String {
        let m = remaining / 60, s = remaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Navigation

    var current: Question? { questions.indices.contains(currentIndex) ? questions[currentIndex] : nil }
    var total: Int { questions.count }
    var answeredCount: Int { answers.compactMap { $0 }.count }
    var unansweredIndices: [Int] { answers.indices.filter { answers[$0] == nil } }

    func select(_ index: Int) {
        guard answers.indices.contains(currentIndex) else { return }
        answers[currentIndex] = index
        persist()
    }

    func next() { if currentIndex < questions.count - 1 { currentIndex += 1 }; persist() }
    func previous() { if currentIndex > 0 { currentIndex -= 1 }; persist() }
    func goto(_ i: Int) { if questions.indices.contains(i) { currentIndex = i }; persist() }

    // MARK: - Fin & notation

    func finish(auto: Bool = false) {
        guard isRunning else { return }
        isRunning = false
        timer?.invalidate(); timer = nil

        let score = Scoring.score(questions: questions, answers: answers)
        let perCat = Scoring.perCategory(questions: questions, answers: answers)
        let timeUsed = min(duration, Int(Date().timeIntervalSince(startDate)))
        result = ExamResult(score: score, total: questions.count,
                            timeUsedSeconds: timeUsed,
                            passThreshold: Scoring.passThreshold(total: questions.count),
                            perCategory: perCat)
        finished = true
        clearSaved()
    }

    func wrongQuestions() -> [Question] {
        questions.enumerated().compactMap { i, q in
            (answers.indices.contains(i) && answers[i] == q.correctAnswer) ? nil : q
        }
    }

    // MARK: - Persistance de session

    private func persist() {
        guard isRunning else { return }
        let state = ExamSessionState(questionIds: questions.map(\.id), answers: answers,
                                     currentIndex: currentIndex, startDate: startDate,
                                     durationSeconds: duration, strict: strict)
        if let raw = try? JSONEncoder().encode(state) {
            try? raw.write(to: fileURL, options: .atomic)
        }
    }

    private func clearSaved() { try? FileManager.default.removeItem(at: fileURL) }

    func abandon() {
        isRunning = false
        timer?.invalidate(); timer = nil
        clearSaved()
    }

    deinit { timer?.invalidate() }
}
