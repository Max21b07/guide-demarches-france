import SwiftUI

/// Paramètres et gestion des notifications.
struct SettingsView: View {
    @EnvironmentObject var store: Store
    @State private var showResetConfirm = false
    var lang: InterfaceLanguage { store.lang }

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                var c = DateComponents()
                c.hour = store.data.settings.reminderHour
                c.minute = store.data.settings.reminderMinute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                store.data.settings.reminderHour = c.hour ?? 19
                store.data.settings.reminderMinute = c.minute ?? 0
                rescheduleNotifications()
            }
        )
    }

    var body: some View {
        Form {
            Section(L.t("language", lang)) {
                Picker(L.t("language", lang), selection: $store.data.settings.interfaceLanguage) {
                    ForEach(InterfaceLanguage.allCases, id: \.self) { l in
                        Text("\(l.flag) \(l.label)").tag(l)
                    }
                }
                Text("Les exercices restent toujours en français.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Expérience") {
                Toggle(L.t("sound", lang), isOn: $store.data.settings.soundEnabled)
                Toggle(L.t("haptics", lang), isOn: $store.data.settings.hapticsEnabled)
                Toggle(L.t("strict", lang), isOn: $store.data.settings.strictExamMode)
                Text("En mode strict, la traduction est désactivée pendant les simulations.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section(L.t("notifications", lang)) {
                Toggle(L.t("notifications", lang), isOn: $store.data.settings.notificationsEnabled)
                    .onChange(of: store.data.settings.notificationsEnabled) { _, on in
                        Task { await toggleNotifications(on) }
                    }
                if store.data.settings.notificationsEnabled {
                    DatePicker(L.t("reminder.hour", lang), selection: reminderTime,
                               displayedComponents: .hourAndMinute)
                    Stepper("Rappels par semaine : \(store.data.settings.remindersPerWeek)",
                            value: $store.data.settings.remindersPerWeek, in: 1...7)
                        .onChange(of: store.data.settings.remindersPerWeek) { _, _ in rescheduleNotifications() }
                }
            }

            Section {
                Button("Réinitialiser ma progression", role: .destructive) { showResetConfirm = true }
            } footer: {
                Text("Banque : \(bankCountText). Toutes les données restent sur cet iPhone.")
            }
        }
        .navigationTitle(L.t("settings", lang))
        .navigationBarTitleDisplayMode(.inline)
        .alert("Réinitialiser ?", isPresented: $showResetConfirm) {
            Button("Annuler", role: .cancel) {}
            Button("Réinitialiser", role: .destructive) { store.resetProgress() }
        } message: {
            Text("Cette action efface XP, badges, séries et statistiques.")
        }
    }

    @EnvironmentObject private var bank: QuestionBank
    private var bankCountText: String { "\(bank.count) questions" }

    private func toggleNotifications(_ on: Bool) async {
        if on {
            let granted = await NotificationManager.shared.requestAuthorization()
            if granted {
                await NotificationManager.shared.schedule(
                    hour: store.data.settings.reminderHour,
                    minute: store.data.settings.reminderMinute,
                    perWeek: store.data.settings.remindersPerWeek)
            } else {
                store.data.settings.notificationsEnabled = false
            }
        } else {
            NotificationManager.shared.cancelAll()
        }
    }

    private func rescheduleNotifications() {
        guard store.data.settings.notificationsEnabled else { return }
        Task {
            await NotificationManager.shared.schedule(
                hour: store.data.settings.reminderHour,
                minute: store.data.settings.reminderMinute,
                perWeek: store.data.settings.remindersPerWeek)
        }
    }
}
