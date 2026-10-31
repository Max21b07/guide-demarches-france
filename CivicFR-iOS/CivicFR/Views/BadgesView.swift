import SwiftUI

/// Badges et récompenses.
struct BadgesView: View {
    @EnvironmentObject var store: Store
    var lang: InterfaceLanguage { store.lang }

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Badges.all) { badge in
                    let unlocked = store.data.unlockedBadges.contains(badge.id)
                    VStack(spacing: 10) {
                        Image(systemName: badge.icon)
                            .font(.system(size: 36))
                            .foregroundStyle(unlocked ? Theme.yellow : .gray.opacity(0.4))
                        Text(badge.title(lang)).font(.subheadline.bold())
                            .multilineTextAlignment(.center)
                        Text(badge.descFr).font(.caption2).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .cardStyle()
                    .opacity(unlocked ? 1 : 0.6)
                    .overlay(alignment: .topTrailing) {
                        if !unlocked {
                            Image(systemName: "lock.fill").font(.caption)
                                .foregroundStyle(.secondary).padding(8)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Theme.bg)
        .navigationTitle(L.t("my.badges", lang))
        .navigationBarTitleDisplayMode(.inline)
    }
}
