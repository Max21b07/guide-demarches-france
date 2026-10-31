import SwiftUI

/// Splash → présentation → choix de la langue d'interface.
struct OnboardingFlow: View {
    @EnvironmentObject var store: Store
    @State private var step = 0

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.blueDeep, Theme.blueLight],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch step {
            case 0: splash
            case 1: intro
            default: languagePick
            }
        }
        .foregroundStyle(.white)
    }

    private var splash: some View {
        VStack(spacing: 20) {
            Image(systemName: "flag.checkered.2.crossed")
                .font(.system(size: 72))
            Text("CIVIC FR").font(.system(size: 40, weight: .heavy))
            Text("Réussir l'examen civique").font(.title3)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation { step = 1 }
            }
        }
    }

    private var intro: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "graduationcap.fill").font(.system(size: 64))
            Text("Préparez l'examen civique français")
                .font(.title.bold()).multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 14) {
                featureRow("checkmark.seal.fill", "Simulations complètes dans les conditions de l'examen")
                featureRow("globe", "Aide en vietnamien à la demande 🇻🇳")
                featureRow("flame.fill", "Entraînement quotidien et progression")
            }
            .padding()
            Spacer()
            Button("Continuer") { withAnimation { step = 2 } }
                .buttonStyle(PrimaryButtonStyle(color: .white.opacity(0.95)))
                .tint(Theme.blueDeep)
                .foregroundStyle(Theme.blueDeep)
        }
        .padding()
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).font(.title3).frame(width: 28)
            Text(text)
            Spacer()
        }
    }

    private var languagePick: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Langue de l'interface").font(.title.bold())
            Text("Les exercices restent en français").font(.subheadline).opacity(0.85)
            ForEach(InterfaceLanguage.allCases, id: \.self) { lang in
                Button {
                    store.data.settings.interfaceLanguage = lang
                    SoundManager.shared.tap()
                    finish()
                } label: {
                    HStack {
                        Text(lang.flag).font(.largeTitle)
                        Text(lang.label).font(.title3.bold())
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.corner))
                }
                .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding()
    }

    private func finish() {
        store.data.onboardingDone = true
        store.saveNow()
    }
}
