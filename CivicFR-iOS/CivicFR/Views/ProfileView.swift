import SwiftUI

/// Onglet Profil : résumé, accès statistiques, badges, programme, paramètres.
struct ProfileView: View {
    @EnvironmentObject var store: Store
    var lang: InterfaceLanguage { store.lang }
    private var level: Level { Levels.current(for: store.data.xp) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    profileHeader
                    HStack {
                        StatTile(icon: "flame.fill", value: "\(store.data.streakDays)",
                                 label: L.t("streak", lang), color: Theme.orange)
                        StatTile(icon: "star.fill", value: "\(store.data.xp)",
                                 label: "XP", color: Theme.yellow)
                        StatTile(icon: "rosette", value: "\(store.data.unlockedBadges.count)",
                                 label: L.t("my.badges", lang), color: Theme.blueLight)
                    }
                    VStack(spacing: 12) {
                        NavigationLink { StatsView() } label: {
                            QuickAccessStatic(icon: "chart.bar.fill", title: L.t("my.stats", lang), color: Theme.blueLight)
                        }
                        NavigationLink { BadgesView() } label: {
                            QuickAccessStatic(icon: "rosette", title: L.t("my.badges", lang), color: Theme.yellow)
                        }
                        NavigationLink { ProgramView() } label: {
                            QuickAccessStatic(icon: "calendar", title: L.t("program", lang), color: Theme.green)
                        }
                        NavigationLink { SettingsView() } label: {
                            QuickAccessStatic(icon: "gearshape.fill", title: L.t("settings", lang), color: .gray)
                        }
                    }
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle(L.t("tab.profile", lang))
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64)).foregroundStyle(Theme.blueDeep)
            Text(level.name(lang)).font(.title2.bold())
            ProgressBar(value: Levels.progress(for: store.data.xp), color: Theme.blueDeep)
            if let next = Levels.next(for: store.data.xp) {
                Text("\(store.data.xp) / \(next.minXP) XP → \(next.name(lang))")
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                Text("Niveau maximum atteint 🎉").font(.caption).foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }
}
