import SwiftUI

/// Onglet Examen : intro → simulation → résultats.
struct ExamTabView: View {
    @EnvironmentObject var store: Store
    @StateObject private var engine: ExamEngine

    init(bank: QuestionBank) {
        _engine = StateObject(wrappedValue: ExamEngine(bank: bank))
    }

    var body: some View {
        NavigationStack {
            Group {
                if engine.finished, engine.result != nil {
                    ExamResultView(engine: engine)
                } else if engine.isRunning {
                    ExamView(engine: engine)
                } else {
                    ExamIntroView(engine: engine)
                }
            }
            .background(Theme.bg)
        }
    }
}

/// Écran de préparation avant l'examen.
struct ExamIntroView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var bank: QuestionBank
    @ObservedObject var engine: ExamEngine
    var lang: InterfaceLanguage { store.lang }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56)).foregroundStyle(Theme.blueDeep)
                Text(L.t("exam.intro.title", lang)).font(.title.bold())

                VStack(alignment: .leading, spacing: 14) {
                    infoRow("list.number", "\(AppConfig.examQuestionCount) questions")
                    infoRow("timer", "\(AppConfig.examDurationMinutes) minutes")
                    infoRow("target", "Seuil de réussite : \(AppConfig.examPassPercent) %")
                    infoRow("eye.slash", "Aucun indice pendant l'épreuve")
                    infoRow("globe", store.data.settings.strictExamMode
                            ? "Mode strict : traduction désactivée"
                            : "Traduction 🇻🇳 disponible à la demande")
                }
                .cardStyle()

                Text("Format conforme à l'examen civique officiel (40 q · 45 min · 80 %). Questions pédagogiques, non officielles — référence : Livret du citoyen.")
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if bank.count < AppConfig.examQuestionCount {
                    Text("⚠️ La banque contient \(bank.count) questions. L'examen en utilisera \(min(bank.count, AppConfig.examQuestionCount)).")
                        .font(.caption).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if engine.hasSavedSession {
                    Button(L.t("resume", lang)) { _ = engine.resumeIfAvailable() }
                        .buttonStyle(PrimaryButtonStyle(color: Theme.orange))
                }

                Button(L.t("exam.start", lang)) {
                    SoundManager.shared.tap()
                    engine.start(strict: store.data.settings.strictExamMode)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(bank.count == 0)
            }
            .padding()
        }
        .navigationTitle(L.t("tab.exam", lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).frame(width: 26).foregroundStyle(Theme.blueLight)
            Text(text); Spacer()
        }
    }
}
