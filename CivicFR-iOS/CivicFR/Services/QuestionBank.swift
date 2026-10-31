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
        // On ignore les questions mal formées, puis on mélange les réponses
        // (déterministe par identifiant) pour que la bonne réponse ne soit pas
        // toujours en première position.
        questions = decoded.filter { $0.isValid }.map { Self.shuffledAnswers($0) }
    }

    /// Permutation déterministe des réponses d'une question, stable d'un lancement
    /// à l'autre (reprise d'examen cohérente).
    static func shuffledAnswers(_ q: Question) -> Question {
        var seed = UInt64(fnv1a(q.id))
        func next() -> UInt64 { seed &+= 0x9E3779B97F4A7C15
            var z = seed
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31) }
        var order = Array(q.answersFr.indices)
        var i = order.count - 1
        while i > 0 {
            let j = Int(next() % UInt64(i + 1))
            order.swapAt(i, j); i -= 1
        }
        let fr = order.map { q.answersFr[$0] }
        let vi = order.map { q.answersVi[$0] }
        let newCorrect = order.firstIndex(of: q.correctAnswer) ?? q.correctAnswer
        return Question(id: q.id, category: q.category, subcategory: q.subcategory,
                        difficulty: q.difficulty, questionFr: q.questionFr, questionVi: q.questionVi,
                        answersFr: fr, answersVi: vi, correctAnswer: newCorrect,
                        explanationFr: q.explanationFr, explanationVi: q.explanationVi,
                        sourceUrl: q.sourceUrl, sourceType: q.sourceType, verifiedAt: q.verifiedAt)
    }

    private static func fnv1a(_ s: String) -> UInt32 {
        var h: UInt32 = 2166136261
        for b in s.utf8 { h ^= UInt32(b); h = h &* 16777619 }
        return h
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
