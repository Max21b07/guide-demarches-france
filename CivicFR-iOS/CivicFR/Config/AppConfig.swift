import Foundation

/// Configuration centralisée de l'examen et de la gamification.
/// À ajuster si les règles officielles de l'examen civique évoluent.
enum AppConfig {

    // MARK: Examen (valeurs initiales, à vérifier sur les sources officielles)
    static let examQuestionCount = 40
    static let examDurationMinutes = 45
    static let examDurationSeconds = examDurationMinutes * 60
    static let examMaxScore = 40
    /// Seuil de réussite : 32/40 (80 %).
    static let examPassThreshold = 32
    static let examPassPercent = 80

    // MARK: Entraînement rapide (nombre de questions -> durée indicative en secondes)
    static let trainingPresets: [(count: Int, seconds: Int)] = [
        (5, 120), (10, 300), (20, 600)
    ]

    // MARK: XP
    static let xpCorrectAnswer = 10
    static let xpSessionComplete = 20
    static let xpStreakBonus = 15          // série de 5 bonnes réponses
    static let xpDailyBonus = 25           // session quotidienne terminée

    // MARK: Programme
    static let programDays = 30
}
