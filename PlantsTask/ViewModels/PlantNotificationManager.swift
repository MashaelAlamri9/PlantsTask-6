import Foundation
import UserNotifications

/// Schedules the "let's water your plant" local notifications.
final class PlantNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PlantNotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let reminderHour = 9          // notifications arrive at 9:00 AM
    private let upcomingEveryTwoDays = 14 // how many "every 2 days" alerts to keep booked

    private override init() {
        super.init()
        center.delegate = self
    }

    // MARK: - Public API
    /// Asks for permission the first time, then (re)books the notifications for this plant.
    func schedule(for reminder: PlantReminder) {
        Task {
            guard await isAllowed() else { return }
            await replace(for: reminder)
        }
    }

    func cancel(for id: UUID) {
        Task { await removePending(for: id) }
    }

    func rescheduleAll(_ reminders: [PlantReminder]) {
        Task {
            guard await isAllowed() else { return }
            for reminder in reminders {
                await replace(for: reminder)
            }
        }
    }

    // MARK: - Permission
    private func isAllowed() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    // MARK: - Scheduling
    private func replace(for reminder: PlantReminder) async {
        await removePending(for: reminder.id)
        for request in makeRequests(for: reminder) {
            try? await center.add(request)
        }
    }

    private func removePending(for id: UUID) async {
        let prefix = id.uuidString
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func makeRequests(for reminder: PlantReminder) -> [UNNotificationRequest] {
        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let's water your plant"
        content.sound = .default

        let calendar = Calendar.current
        let anchor = reminder.createdAt ?? Date()
        let id = reminder.id.uuidString

        switch reminder.wateringDays {
        case "Every week":
            var components = DateComponents()
            components.hour = reminderHour
            components.weekday = calendar.component(.weekday, from: anchor)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            return [UNNotificationRequest(identifier: "\(id)-weekly", content: content, trigger: trigger)]

        case "Every 2 days":
            // Calendar triggers can't repeat every 2 days, so book the next few dates one by one.
            var requests: [UNNotificationRequest] = []
            let startOfAnchor = calendar.startOfDay(for: anchor)
            var step = 0
            while requests.count < upcomingEveryTwoDays && step < 400 {
                defer { step += 1 }
                guard
                    let day = calendar.date(byAdding: .day, value: step * 2, to: startOfAnchor),
                    let fireDate = calendar.date(bySettingHour: reminderHour, minute: 0, second: 0, of: day),
                    fireDate > Date()
                else { continue }

                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                requests.append(UNNotificationRequest(identifier: "\(id)-\(step)", content: content, trigger: trigger))
            }
            return requests

        default: // "Every day"
            var components = DateComponents()
            components.hour = reminderHour
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            return [UNNotificationRequest(identifier: "\(id)-daily", content: content, trigger: trigger)]
        }
    }

    // MARK: - Show the banner even while the app is open
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
