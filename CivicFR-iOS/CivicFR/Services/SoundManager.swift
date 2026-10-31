import AVFoundation
import AudioToolbox
import UIKit

/// Effets sonores (sons système, sans fichiers audio externes) et retours haptiques.
/// Tout est désactivable via les paramètres.
@MainActor
final class SoundManager {
    static let shared = SoundManager()
    private init() {}

    var soundEnabled = true
    var hapticsEnabled = true

    enum Effect {
        case correct, wrong, levelUp, badge, examPassed
        var systemSoundID: SystemSoundID {
            switch self {
            case .correct: return 1057      // Tink
            case .wrong: return 1053        // doux
            case .levelUp: return 1025
            case .badge: return 1016
            case .examPassed: return 1025
            }
        }
    }

    func play(_ effect: Effect) {
        if soundEnabled { AudioServicesPlaySystemSound(effect.systemSoundID) }
        if hapticsEnabled { haptic(for: effect) }
    }

    private func haptic(for effect: Effect) {
        switch effect {
        case .correct, .examPassed, .levelUp, .badge:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .wrong:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    func tap() {
        if hapticsEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    }
}
