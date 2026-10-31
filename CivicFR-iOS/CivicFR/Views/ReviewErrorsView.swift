import SwiftUI

/// Révision des erreurs : séance d'entraînement limitée aux questions non maîtrisées.
struct ReviewErrorsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var bank: QuestionBank

    var body: some View {
        TrainingSessionView(kind: .review, count: 20, bank: bank, store: store)
            .navigationTitle(L.t("review.errors", store.lang))
            .navigationBarTitleDisplayMode(.inline)
    }
}
