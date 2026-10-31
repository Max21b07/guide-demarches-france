import SwiftUI
import Charts

/// Écran de résultats de la simulation.
struct ExamResultView: View {
    @EnvironmentObject var store: Store
    @ObservedObject var engine: ExamEngine
    @State private var recorded = false
    @State private var showCorrection = false

    var lang: InterfaceLanguage { store.lang }
    private var result: ExamResult { engine.result ?? ExamResult(score: 0, total: 0, timeUsedSeconds: 0, passThreshold: 0, perCategory: [:]) }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(result.passed ? L.t("passed", lang) : L.t("failed", lang))
                    .font(.title2.bold())
                    .foregroundStyle(result.passed ? Theme.green : Theme.orange)
                    .multilineTextAlignment(.center)

                ScoreRing(score: result.score, total: result.total, passed: result.passed)

                HStack {
                    StatTile(icon: "timer", value: result.timeUsedText, label: L.t("time.used", lang))
                    StatTile(icon: "checkmark.circle.fill", value: "\(result.score)",
                             label: L.t("good.answers", lang), color: Theme.green)
                    StatTile(icon: "xmark.circle.fill", value: "\(result.total - result.score)",
                             label: L.t("bad.answers", lang), color: Theme.red)
                }

                categoryChart
                comparison

                VStack(spacing: 12) {
                    Button(L.t("correction", lang)) { showCorrection = true }
                        .buttonStyle(PrimaryButtonStyle())
                    if !result.passed {
                        NavigationLink {
                            if let weak = weakestCategory {
                                TrainingSessionView(kind: .category(weak), count: 10,
                                                    bank: bankRef, store: store)
                            }
                        } label: {
                            Text(L.t("retry", lang))
                                .font(.headline).foregroundStyle(Theme.blueDeep)
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .overlay(RoundedRectangle(cornerRadius: Theme.corner)
                                    .stroke(Theme.blueDeep, lineWidth: 1.5))
                        }
                    }
                    Button("Retour à l'accueil") { engine.finished = false }
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Résultats")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showCorrection) {
            CorrectionView(questions: engine.questions, answers: engine.answers)
                .environmentObject(store)
        }
        .onAppear(perform: recordOnce)
    }

    @EnvironmentObject private var bankRef: QuestionBank

    private func recordOnce() {
        guard !recorded, let r = engine.result else { return }
        recorded = true
        store.recordExam(r)
        SoundManager.shared.play(r.passed ? .examPassed : .wrong)
    }

    private var weakestCategory: Category? {
        result.perCategory
            .filter { $0.value.count == 2 && $0.value[1] > 0 }
            .min(by: { Double($0.value[0]) / Double($0.value[1]) < Double($1.value[0]) / Double($1.value[1]) })
            .flatMap { Category(rawValue: $0.key) }
    }

    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: L.t("by.category", lang))
            Chart {
                ForEach(chartData, id: \.category) { item in
                    BarMark(x: .value("Taux", item.rate),
                            y: .value("Catégorie", item.label))
                        .foregroundStyle(item.color)
                        .annotation(position: .trailing) {
                            Text("\(Int(item.rate * 100))%").font(.caption2)
                        }
                }
            }
            .chartXScale(domain: 0...1)
            .frame(height: CGFloat(max(1, chartData.count) * 34 + 20))
        }
        .cardStyle()
    }

    private struct CatRate { let category: String; let label: String; let rate: Double; let color: Color }
    private var chartData: [CatRate] {
        result.perCategory.compactMap { key, pair in
            guard pair.count == 2, pair[1] > 0, let c = Category(rawValue: key) else { return nil }
            return CatRate(category: key, label: shortLabel(c),
                           rate: Double(pair[0]) / Double(pair[1]), color: c.color)
        }.sorted { $0.rate < $1.rate }
    }

    private func shortLabel(_ c: Category) -> String {
        String((lang == .vi ? c.titleVi : c.titleFr).prefix(16))
    }

    @ViewBuilder private var comparison: some View {
        let past = store.data.examResults.suffix(5)
        if past.count >= 1 {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(text: "Historique des simulations")
                Chart {
                    ForEach(Array(past.enumerated()), id: \.offset) { idx, r in
                        LineMark(x: .value("N°", idx + 1), y: .value("%", r.percentage))
                            .foregroundStyle(Theme.blueLight)
                        PointMark(x: .value("N°", idx + 1), y: .value("%", r.percentage))
                            .foregroundStyle(r.passed ? Theme.green : Theme.red)
                    }
                    RuleMark(y: .value("Seuil", AppConfig.examPassPercent))
                        .foregroundStyle(Theme.orange.opacity(0.6))
                        .lineStyle(StrokeStyle(dash: [5]))
                }
                .chartYScale(domain: 0...100)
                .frame(height: 160)
            }
            .cardStyle()
        }
    }
}
