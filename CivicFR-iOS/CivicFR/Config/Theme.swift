import SwiftUI
import UIKit

/// Palette et styles communs. S'adapte au mode clair / sombre.
enum Theme {
    static let blueDeep = Color(red: 0.10, green: 0.22, blue: 0.55)   // confiance / institutions
    static let blueLight = Color(red: 0.26, green: 0.56, blue: 0.96)  // progression
    static let green = Color(red: 0.20, green: 0.74, blue: 0.45)      // bonne réponse
    static let red = Color(red: 0.92, green: 0.30, blue: 0.33)        // mauvaise réponse
    static let orange = Color(red: 0.98, green: 0.63, blue: 0.16)     // attention / progression
    static let yellow = Color(red: 0.99, green: 0.80, blue: 0.22)

    /// Fond légèrement cassé (clair) / sombre.
    static let bg = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)

    static let corner: CGFloat = 18
    static let cardShadow = Color.black.opacity(0.06)
}

// MARK: - Styles réutilisables

struct CardModifier: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
            .shadow(color: Theme.cardShadow, radius: 10, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View { modifier(CardModifier(padding: padding)) }
}

/// Grand bouton principal.
struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = Theme.blueDeep
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
