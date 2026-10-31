import SwiftUI

/// Tableau de bord principal (onglet Accueil).
struct DashboardView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var bank: QuestionBank
    var goToTab: (Int) -> Void

    var lang: InterfaceLanguage { store.lang }
    private var level: Level { Levels.current(for: store.data.xp) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    goalCard
                    Button(L.t("start.test", lang)) {
                        SoundManager.shared.tap(); goToTab(2)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    quickAccess
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle("CIVIC FR")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 46)).foregroundStyle(Theme.blueDeep)
            VStack(alignment: .leading, spacing: 2) {
                Text(L.t("welcome", lang)).font(.title2.bold())
                Text("\(L.t("level", lang)) · \(level.name(lang))")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 2) {
                Image(systemName: "flame.fill").foregroundStyle(Theme.orange)
                Text("\(store.data.streakDays)").font(.headline)
                Text(L.t("streak", lang)).font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(L.t("goal.title", lang), systemImage: "target")
                .font(.headline).foregroundStyle(Theme.blueDeep)
            Text("« \(L.t("goal.text", lang)) »").font(.title3.bold())

            ProgressBar(value: Levels.progress(for: store.data.xp), color: Theme.blueDeep)
            Text("\(store.data.xp) XP · \(level.name(lang))")
                .font(.caption).foregroundStyle(.secondary)

            HStack {
                metric("\(store.data.masteredCount)", L.t("mastered", lang), Theme.green)
                Divider()
                metric("\(store.data.toReviewCount)", L.t("toreview", lang), Theme.orange)
                Divider()
                metric("\(store.data.lastExamResult?.score ?? 0)", L.t("lastscore", lang), Theme.blueLight)
                Divider()
                metric("\(store.data.bestExamScore)", L.t("bestscore", lang), Theme.blueDeep)
            }
        }
        .cardStyle()
    }

    private func metric(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.title3.bold()).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var quickAccess: some View {
        VStack(spacing: 12) {
            QuickAccessCard(icon: "bolt.fill", title: L.t("daily.training", lang),
                            color: Theme.orange) { goToTab(1) }
            NavigationLink { ReviewErrorsView() } label: {
                QuickAccessStatic(icon: "arrow.counterclockwise", title: L.t("review.errors", lang), color: Theme.red)
            }
            NavigationLink { StatsView() } label: {
                QuickAccessStatic(icon: "chart.bar.fill", title: L.t("my.stats", lang), color: Theme.blueLight)
            }
            NavigationLink { BadgesView() } label: {
                QuickAccessStatic(icon: "rosette", title: L.t("my.badges", lang), color: Theme.yellow)
            }
            NavigationLink { ProgramView() } label: {
                QuickAccessStatic(icon: "calendar", title: L.t("program", lang), color: Theme.green)
            }
        }
    }
}

/// Variante non-bouton pour NavigationLink.
struct QuickAccessStatic: View {
    var icon: String; var title: String; var color: Color
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title2).foregroundStyle(.white)
                .frame(width: 46, height: 46).background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(title).font(.headline).foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .cardStyle(padding: 14)
    }
}
