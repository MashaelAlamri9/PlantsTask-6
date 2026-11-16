import Foundation
import UserNotifications

/// إشعار واحد للتطبيق كله بدل إشعار لكل نبتة.
final class PlantNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PlantNotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let reminderHour = 9
    private let upcomingEveryTwoDays = 14
    private let testHourly = true   // للاختبار فقط، خلها false في النهاية

    private override init() {
        super.init()
        center.delegate = self
    }

    // MARK: - Public API
    /// يشتغل الإشعار لو فيه تذكير، ويتلغي لو القائمة فاضية.
    func sync(with reminders: [PlantReminder]) {
        Task {
            center.removeAllPendingNotificationRequests()
            guard !reminders.isEmpty, await isAllowed() else { return }
            for request in makeRequests(for: reminders) {
                try? await center.add(request)
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
    private func makeRequests(for reminders: [PlantReminder]) -> [UNNotificationRequest] {
        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let's water your plant"
        content.sound = .default

        if testHourly {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
            return [UNNotificationRequest(identifier: "planto-hourly", content: content, trigger: trigger)]
        }

        let calendar = Calendar.current
        let frequencies = Set(reminders.map(\.wateringDays))
        let anchor = reminders.compactMap(\.createdAt).min() ?? Date()

        if frequencies.contains(.everyDay) {
            var components = DateComponents()
            components.hour = reminderHour
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            return [UNNotificationRequest(identifier: "planto-daily", content: content, trigger: trigger)]
        }

        if frequencies.contains(.everyTwoDays) {
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
                requests.append(UNNotificationRequest(identifier: "planto-\(step)", content: content, trigger: trigger))
            }
            return requests
        }

        // Every week
        var components = DateComponents()
        components.hour = reminderHour
        components.weekday = calendar.component(.weekday, from: anchor)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        return [UNNotificationRequest(identifier: "planto-weekly", content: content, trigger: trigger)]
    }

    // MARK: - Show the banner even while the app is open
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
