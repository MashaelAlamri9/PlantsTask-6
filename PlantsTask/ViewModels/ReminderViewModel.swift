import Foundation
import Combine

final class ReminderViewModel: ObservableObject {
    @Published private(set) var reminders: [PlantReminder] = []

    private let remindersKey = "PlantsTask.reminders"
    private let progressDateKey = "PlantsTask.progressDate"

    init() {
        loadReminders()
        refreshForNewDay()
    }

    // MARK: - Progress
    var completedCount: Int {
        reminders.filter(\.isCompleted).count
    }

    var progress: Double {
        guard !reminders.isEmpty else { return 0 }
        return Double(completedCount) / Double(reminders.count)
    }

    // MARK: - Add
    func addReminder(_ reminder: PlantReminder) {
        reminders.append(reminder)
        saveReminders()
        rescheduleNotifications()
    }

    // MARK: - Update
    func updateReminder(_ updatedReminder: PlantReminder) {
        guard let index = reminders.firstIndex(where: { $0.id == updatedReminder.id }) else {
            return
        }
        reminders[index] = updatedReminder
        saveReminders()
        rescheduleNotifications()
    }

    // MARK: - Delete
    func deleteReminder(id: UUID) {
        reminders.removeAll { $0.id == id }
        saveReminders()
        rescheduleNotifications()
    }

    func deleteReminder(at offsets: IndexSet) {
        // Delete from the last index first so earlier indexes do not shift.
        for index in offsets.sorted(by: >) {
            guard reminders.indices.contains(index) else { continue }
            reminders.remove(at: index)
        }
        saveReminders()
        rescheduleNotifications()
    }

    // MARK: - Daily Checkmark
    func toggleCompletion(for reminder: PlantReminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else {
            return
        }
        reminders[index].isCompleted.toggle()
        saveReminders()
    }

    // MARK: - Persistence
    private func saveReminders() {
        guard let data = try? JSONEncoder().encode(reminders) else { return }
        UserDefaults.standard.set(data, forKey: remindersKey)
    }

    private func loadReminders() {
        guard
            let data = UserDefaults.standard.data(forKey: remindersKey),
            let savedReminders = try? JSONDecoder().decode([PlantReminder].self, from: data)
        else {
            reminders = []
            return
        }
        reminders = savedReminders
    }

    // Re-books the upcoming notifications (keeps the every-2-days ones topped up).
    func rescheduleNotifications() {
        PlantNotificationManager.shared.sync(with: reminders)
    }
    // The checkmarks start fresh when the calendar day changes.
    // Also called when the app returns to the foreground, in case it stayed open past midnight.
    func refreshForNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let savedDate = UserDefaults.standard.object(forKey: progressDateKey) as? Date

        // Already refreshed today, nothing to do.
        if let savedDate, Calendar.current.isDate(savedDate, inSameDayAs: today) {
            return
        }

        for index in reminders.indices {
            reminders[index].isCompleted = false
        }
        UserDefaults.standard.set(today, forKey: progressDateKey)
        saveReminders()
    }
}
