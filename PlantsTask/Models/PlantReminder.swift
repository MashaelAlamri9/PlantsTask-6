import Foundation

struct PlantReminder: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var plantName: String
    var room: String
    var light: String
    var wateringDays: String
    var waterAmount: String
    var isCompleted: Bool = false
    // Optional so reminders saved by older builds still decode.
    var createdAt: Date? = Date()
}
