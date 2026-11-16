import Foundation

// MARK: - Options (Enums)
/// Shared shape for every fixed-choice option, so one Picker row can serve all of them.
/// Raw values match the old saved strings, so reminders saved by earlier builds still decode.
protocol PlantOption: RawRepresentable, CaseIterable, Identifiable, Hashable, Codable where RawValue == String {}

extension PlantOption {
    var id: String { rawValue }
}

enum Room: String, PlantOption {
    case bedroom = "Bedroom"
    case livingRoom = "Living Room"
    case kitchen = "Kitchen"
}

enum Light: String, PlantOption {
    case fullSun = "Full sun"
    case partialSun = "Partial sun"
    case shade = "Shade"
}

enum WateringFrequency: String, PlantOption {
    case everyDay = "Every day"
    case everyTwoDays = "Every 2 days"
    case everyWeek = "Every week"
}

enum WaterAmount: String, PlantOption {
    case small = "20-50 ml"
    case medium = "50-100 ml"
    case large = "100-200 ml"
}

// MARK: - Model
struct PlantReminder: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var plantName: String
    var room: Room
    var light: Light
    var wateringDays: WateringFrequency
    var waterAmount: WaterAmount
    var isCompleted: Bool = false
    // Optional so reminders saved by older builds still decode.
    var createdAt: Date? = Date()
}
