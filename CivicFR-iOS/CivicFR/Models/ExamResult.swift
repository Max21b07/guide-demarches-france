import Foundation

/// Résultat d'une simulation d'examen terminée.
struct ExamResult: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var score: Int           // bonnes réponses
    var total: Int           // nombre de questions
    var timeUsedSeconds: Int
    var passThreshold: Int
    /// bonnes/total par catégorie (rawValue -> [correct, total]).
    var perCategory: [String: [Int]]

    var passed: Bool { score >= passThreshold }
    var percentage: Int { total == 0 ? 0 : Int((Double(score) / Double(total) * 100).rounded()) }

    var timeUsedText: String {
        let m = timeUsedSeconds / 60, s = timeUsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
