import Foundation

/// Une question du QCM. Les clés JSON sont en snake_case
/// (décodage via `.convertFromSnakeCase`).
struct Question: Codable, Identifiable, Hashable {
    let id: String
    let category: Category
    var subcategory: String?
    let difficulty: Difficulty
    let questionFr: String
    let questionVi: String
    let answersFr: [String]
    let answersVi: [String]
    let correctAnswer: Int
    let explanationFr: String
    let explanationVi: String
    var sourceUrl: String?
    let sourceType: SourceType
    var verifiedAt: String?

    /// Énoncé selon la langue d'interface.
    func question(_ lang: InterfaceLanguage) -> String {
        lang == .vi ? questionVi : questionFr
    }

    func answers(_ lang: InterfaceLanguage) -> [String] {
        lang == .vi ? answersVi : answersFr
    }

    func explanation(_ lang: InterfaceLanguage) -> String {
        lang == .vi ? explanationVi : explanationFr
    }

    /// Validité minimale : 4 réponses et index correct cohérent.
    var isValid: Bool {
        answersFr.count == 4 && answersVi.count == 4 &&
        correctAnswer >= 0 && correctAnswer < answersFr.count &&
        !questionFr.isEmpty
    }

    static func == (lhs: Question, rhs: Question) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
