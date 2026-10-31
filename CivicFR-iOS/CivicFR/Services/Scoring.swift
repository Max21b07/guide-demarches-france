import Foundation

/// Logique de notation pure (testable unitairement, sans dépendance UI).
enum Scoring {

    /// Seuil de réussite (80 %), adapté si le nombre de questions diffère de 40.
    static func passThreshold(total: Int) -> Int {
        if total == AppConfig.examQuestionCount { return AppConfig.examPassThreshold }
        return Int((Double(total) * Double(AppConfig.examPassPercent) / 100).rounded(.up))
    }

    /// Nombre de bonnes réponses. `answers` est parallèle à `questions` (nil = non répondue).
    static func score(questions: [Question], answers: [Int?]) -> Int {
        var s = 0
        for (i, q) in questions.enumerated() where answers.indices.contains(i) {
            if answers[i] == q.correctAnswer { s += 1 }
        }
        return s
    }

    /// Détail bonnes/total par catégorie (rawValue -> [correct, total]).
    static func perCategory(questions: [Question], answers: [Int?]) -> [String: [Int]] {
        var result: [String: [Int]] = [:]
        for (i, q) in questions.enumerated() {
            var pair = result[q.category.rawValue] ?? [0, 0]
            pair[1] += 1
            if answers.indices.contains(i), answers[i] == q.correctAnswer { pair[0] += 1 }
            result[q.category.rawValue] = pair
        }
        return result
    }

    static func passed(score: Int, total: Int) -> Bool {
        score >= passThreshold(total: total)
    }
}
