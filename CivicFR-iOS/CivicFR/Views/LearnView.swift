import SwiftUI

/// Onglet Apprendre : entraînement rapide, par catégorie, révision.
struct LearnView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var bank: QuestionBank
    var lang: InterfaceLanguage { store.lang }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionTitle(text: L.t("daily.training", lang))
                    ForEach(AppConfig.trainingPresets, id: \.count) { preset in
                        NavigationLink {
                            TrainingSessionView(kind: .quick, count: preset.count, bank: bank, store: store)
                        } label: {
                            presetRow(count: preset.count, seconds: preset.seconds)
                        }
                    }

                    NavigationLink {
                        TrainingSessionView(kind: .review, count: 20, bank: bank, store: store)
                    } label: {
                        QuickAccessStatic(icon: "arrow.counterclockwise",
                                          title: L.t("review.errors", lang), color: Theme.red)
                    }

                    SectionTitle(text: L.t("by.category", lang)).padding(.top, 6)
                    ForEach(bank.categoriesAvailable()) { cat in
                        NavigationLink {
                            TrainingSessionView(kind: .category(cat), count: 10, bank: bank, store: store)
                        } label: {
                            categoryRow(cat)
                        }
                    }
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle(L.t("tab.learn", lang))
        }
    }

    private func presetRow(count: Int, seconds: Int) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "bolt.fill").font(.title2).foregroundStyle(.white)
                .frame(width: 46, height: 46).background(Theme.orange)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading) {
                Text("\(count) questions").font(.headline).foregroundStyle(.primary)
                Text("≈ \(seconds / 60) min").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .cardStyle(padding: 14)
    }

    private func categoryRow(_ cat: Category) -> some View {
        let stat = store.data.stat(for: cat)
        return HStack(spacing: 14) {
            Image(systemName: cat.icon).font(.title3).foregroundStyle(.white)
                .frame(width: 46, height: 46).background(cat.color)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(lang == .vi ? cat.titleVi : cat.titleFr)
                    .font(.subheadline.bold()).foregroundStyle(.primary)
                    .lineLimit(2)
                if stat.seen > 0 {
                    ProgressBar(value: stat.rate, color: cat.color, height: 6)
                }
            }
            Spacer()
            if stat.seen > 0 {
                Text("\(Int(stat.rate * 100)) %").font(.caption.bold()).foregroundStyle(.secondary)
            }
        }
        .cardStyle(padding: 14)
    }
}
