import SwiftUI
import Charts

/// Statistiques et suivi des progrès.
struct StatsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var bank: QuestionBank
    var lang: InterfaceLanguage { store.lang }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                overview
                categoryBreakdown
                weaknesses
                examHistory
            }
            .padding()
        }
        .background(Theme.bg)
        .navigationTitle(L.t("my.stats", lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var overview: some View {
        VStack(spacing: 12) {
            HStack {
                StatTile(icon: "questionmark.circle.fill", value: "\(store.data.totalAnswered)", label: "Questions")
                StatTile(icon: "percent", value: "\(Int(store.data.globalRate * 100))",
                         label: "Taux de réussite", color: Theme.green)
            }
            HStack {
                StatTile(icon: "clock.fill", value: hoursText, label: "Apprentissage", color: Theme.orange)
                StatTile(icon: "checkmark.seal.fill", value: "\(store.data.examCount)",
                         label: "Simulations", color: Theme.blueDeep)
            }
            HStack {
                StatTile(icon: "flame.fill", value: "\(store.data.longestStreak)",
                         label: "Record série", color: Theme.red)
                StatTile(icon: "trophy.fill", value: "\(store.data.bestExamScore)",
                         label: L.t("bestscore", lang), color: Theme.yellow)
            }
        }
    }

    private var hoursText: String {
        let h = store.data.learningSeconds / 3600
        let m = (store.data.learningSeconds % 3600) / 60
        return h > 0 ? "\(h)h\(String(format: "%02d", m))" : "\(m) min"
    }

    @ViewBuilder private var categoryBreakdown: some View {
        let data = categoryData
        if data.isEmpty {
            emptyCard
        } else {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(text: L.t("by.category", lang))
                Chart {
                    ForEach(data, id: \.name) { d in
                        BarMark(x: .value("%", d.rate), y: .value("Cat", d.name))
                            .foregroundStyle(d.color)
                            .annotation(position: .trailing) { Text("\(Int(d.rate * 100))%").font(.caption2) }
                    }
                }
                .chartXScale(domain: 0...1)
                .frame(height: CGFloat(data.count * 34 + 20))
            }
            .cardStyle()
        }
    }

    private struct CatData { let name: String; let rate: Double; let color: Color }
    private var categoryData: [CatData] {
        Category.allCases.compactMap { c in
            let s = store.data.stat(for: c)
            guard s.seen > 0 else { return nil }
            return CatData(name: String((lang == .vi ? c.titleVi : c.titleFr).prefix(16)),
                           rate: s.rate, color: c.color)
        }
    }

    @ViewBuilder private var weaknesses: some View {
        let weak = Category.allCases
            .map { ($0, store.data.stat(for: $0)) }
            .filter { $0.1.seen >= 3 }
            .sorted { $0.1.rate < $1.1.rate }
            .prefix(3)
        if !weak.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(text: "À retravailler en priorité")
                ForEach(Array(weak.enumerated()), id: \.offset) { _, pair in
                    let cat = pair.0
                    let stat = pair.1
                    NavigationLink {
                        TrainingSessionView(kind: .category(cat), count: 10, bank: bank, store: store)
                    } label: {
                        HStack {
                            Image(systemName: cat.icon).foregroundStyle(cat.color)
                            Text(lang == .vi ? cat.titleVi : cat.titleFr).foregroundStyle(.primary)
                                .lineLimit(1)
                            Spacer()
                            Text("\(Int(stat.rate * 100))%").foregroundStyle(Theme.orange).font(.subheadline.bold())
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .cardStyle()
        }
    }

    @ViewBuilder private var examHistory: some View {
        let results = store.data.examResults.suffix(10)
        if results.count >= 1 {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(text: "Évolution des simulations")
                Chart {
                    ForEach(Array(results.enumerated()), id: \.offset) { i, r in
                        LineMark(x: .value("N°", i + 1), y: .value("%", r.percentage))
                            .foregroundStyle(Theme.blueLight)
                        PointMark(x: .value("N°", i + 1), y: .value("%", r.percentage))
                            .foregroundStyle(r.passed ? Theme.green : Theme.red)
                    }
                    RuleMark(y: .value("Seuil", AppConfig.examPassPercent))
                        .foregroundStyle(Theme.orange.opacity(0.6))
                        .lineStyle(StrokeStyle(dash: [5]))
                }
                .chartYScale(domain: 0...100)
                .frame(height: 170)
            }
            .cardStyle()
        }
    }

    private var emptyCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar").font(.largeTitle).foregroundStyle(.secondary)
            Text(L.t("no.data", lang)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).cardStyle()
    }
}
