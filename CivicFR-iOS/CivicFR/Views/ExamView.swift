import SwiftUI

/// Déroulement de la simulation (conditions d'examen).
struct ExamView: View {
    @EnvironmentObject var store: Store
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var engine: ExamEngine

    @State private var showTranslation = false
    @State private var showSummary = false
    @State private var confirmFinish = false

    var lang: InterfaceLanguage { store.lang }
    private var canTranslate: Bool { !engine.strict }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            if let q = engine.current { questionBody(q) }
            bottomBar
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("\(L.t("exam.question", lang)) \(engine.currentIndex + 1)/\(engine.total)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showSummary = true } label: { Image(systemName: "list.bullet.rectangle") }
            }
        }
        .sheet(isPresented: $showSummary) { summarySheet }
        .onChange(of: scenePhase) { _, phase in if phase == .active { engine.tick() } }
        .alert("Terminer l'examen ?", isPresented: $confirmFinish) {
            Button("Annuler", role: .cancel) {}
            Button(L.t("finish", lang), role: .destructive) { engine.finish() }
        } message: {
            Text("\(engine.answeredCount)/\(engine.total) questions répondues.")
        }
    }

    private var topBar: some View {
        VStack(spacing: 8) {
            HStack {
                Label(engine.timeText, systemImage: "timer")
                    .font(.title3.monospacedDigit().bold())
                    .foregroundStyle(engine.remaining < 300 ? Theme.red : Theme.blueDeep)
                Spacer()
                Text("\(engine.answeredCount)/\(engine.total)")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            ProgressBar(value: Double(engine.currentIndex + 1) / Double(max(1, engine.total)))
        }
        .padding()
        .background(Theme.card)
    }

    private func questionBody(_ q: Question) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(q.questionFr).font(.title3.bold())
                    if showTranslation && canTranslate {
                        Text(q.questionVi).font(.body).foregroundStyle(.secondary)
                    }
                }
                .cardStyle()

                if canTranslate {
                    Button {
                        withAnimation { showTranslation.toggle() }
                    } label: {
                        Label(showTranslation ? L.t("hide.translation", lang) : L.t("translate", lang),
                              systemImage: "character.bubble").font(.subheadline)
                    }
                }

                ForEach(q.answersFr.indices, id: \.self) { i in
                    AnswerOption(text: q.answersFr[i],
                                 translation: (showTranslation && canTranslate) ? q.answersVi[i] : nil,
                                 state: engine.answers[engine.currentIndex] == i ? .selected : .normal) {
                        engine.select(i); SoundManager.shared.tap()
                    }
                }
            }
            .padding()
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                engine.previous()
            } label: {
                Image(systemName: "chevron.left"); Text(L.t("previous", lang))
            }
            .disabled(engine.currentIndex == 0)

            Spacer()

            if engine.currentIndex == engine.total - 1 {
                Button(L.t("finish.exam", lang)) { confirmFinish = true }
                    .fontWeight(.bold).foregroundStyle(Theme.green)
            } else {
                Button {
                    engine.next()
                } label: {
                    Text(L.t("next", lang)); Image(systemName: "chevron.right")
                }
                .fontWeight(.bold)
            }
        }
        .padding()
        .background(Theme.card)
    }

    private var summarySheet: some View {
        NavigationStack {
            List {
                Section(L.t("unanswered", lang)) {
                    if engine.unansweredIndices.isEmpty {
                        Text("Toutes les questions sont répondues ✅").foregroundStyle(.secondary)
                    }
                    ForEach(engine.unansweredIndices, id: \.self) { i in
                        Button("\(L.t("exam.question", lang)) \(i + 1)") {
                            engine.goto(i); showSummary = false
                        }
                    }
                }
                Section {
                    Button(L.t("finish.exam", lang), role: .destructive) {
                        showSummary = false; confirmFinish = true
                    }
                }
            }
            .navigationTitle(L.t("finish.exam", lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { showSummary = false }
                }
            }
        }
    }
}
