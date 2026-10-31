import Foundation

/// Niveaux de progression (inspiré Duolingo), basés sur l'XP cumulée.
struct Level: Identifiable {
    let id: Int
    let nameFr: String
    let nameVi: String
    let minXP: Int

    func name(_ lang: InterfaceLanguage) -> String { lang == .vi ? nameVi : nameFr }
}

enum Levels {
    static let all: [Level] = [
        Level(id: 0, nameFr: "Débutante", nameVi: "Người mới", minXP: 0),
        Level(id: 1, nameFr: "Apprentie", nameVi: "Học viên", minXP: 200),
        Level(id: 2, nameFr: "Exploratrice", nameVi: "Khám phá", minXP: 500),
        Level(id: 3, nameFr: "Confirmée", nameVi: "Vững vàng", minXP: 1000),
        Level(id: 4, nameFr: "Experte", nameVi: "Chuyên gia", minXP: 2000),
        Level(id: 5, nameFr: "Prête pour l'examen", nameVi: "Sẵn sàng thi", minXP: 3500)
    ]

    static func current(for xp: Int) -> Level {
        all.last { xp >= $0.minXP } ?? all[0]
    }

    static func next(for xp: Int) -> Level? {
        all.first { $0.minXP > xp }
    }

    /// Progression (0...1) vers le niveau suivant.
    static func progress(for xp: Int) -> Double {
        let cur = current(for: xp)
        guard let nxt = next(for: xp) else { return 1 }
        let span = nxt.minXP - cur.minXP
        guard span > 0 else { return 1 }
        return Double(xp - cur.minXP) / Double(span)
    }
}
