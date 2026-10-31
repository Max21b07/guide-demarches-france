import SwiftUI

// MARK: - Catégories du programme civique

enum Category: String, Codable, CaseIterable, Identifiable {
    case valeurs
    case institutions
    case droits
    case histoire
    case geographie
    case vieQuotidienne
    case education
    case sante
    case travail
    case famille

    var id: String { rawValue }

    /// Décodage tolérant : une valeur inconnue dans le JSON ne casse pas tout le chargement.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Category(rawValue: raw) ?? .vieQuotidienne
    }

    var titleFr: String {
        switch self {
        case .valeurs: return "Valeurs de la République"
        case .institutions: return "Institutions françaises et européennes"
        case .droits: return "Droits et devoirs"
        case .histoire: return "Histoire de France"
        case .geographie: return "Géographie de la France"
        case .vieQuotidienne: return "Vie quotidienne"
        case .education: return "Éducation et école"
        case .sante: return "Santé et protection sociale"
        case .travail: return "Travail et vie professionnelle"
        case .famille: return "Famille et démarches"
        }
    }

    var titleVi: String {
        switch self {
        case .valeurs: return "Giá trị của nền Cộng hòa"
        case .institutions: return "Thể chế Pháp và châu Âu"
        case .droits: return "Quyền và nghĩa vụ"
        case .histoire: return "Lịch sử nước Pháp"
        case .geographie: return "Địa lý nước Pháp"
        case .vieQuotidienne: return "Đời sống hằng ngày"
        case .education: return "Giáo dục và trường học"
        case .sante: return "Y tế và an sinh xã hội"
        case .travail: return "Việc làm và nghề nghiệp"
        case .famille: return "Gia đình và thủ tục hành chính"
        }
    }

    var icon: String {
        switch self {
        case .valeurs: return "flag.fill"
        case .institutions: return "building.columns.fill"
        case .droits: return "checkmark.seal.fill"
        case .histoire: return "clock.fill"
        case .geographie: return "map.fill"
        case .vieQuotidienne: return "house.fill"
        case .education: return "graduationcap.fill"
        case .sante: return "cross.case.fill"
        case .travail: return "briefcase.fill"
        case .famille: return "person.3.fill"
        }
    }

    var color: Color {
        switch self {
        case .valeurs: return Theme.blueDeep
        case .institutions: return Theme.blueLight
        case .droits: return Theme.green
        case .histoire: return .brown
        case .geographie: return .teal
        case .vieQuotidienne: return Theme.orange
        case .education: return .indigo
        case .sante: return .pink
        case .travail: return .purple
        case .famille: return .cyan
        }
    }
}

// MARK: - Difficulté

enum Difficulty: String, Codable, CaseIterable {
    case easy, medium, hard

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Difficulty(rawValue: raw) ?? .medium
    }

    var titleFr: String {
        switch self {
        case .easy: return "Facile"
        case .medium: return "Moyen"
        case .hard: return "Difficile"
        }
    }
}

// MARK: - Origine de la question

enum SourceType: String, Codable {
    case officialVerified = "official_verified"
    case educational
    case generated

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = SourceType(rawValue: raw) ?? .educational
    }

    var labelFr: String {
        switch self {
        case .officialVerified: return "Officiel vérifié"
        case .educational: return "Pédagogique"
        case .generated: return "Générée"
        }
    }
}

// MARK: - Langue d'interface

enum InterfaceLanguage: String, Codable, CaseIterable {
    case fr, vi
    var flag: String { self == .fr ? "🇫🇷" : "🇻🇳" }
    var label: String { self == .fr ? "Français" : "Tiếng Việt" }
}
