import SwiftUI

// MARK: - Barre de progression

struct ProgressBar: View {
    var value: Double            // 0...1
    var color: Color = Theme.blueLight
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.18))
                Capsule().fill(color)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
                    .animation(.easeOut(duration: 0.4), value: value)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Tuile statistique

struct StatTile: View {
    var icon: String
    var value: String
    var label: String
    var color: Color = Theme.blueDeep

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(value).font(.title3.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle(padding: 14)
    }
}

// MARK: - Carte d'accès rapide

struct QuickAccessCard: View {
    var icon: String
    var title: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: { SoundManager.shared.tap(); action() }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2).foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(title).font(.headline).foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .cardStyle(padding: 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - En-tête de section

struct SectionTitle: View {
    var text: String
    var body: some View {
        Text(text).font(.title3.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Option de réponse (QCM)

struct AnswerOption: View {
    var text: String
    var translation: String?
    var state: State
    var action: () -> Void

    enum State { case normal, selected, correct, wrong, dimmed }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: symbol)
                    .foregroundStyle(iconColor)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 3) {
                    Text(text).foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let tr = translation, !tr.isEmpty {
                        Text(tr).font(.subheadline).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .multilineTextAlignment(.leading)
            .padding(14)
            .background(bg)
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(border, lineWidth: 1.5))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(state == .dimmed ? 0.5 : 1)
        }
        .buttonStyle(.plain)
    }

    private var symbol: String {
        switch state {
        case .correct: return "checkmark.circle.fill"
        case .wrong: return "xmark.circle.fill"
        case .selected: return "largecircle.fill.circle"
        default: return "circle"
        }
    }
    private var iconColor: Color {
        switch state {
        case .correct: return Theme.green
        case .wrong: return Theme.red
        case .selected: return Theme.blueDeep
        default: return .secondary
        }
    }
    private var bg: Color {
        switch state {
        case .correct: return Theme.green.opacity(0.12)
        case .wrong: return Theme.red.opacity(0.12)
        case .selected: return Theme.blueLight.opacity(0.12)
        default: return Theme.card
        }
    }
    private var border: Color {
        switch state {
        case .correct: return Theme.green
        case .wrong: return Theme.red
        case .selected: return Theme.blueDeep
        default: return Color.gray.opacity(0.2)
        }
    }
}

// MARK: - Badge circulaire de score

struct ScoreRing: View {
    var score: Int
    var total: Int
    var passed: Bool

    private var fraction: Double { total == 0 ? 0 : Double(score) / Double(total) }

    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.15), lineWidth: 14)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(passed ? Theme.green : Theme.orange,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: fraction)
            VStack {
                Text("\(score)/\(total)").font(.largeTitle.bold())
                Text("\(Int((fraction * 100).rounded())) %").foregroundStyle(.secondary)
            }
        }
        .frame(width: 180, height: 180)
    }
}
