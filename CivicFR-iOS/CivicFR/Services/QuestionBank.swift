import Foundation

/// Banque de questions chargée depuis `questions.json` (hors ligne).
/// La base peut être enrichie en modifiant uniquement le JSON, sans toucher au code.
@MainActor
final class QuestionBank: ObservableObject {
    @Published private(set) var questions: [Question] = []

    init() { load() }

    func load() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let raw = try? Data(contentsOf: url) else {
            questions = []
            return
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = (try? decoder.decode([Question].self, from: raw)) ?? []
        // On ignore les questions mal formées pour ne pas casser l'app.
        questions = decoded.filter { $0.isValid }
    }

    var count: Int { questions.count }

    func questions(in category: Category) -> [Question] {
        questions.filter { $0.category == category }
    }

    func categoriesAvailable() -> [Category] {
        Category.allCases.filter { !questions(in: $0).isEmpty }
    }

    func question(id: String) -> Question? { questions.first { $0.id == id } }

    // MARK: - Sélection

    /// Tirage aléatoire simple sans doublon.
    func random(count: Int, in category: Category? = nil) -> [Question] {
        let pool = category.map { questions(in: $0) } ?? questions
        return Array(pool.shuffled().prefix(count))
    }

    /// Tirage pondéré : privilégie les questions jamais vues ou mal maîtrisées,
    /// sans faire disparaître celles déjà réussies. Sans doublon.
    func weighted(count: Int, stats: [String: QuestionStat], in category: Category? = nil) -> [Question] {
        let pool = category.map { questions(in: $0) } ?? questions
        func weight(_ q: Question) -> Double {
            guard let s = stats[q.id], s.seen > 0 else { return 4.0 } // jamais vue
            if s.isMastered { return 1.0 }
            if !s.lastCorrect { return 6.0 }                          // dernière réponse fausse
            return 2.5
        }
        var remaining = pool
        var picked: [Question] = []
        while picked.count < count && !remaining.isEmpty {
            let weights = remaining.map(weight)
            let total = weights.reduce(0, +)
            var r = Double.random(in: 0..<total)
            var idx = 0
            for (i, w) in weights.enumerated() {
                r -= w
                if r < 0 { idx = i; break }
            }
            picked.append(remaining.remove(at: idx))
        }
        return picked
    }

    /// Questions à revoir (vues mais non maîtrisées).
    func toReview(stats: [String: QuestionStat]) -> [Question] {
        questions.filter {
            if let s = stats[$0.id] { return s.seen > 0 && !s.isMastered }
            return false
        }
    }

    // MARK: - Examen

    /// Compose une épreuve de `AppConfig.examQuestionCount` questions,
    /// réparties au mieux sur les catégories disponibles, sans doublon.
    func examSet() -> [Question] {
        let target = AppConfig.examQuestionCount
        let cats = categoriesAvailable()
        guard !cats.isEmpty else { return [] }
        if questions.count <= target { return questions.shuffled() }

        var result: [Question] = []
        var pools: [Category: [Question]] = [:]
        for c in cats { pools[c] = questions(in: c).shuffled() }

        // Répartition équilibrée en « tourniquet ».
        outer: while result.count < target {
            var progressed = false
            for c in cats {
                if var p = pools[c], !p.isEmpty {
                    result.append(p.removeFirst())
                    pools[c] = p
                    progressed = true
                    if result.count >= target { break outer }
                }
            }
            if !progressed { break }
        }
        return result.shuffled()
    }
}
