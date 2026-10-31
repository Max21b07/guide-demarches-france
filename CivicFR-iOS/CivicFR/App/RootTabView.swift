import SwiftUI

/// Tab Bar inférieure : Accueil · Apprendre · Examen · Profil.
struct RootTabView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var bank: QuestionBank
    @State private var selection = 0

    var lang: InterfaceLanguage { store.lang }

    var body: some View {
        TabView(selection: $selection) {
            DashboardView(goToTab: { selection = $0 })
                .tabItem { Label(L.t("tab.home", lang), systemImage: "house.fill") }
                .tag(0)

            LearnView()
                .tabItem { Label(L.t("tab.learn", lang), systemImage: "book.fill") }
                .tag(1)

            ExamTabView(bank: bank)
                .tabItem { Label(L.t("tab.exam", lang), systemImage: "checkmark.seal.fill") }
                .tag(2)

            ProfileView()
                .tabItem { Label(L.t("tab.profile", lang), systemImage: "person.fill") }
                .tag(3)
        }
        .overlay(alignment: .top) { BadgeToast() }
    }
}

/// Petite bannière quand un badge est débloqué.
struct BadgeToast: View {
    @EnvironmentObject var store: Store
    @State private var shown: Badge?

    var body: some View {
        VStack {
            if let b = shown {
                HStack(spacing: 12) {
                    Image(systemName: b.icon).font(.title2).foregroundStyle(Theme.yellow)
                    VStack(alignment: .leading) {
                        Text("Badge débloqué !").font(.caption).foregroundStyle(.secondary)
                        Text(b.title(store.lang)).font(.headline)
                    }
                    Spacer()
                }
                .cardStyle()
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: shown?.id)
        .onReceive(store.$newlyUnlocked) { _ in showNext() }
    }

    private func showNext() {
        guard shown == nil, let b = store.consumeNewlyUnlocked() else { return }
        SoundManager.shared.play(.badge)
        shown = b
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            shown = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showNext() }
        }
    }
}
