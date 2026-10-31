import SwiftUI

/// Programme d'apprentissage personnalisé sur 30 jours.
struct ProgramView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var bank: QuestionBank
    var lang: InterfaceLanguage { store.lang }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                ForEach(ProgramPlan.weeks) { week in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Semaine \(week.number) · \(week.title)")
                            .font(.headline).foregroundStyle(Theme.blueDeep)
                        ForEach(week.days) { day in
                            dayRow(day)
                        }
                    }
                    .cardStyle()
                }
                // Suggestion adaptative selon les faiblesses.
                if let weak = weakestCategory {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Conseil personnalisé", systemImage: "lightbulb.fill")
                            .font(.headline).foregroundStyle(Theme.orange)
                        Text("Ta catégorie la plus fragile est « \(lang == .vi ? weak.titleVi : weak.titleFr) ». Travaille-la en priorité.")
                            .font(.subheadline)
                        NavigationLink {
                            TrainingSessionView(kind: .category(weak), count: 10, bank: bank, store: store)
                        } label: {
                            Text("S'entraîner maintenant").font(.subheadline.bold())
                        }
                    }
                    .cardStyle()
                }
            }
            .padding()
        }
        .background(Theme.bg)
        .navigationTitle(L.t("program", lang))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.startProgramIfNeeded() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Préparation en 30 jours").font(.title3.bold())
            Text("Jour \(store.programDay) / \(AppConfig.programDays)")
                .font(.subheadline).foregroundStyle(.secondary)
            ProgressBar(value: Double(store.programDay) / Double(AppConfig.programDays), color: Theme.green)
        }
        .cardStyle()
    }

    @ViewBuilder private func dayRow(_ day: ProgramDay) -> some View {
        let done = day.number < store.programDay
        let current = day.number == store.programDay
        let content = HStack(spacing: 12) {
            ZStack {
                Circle().fill(current ? Theme.green : (done ? Theme.blueLight : Color.gray.opacity(0.2)))
                    .frame(width: 30, height: 30)
                if done { Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white) }
                else { Text("\(day.number)").font(.caption.bold()).foregroundStyle(current ? .white : .secondary) }
            }
            Text(day.label).font(.subheadline)
                .foregroundStyle(current ? .primary : .secondary)
            Spacer()
            if day.category != nil || day.isSimulation {
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
            }
        }

        if let cat = day.category {
            NavigationLink {
                TrainingSessionView(kind: .category(cat), count: 10, bank: bank, store: store)
            } label: { content }
        } else if day.isSimulation {
            NavigationLink { SimulationLauncher() } label: { content }
        } else {
            content
        }
    }

    private var weakestCategory: Category? {
        Category.allCases
            .map { ($0, store.data.stat(for: $0)) }
            .filter { $0.1.seen >= 3 }
            .min { $0.1.rate < $1.1.rate }?.0
    }
}

/// Petit lanceur renvoyant vers l'onglet examen (via message).
struct SimulationLauncher: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 54)).foregroundStyle(Theme.blueDeep)
            Text("Lance une simulation complète").font(.headline)
            Text("Rends-toi dans l'onglet « Examen » pour démarrer une épreuve de \(AppConfig.examQuestionCount) questions.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Contenu du programme

struct ProgramDay: Identifiable {
    let number: Int
    let label: String
    var category: Category? = nil
    var isSimulation: Bool = false
    var id: Int { number }
}

struct ProgramWeek: Identifiable {
    let number: Int
    let title: String
    let days: [ProgramDay]
    var id: Int { number }
}

enum ProgramPlan {
    static let weeks: [ProgramWeek] = [
        ProgramWeek(number: 1, title: "Fondations", days: [
            ProgramDay(number: 1, label: "Valeurs de la République", category: .valeurs),
            ProgramDay(number: 2, label: "Droits et devoirs", category: .droits),
            ProgramDay(number: 3, label: "Institutions françaises", category: .institutions),
            ProgramDay(number: 4, label: "Valeurs (approfondissement)", category: .valeurs),
            ProgramDay(number: 5, label: "Institutions européennes", category: .institutions),
            ProgramDay(number: 6, label: "Révision des erreurs"),
            ProgramDay(number: 7, label: "Mini-simulation", isSimulation: true)
        ]),
        ProgramWeek(number: 2, title: "Histoire & géographie", days: [
            ProgramDay(number: 8, label: "Histoire de France", category: .histoire),
            ProgramDay(number: 9, label: "Symboles et histoire", category: .histoire),
            ProgramDay(number: 10, label: "Géographie", category: .geographie),
            ProgramDay(number: 11, label: "Géographie (approfondissement)", category: .geographie),
            ProgramDay(number: 12, label: "Droits et devoirs", category: .droits),
            ProgramDay(number: 13, label: "Révision des erreurs"),
            ProgramDay(number: 14, label: "Mini-simulation", isSimulation: true)
        ]),
        ProgramWeek(number: 3, title: "Vie en France", days: [
            ProgramDay(number: 15, label: "Vie quotidienne", category: .vieQuotidienne),
            ProgramDay(number: 16, label: "Travail", category: .travail),
            ProgramDay(number: 17, label: "Santé et protection sociale", category: .sante),
            ProgramDay(number: 18, label: "Éducation", category: .education),
            ProgramDay(number: 19, label: "Famille et démarches", category: .famille),
            ProgramDay(number: 20, label: "Révision des erreurs"),
            ProgramDay(number: 21, label: "Mini-simulation", isSimulation: true)
        ]),
        ProgramWeek(number: 4, title: "Révisions & examens blancs", days: [
            ProgramDay(number: 22, label: "Révision générale", category: .valeurs),
            ProgramDay(number: 23, label: "Révision institutions", category: .institutions),
            ProgramDay(number: 24, label: "Révision histoire/géo", category: .histoire),
            ProgramDay(number: 25, label: "Révision vie en France", category: .vieQuotidienne),
            ProgramDay(number: 26, label: "Simulation complète", isSimulation: true),
            ProgramDay(number: 27, label: "Correction des lacunes"),
            ProgramDay(number: 28, label: "Simulation complète", isSimulation: true),
            ProgramDay(number: 29, label: "Révision ciblée"),
            ProgramDay(number: 30, label: "Examen blanc final", isSimulation: true)
        ])
    ]
}
