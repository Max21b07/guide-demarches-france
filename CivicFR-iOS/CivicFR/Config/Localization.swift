import Foundation

/// Localisation légère de l'interface (FR / VI).
/// Les exercices restent en français ; seule l'interface est traduite.
enum L {
    private static let strings: [String: (fr: String, vi: String)] = [
        "tab.home": ("Accueil", "Trang chủ"),
        "tab.learn": ("Apprendre", "Học tập"),
        "tab.exam": ("Examen", "Thi thử"),
        "tab.profile": ("Profil", "Hồ sơ"),

        "welcome": ("Bonjour", "Xin chào"),
        "goal.title": ("Mon objectif", "Mục tiêu của tôi"),
        "goal.text": ("Réussir l'examen civique français", "Đỗ kỳ thi công dân Pháp"),
        "start.test": ("COMMENCER UN TEST", "BẮT ĐẦU LÀM BÀI"),
        "daily.training": ("Entraînement quotidien", "Luyện tập hằng ngày"),
        "review.errors": ("Révision des erreurs", "Ôn lại lỗi sai"),
        "my.stats": ("Mes statistiques", "Thống kê"),
        "my.badges": ("Mes badges", "Huy hiệu"),
        "program": ("Programme 30 jours", "Lộ trình 30 ngày"),

        "mastered": ("Maîtrisées", "Đã thành thạo"),
        "toreview": ("À revoir", "Cần ôn lại"),
        "lastscore": ("Dernier score", "Điểm gần nhất"),
        "bestscore": ("Meilleur score", "Điểm cao nhất"),
        "level": ("Niveau", "Cấp độ"),
        "streak": ("jours consécutifs", "ngày liên tục"),

        "exam.intro.title": ("Simulation d'examen", "Thi thử"),
        "exam.start": ("COMMENCER L'EXAMEN", "BẮT ĐẦU THI"),
        "exam.question": ("Question", "Câu"),
        "validate": ("Valider", "Xác nhận"),
        "next": ("Suivant", "Tiếp theo"),
        "previous": ("Précédent", "Trước"),
        "skip": ("Passer", "Bỏ qua"),
        "finish": ("Terminer", "Kết thúc"),
        "finish.exam": ("Terminer l'examen", "Nộp bài"),
        "resume": ("Reprendre", "Tiếp tục"),

        "translate": ("🇻🇳 Traduire", "🇫🇷 Dịch sang Pháp"),
        "hide.translation": ("Masquer la traduction", "Ẩn bản dịch"),

        "passed": ("BRAVO ! EXAMEN RÉUSSI", "CHÚC MỪNG! ĐẠT YÊU CẦU"),
        "failed": ("PAS ENCORE ! CONTINUE TES EFFORTS", "CHƯA ĐẠT! HÃY TIẾP TỤC CỐ GẮNG"),
        "correction": ("Correction détaillée", "Chữa bài chi tiết"),
        "retry": ("Nouvelle séance ciblée", "Luyện tập trọng điểm"),

        "settings": ("Paramètres", "Cài đặt"),
        "sound": ("Sons", "Âm thanh"),
        "haptics": ("Vibrations", "Rung"),
        "strict": ("Mode examen strict", "Chế độ thi nghiêm ngặt"),
        "notifications": ("Rappels quotidiens", "Nhắc nhở hằng ngày"),
        "reminder.hour": ("Heure du rappel", "Giờ nhắc"),
        "language": ("Langue de l'interface", "Ngôn ngữ giao diện"),

        "correct": ("Bonne réponse !", "Chính xác!"),
        "wrong": ("Pas tout à fait", "Chưa đúng"),
        "explanation": ("Explication", "Giải thích"),
        "unanswered": ("Questions non répondues", "Câu chưa trả lời"),
        "time.used": ("Temps utilisé", "Thời gian đã dùng"),
        "good.answers": ("Bonnes réponses", "Số câu đúng"),
        "bad.answers": ("Mauvaises réponses", "Số câu sai"),
        "by.category": ("Performance par catégorie", "Theo chủ đề"),
        "no.data": ("Pas encore de données", "Chưa có dữ liệu")
    ]

    static func t(_ key: String, _ lang: InterfaceLanguage) -> String {
        guard let pair = strings[key] else { return key }
        return lang == .vi ? pair.vi : pair.fr
    }
}
