import SwiftUI

/// Correction détaillée d'un examen : réponses données vs correctes, explications.
struct CorrectionView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let questions: [Question]
    let answers: [Int?]
    @State private var wrongOnly = false

    var lang: InterfaceLanguage { store.lang }

    private var indices: [Int] {
        questions.indices.filter { i in
            if !wrongOnly { return true }
            return answers[safe: i].flatMap { $0 } != questions[i].correctAnswer
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    Picker("Filtre", selection: $wrongOnly) {
                        Text("Tout").tag(false)
                        Text("Erreurs uniquement").tag(true)
                    }
                    .pickerStyle(.segmented)

                    ForEach(indices, id: \.self) { i in
                        CorrectionCard(index: i, question: questions[i],
                                       given: answers[safe: i].flatMap { $0 }, lang: lang)
                    }
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle(L.t("correction", lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Fermer") { dismiss() } }
            }
        }
    }
}

struct CorrectionCard: View {
    let index: Int
    let question: Question
    let given: Int?
    let lang: InterfaceLanguage
    @State private var translate = false

    private var isCorrect: Bool { given == question.correctAnswer }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Q\(index + 1)").font(.caption.bold()).foregroundStyle(.secondary)
                Spacer()
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(isCorrect ? Theme.green : Theme.red)
            }
            Text(question.questionFr).font(.headline)
            if translate { Text(question.questionVi).font(.subheadline).foregroundStyle(.secondary) }

            ForEach(question.answersFr.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: icon(for: i)).foregroundStyle(color(for: i))
                    Text(question.answersFr[i])
                        .foregroundStyle(i == question.correctAnswer ? Theme.green : .primary)
                    Spacer()
                }
                .font(.subheadline)
            }

            Divider()
            Text(question.explanationFr).font(.subheadline)
            if translate { Text(question.explanationVi).font(.subheadline).foregroundStyle(.secondary) }

            Button {
                withAnimation { translate.toggle() }
            } label: {
                Label(translate ? L.t("hide.translation", lang) : L.t("translate", lang),
                      systemImage: "character.bubble").font(.caption)
            }
        }
        .cardStyle()
    }

    private func icon(for i: Int) -> String {
        if i == question.correctAnswer { return "checkmark.circle.fill" }
        if i == given { return "xmark.circle.fill" }
        return "circle"
    }
    private func color(for i: Int) -> Color {
        if i == question.correctAnswer { return Theme.green }
        if i == given { return Theme.red }
        return .secondary
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
