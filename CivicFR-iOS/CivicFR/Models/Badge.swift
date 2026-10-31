import Foundation

/// Un badge à débloquer.
struct Badge: Identifiable {
    let id: String
    let titleFr: String
    let titleVi: String
    let icon: String
    let descFr: String
    /// Condition d'obtention évaluée sur les données utilisateur.
    let condition: (UserData) -> Bool

    func title(_ lang: InterfaceLanguage) -> String { lang == .vi ? titleVi : titleFr }
}

enum Badges {
    static let all: [Badge] = [
        Badge(id: "first_question", titleFr: "Première question", titleVi: "Câu hỏi đầu tiên",
              icon: "star.fill", descFr: "Répondre à sa première question") { $0.totalAnswered >= 1 },
        Badge(id: "correct_50", titleFr: "50 réussies", titleVi: "50 câu đúng",
              icon: "50.circle.fill", descFr: "50 bonnes réponses") { $0.totalCorrect >= 50 },
        Badge(id: "correct_100", titleFr: "100 réussies", titleVi: "100 câu đúng",
              icon: "100.circle.fill", descFr: "100 bonnes réponses") { $0.totalCorrect >= 100 },
        Badge(id: "first_exam", titleFr: "Première simulation", titleVi: "Bài thi thử đầu tiên",
              icon: "checkered.flag", descFr: "Terminer une simulation") { $0.examCount >= 1 },
        Badge(id: "exam_passed", titleFr: "Examen réussi", titleVi: "Đỗ kỳ thi",
              icon: "rosette", descFr: "Réussir une simulation") { $0.passedExamCount >= 1 },
        Badge(id: "streak_7", titleFr: "7 jours", titleVi: "7 ngày liên tục",
              icon: "flame.fill", descFr: "7 jours consécutifs") { $0.longestStreak >= 7 },
        Badge(id: "streak_30", titleFr: "30 jours", titleVi: "30 ngày liên tục",
              icon: "flame.circle.fill", descFr: "30 jours consécutifs") { $0.longestStreak >= 30 },
        Badge(id: "rate_90", titleFr: "90 % de réussite", titleVi: "90% chính xác",
              icon: "chart.line.uptrend.xyaxis", descFr: "90 % sur une simulation") {
                  ($0.examResults.map(\.percentage).max() ?? 0) >= 90
              },
        Badge(id: "category_100", titleFr: "Catégorie parfaite", titleVi: "Hoàn hảo một chủ đề",
              icon: "crown.fill", descFr: "100 % sur une catégorie (min. 10 questions)") { data in
                  data.categoryStats.values.contains { $0.seen >= 10 && $0.correct == $0.seen }
              }
    ]

    static func badge(id: String) -> Badge? { all.first { $0.id == id } }
}
