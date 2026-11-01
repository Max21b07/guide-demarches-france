import SwiftUI

/// Séance d'entraînement avec feedback immédiat, animation et son.
struct TrainingSessionView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @StateObject private var engine: TrainingEngine

    let kind: TrainingKind
    let count: Int
    @State private var showTranslation = false
    @State private var started = false

    init(kind: TrainingKind, count: Int, bank: QuestionBank, store: Store) {
        self.kind = kind
        self.count = count
        _engine = StateObject(wrappedValue: TrainingEngine(bank: bank, store: store))
    }

    var lang: InterfaceLanguage { store.lang }

    var body: some View {
        Group {
            if engine.finished {
                TrainingSummary(engine: engine) { dismiss() }
            } else if engine.isEmpty {
                emptyState
            } else {
                session
            }
        }
        .background(Theme.bg)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: startIfNeeded)
    }

    private func startIfNeeded() {
        guard !started else { return }
        started = true
        switch kind {
        case .quick: engine.startQuick(count: count)
        case .category(let c): engine.startCategory(c, count: count)
        case .review: engine.startReview(count: count)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle").font(.system(size: 54)).foregroundStyle(Theme.green)
            Text("Rien à revoir pour le moment !").font(.headline)
            Text("Entraîne-toi encore pour remplir cette liste.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Retour") { dismiss() }.buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }

    @ViewBuilder private var session: some View {
        if let q = engine.current {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Progression
                    HStack {
                        Text("\(engine.index + 1)/\(engine.total)").font(.subheadline.bold())
                        Spacer()
                        Label("\(engine.correctCount)", systemImage: "checkmark.seal.fill")
                            .font(.subheadline).foregroundStyle(Theme.green)
                    }
                    ProgressBar(value: Double(engine.index) / Double(max(1, engine.total)))

                    // Énoncé
                    VStack(alignment: .leading, spacing: 8) {
                        if q.isSituation {
                            Text("📘 Mise en situation").font(.caption.bold()).foregroundStyle(Theme.orange)
                        }
                        Text(q.questionFr).font(.title3.bold())
                        if showTranslation {
                            Text(q.questionVi).font(.body).foregroundStyle(.secondary)
                        }
                    }
                    .cardStyle()

                    translateButton

                    // Réponses
                    ForEach(q.answersFr.indices, id: \.self) { i in
                        AnswerOption(text: q.answersFr[i],
                                     translation: showTranslation ? q.answersVi[i] : nil,
                                     state: optionState(q, i)) {
                            engine.select(i); SoundManager.shared.tap()
                        }
                    }

                    if engine.revealed { explanation(q) }

                    actionButton(q)
                }
                .padding()
                .animation(.easeInOut, value: engine.revealed)
            }
        }
    }

    private var translateButton: some View {
        Button {
            withAnimation { showTranslation.toggle() }
        } label: {
            Label(showTranslation ? L.t("hide.translation", lang) : L.t("translate", lang),
                  systemImage: "character.bubble")
                .font(.subheadline)
        }
    }

    private func optionState(_ q: Question, _ i: Int) -> AnswerOption.State {
        if engine.revealed {
            if i == q.correctAnswer { return .correct }
            if i == engine.selected { return .wrong }
            return .dimmed
        }
        return engine.selected == i ? .selected : .normal
    }

    @ViewBuilder private func explanation(_ q: Question) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(engine.lastAnswerCorrect ? L.t("correct", lang) : L.t("wrong", lang),
                  systemImage: engine.lastAnswerCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                .font(.headline)
                .foregroundStyle(engine.lastAnswerCorrect ? Theme.green : Theme.orange)
            Text(q.explanationFr).font(.subheadline)
            if showTranslation {
                Text(q.explanationVi).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .cardStyle()
        .transition(.opacity)
    }

    @ViewBuilder private func actionButton(_ q: Question) -> some View {
        if engine.revealed {
            Button(engine.index == engine.total - 1 ? L.t("finish", lang) : L.t("next", lang)) {
                withAnimation { engine.advance() }
            }
            .buttonStyle(PrimaryButtonStyle(color: Theme.green))
        } else {
            Button(L.t("validate", lang)) {
                engine.validate()
                SoundManager.shared.play(engine.lastAnswerCorrect ? .correct : .wrong)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(engine.selected == nil)
            .opacity(engine.selected == nil ? 0.5 : 1)
        }
    }
}

/// Récapitulatif de fin d'entraînement.
struct TrainingSummary: View {
    @ObservedObject var engine: TrainingEngine
    @EnvironmentObject var store: Store
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: engine.accuracy >= 0.8 ? "star.circle.fill" : "hand.thumbsup.fill")
                .font(.system(size: 72))
                .foregroundStyle(engine.accuracy >= 0.8 ? Theme.yellow : Theme.blueLight)
            Text("Séance terminée !").font(.title.bold())
            Text("\(engine.correctCount)/\(engine.total) bonnes réponses")
                .font(.title3).foregroundStyle(.secondary)
            Text("+\(AppConfig.xpSessionComplete) XP").font(.headline).foregroundStyle(Theme.green)
            Spacer()
            Button("Terminer") { onClose() }.buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .onAppear { SoundManager.shared.play(.levelUp) }
    }
}
