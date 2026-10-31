import Foundation

/// Statistiques par question (pondération + maîtrise).
struct QuestionStat: Codable {
    var seen: Int = 0
    var correct: Int = 0
    var lastCorrect: Bool = false
    /// Maîtrisée : réussie au moins 2 fois et dernière réponse correcte.
    var isMastered: Bool { correct >= 2 && lastCorrect }
}

/// Statistiques par catégorie.
struct CategoryStat: Codable {
    var seen: Int = 0
    var correct: Int = 0
    var rate: Double { seen == 0 ? 0 : Double(correct) / Double(seen) }
}

/// Préférences utilisateur.
struct Settings: Codable {
    var interfaceLanguage: InterfaceLanguage = .fr
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    /// Mode examen strict : pas de traduction ni de correction immédiate.
    var strictExamMode: Bool = false
    var notificationsEnabled: Bool = false
    var reminderHour: Int = 19
    var reminderMinute: Int = 0
    var remindersPerWeek: Int = 7
}

/// Toutes les données persistées localement (JSON dans Documents).
struct UserData: Codable {
    var onboardingDone: Bool = false
    var settings = Settings()

    var xp: Int = 0
    var streakDays: Int = 0
    var longestStreak: Int = 0
    var lastStudyDate: Date? = nil
    var learningSeconds: Int = 0

    var totalAnswered: Int = 0
    var totalCorrect: Int = 0

    var questionStats: [String: QuestionStat] = [:]
    var categoryStats: [String: CategoryStat] = [:]

    var unlockedBadges: Set<String> = []
    var examResults: [ExamResult] = []

    var programStartDate: Date? = nil

    // Dérivés ---------------------------------------------------------

    var bestExamScore: Int { examResults.map(\.score).max() ?? 0 }
    var lastExamResult: ExamResult? { examResults.max(by: { $0.date < $1.date }) }
    var examCount: Int { examResults.count }
    var passedExamCount: Int { examResults.filter(\.passed).count }

    var globalRate: Double { totalAnswered == 0 ? 0 : Double(totalCorrect) / Double(totalAnswered) }
    var masteredCount: Int { questionStats.values.filter(\.isMastered).count }
    var toReviewCount: Int { questionStats.values.filter { $0.seen > 0 && !$0.isMastered }.count }

    func stat(for category: Category) -> CategoryStat {
        categoryStats[category.rawValue] ?? CategoryStat()
    }
}
