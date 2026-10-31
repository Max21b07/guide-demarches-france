import Foundation
import UserNotifications

/// Rappels quotidiens locaux (UserNotifications). Respecte le consentement utilisateur.
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let messages: [String] = [
        "Il est temps de réviser ! 5 minutes suffisent pour progresser.",
        "Quelques questions aujourd'hui pour garder ta série 🔥",
        "Aujourd'hui, révise les institutions françaises.",
        "Prête pour l'examen civique ? Entraîne-toi un peu !",
        "Ta progression t'attend. On continue ?"
    ]

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// Programme `perWeek` rappels par semaine à l'heure donnée.
    func schedule(hour: Int, minute: Int, perWeek: Int) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        // Jours de la semaine à utiliser (1 = dimanche ... 7 = samedi).
        let weekdays = daysForFrequency(perWeek)
        for day in weekdays {
            var comps = DateComponents()
            comps.hour = hour
            comps.minute = minute
            comps.weekday = day

            let content = UNMutableNotificationContent()
            content.title = "CIVIC FR"
            content.body = messages.randomElement() ?? messages[0]
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let req = UNNotificationRequest(identifier: "civicfr.reminder.\(day)",
                                            content: content, trigger: trigger)
            try? await center.add(req)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func daysForFrequency(_ perWeek: Int) -> [Int] {
        let n = min(max(perWeek, 1), 7)
        let all = Array(1...7)
        if n == 7 { return all }
        // Répartit les jours sur la semaine.
        var picked: [Int] = []
        let step = Double(7) / Double(n)
        for i in 0..<n { picked.append(all[Int((Double(i) * step).rounded()) % 7]) }
        return Array(Set(picked)).sorted()
    }
}
