import Foundation
import Combine

/// Source de vérité des données utilisateur : persistance locale (JSON) + gamification.
@MainActor
final class Store: ObservableObject {
    @Published var data: UserData {
        didSet { scheduleSave() }
    }

    /// Badges débloqués pendant la session en cours (pour l'animation de récompense).
    @Published var newlyUnlocked: [Badge] = []

    private let fileURL: URL
    private var saveTask: Task<Void, Never>?

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("userdata.json")
        if let loaded = Store.load(from: fileURL) {
            data = loaded
        } else {
            data = UserData()
        }
    }

    var lang: InterfaceLanguage { data.settings.interfaceLanguage }

    // MARK: - Persistance

    private static func load(from url: URL) -> UserData? {
        guard let raw = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(UserData.self, from: raw)
    }

    private func scheduleSave() {
        saveTask?.cancel()
        let snapshot = data
        let url = fileURL
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            if let raw = try? JSONEncoder().encode(snapshot) {
                try? raw.write(to: url, options: .atomic)
            }
        }
    }

    func saveNow() {
        if let raw = try? JSONEncoder().encode(data) {
            try? raw.write(to: fileURL, options: .atomic)
        }
    }

    // MARK: - Enregistrement des réponses

    /// Enregistre une réponse (hors simulation : les stats d'examen passent par `recordExam`).
    func recordAnswer(question: Question, correct: Bool, awardXP: Bool = true) {
        data.totalAnswered += 1
        if correct { data.totalCorrect += 1 }

        var qs = data.questionStats[question.id] ?? QuestionStat()
        qs.seen += 1
        if correct { qs.correct += 1 }
        qs.lastCorrect = correct
        data.questionStats[question.id] = qs

        var cs = data.categoryStats[question.category.rawValue] ?? CategoryStat()
        cs.seen += 1
        if correct { cs.correct += 1 }
        data.categoryStats[question.category.rawValue] = cs

        if awardXP && correct { addXP(AppConfig.xpCorrectAnswer) }
        checkBadges()
    }

    func addXP(_ amount: Int) {
        guard amount > 0 else { return }
        data.xp += amount
    }

    func addLearningTime(_ seconds: Int) {
        data.learningSeconds += max(0, seconds)
    }

    // MARK: - Série quotidienne

    /// À appeler quand une session est terminée : met à jour la série de jours.
    func registerDailyActivity() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        if let last = data.lastStudyDate {
            let lastDay = cal.startOfDay(for: last)
            if lastDay == today { return } // déjà compté aujourd'hui
            if let diff = cal.dateComponents([.day], from: lastDay, to: today).day, diff == 1 {
                data.streakDays += 1
            } else {
                data.streakDays = 1
            }
        } else {
            data.streakDays = 1
        }
        data.lastStudyDate = today
        data.longestStreak = max(data.longestStreak, data.streakDays)
        addXP(AppConfig.xpDailyBonus)
        checkBadges()
    }

    // MARK: - Examen

    func recordExam(_ result: ExamResult) {
        data.examResults.append(result)
        // Intègre les réponses d'examen aux stats globales via perCategory.
        for (cat, pair) in result.perCategory where pair.count == 2 {
            var cs = data.categoryStats[cat] ?? CategoryStat()
            cs.seen += pair[1]
            cs.correct += pair[0]
            data.categoryStats[cat] = cs
        }
        data.totalAnswered += result.total
        data.totalCorrect += result.score
        addXP(AppConfig.xpSessionComplete)
        registerDailyActivity()
        checkBadges()
    }

    // MARK: - Badges

    func checkBadges() {
        for badge in Badges.all where !data.unlockedBadges.contains(badge.id) {
            if badge.condition(data) {
                data.unlockedBadges.insert(badge.id)
                newlyUnlocked.append(badge)
            }
        }
    }

    func consumeNewlyUnlocked() -> Badge? {
        guard !newlyUnlocked.isEmpty else { return nil }
        return newlyUnlocked.removeFirst()
    }

    // MARK: - Programme

    func startProgramIfNeeded() {
        if data.programStartDate == nil { data.programStartDate = Date() }
    }

    var programDay: Int {
        guard let start = data.programStartDate else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return min(max(days + 1, 1), AppConfig.programDays)
    }

    // MARK: - Reset (paramètres)

    func resetProgress() {
        data = UserData(onboardingDone: true, settings: data.settings)
        saveNow()
    }
}
