import SwiftUI

@main
struct CivicFRApp: App {
    @StateObject private var store = Store()
    @StateObject private var bank = QuestionBank()

    var body: some Scene {
        WindowGroup {
            RootContainer()
                .environmentObject(store)
                .environmentObject(bank)
                .tint(Theme.blueDeep)
        }
    }
}

/// Décide entre onboarding et application principale, et applique les préférences.
struct RootContainer: View {
    @EnvironmentObject var store: Store
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if store.data.onboardingDone {
                RootTabView()
            } else {
                OnboardingFlow()
            }
        }
        .onAppear { applyPreferences() }
        .onChange(of: store.data.settings.soundEnabled) { _, _ in applyPreferences() }
        .onChange(of: store.data.settings.hapticsEnabled) { _, _ in applyPreferences() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { store.saveNow() }
        }
    }

    private func applyPreferences() {
        SoundManager.shared.soundEnabled = store.data.settings.soundEnabled
        SoundManager.shared.hapticsEnabled = store.data.settings.hapticsEnabled
    }
}
