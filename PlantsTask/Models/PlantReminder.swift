import Foundation

// MARK: - Options (Enums)
/// Shared shape for every fixed-choice option, so one Picker row can serve all of them.
protocol PlantOption: RawRepresentable, CaseIterable, Identifiable, Hashable, Codable where RawValue == String {}

extension PlantOption {
    var id: String { rawValue }
}

enum Room: String, PlantOption {
    case bedroom = "Bedroom"
    case livingRoom = "Living Room"
    case kitchen = "Kitchen"
    case balcony = "Balcony"
    case bathroom = "Bathroom"
}

enum Light: String, PlantOption {
    case fullSun = "Full Sun"
    case partialSun = "Partial Sun"
    case lowLight = "Low Light"

    var icon: String {
        switch self {
        case .fullSun: return "sun.max"
        case .partialSun: return "sun.horizon"
        case .lowLight: return "moon"
        }
    }

    /// Reminders saved by older builds used different strings; map them to the new cases.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw {
        case "Full sun": self = .fullSun
        case "Partial sun": self = .partialSun
        case "Shade": self = .lowLight
        default:
            guard let value = Light(rawValue: raw) else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: decoder.codingPath, debugDescription: "Unknown light value: \(raw)")
                )
            }
            self = value
        }
    }
}

enum WateringFrequency: String, PlantOption {
    case everyDay = "Every day"
    case everyTwoDays = "Every 2 days"
    case everyThreeDays = "Every 3 days"
    case onceAWeek = "Once a week"
    case everyTenDays = "Every 10 days"
    case everyTwoWeeks = "Every 2 weeks"

    /// "Every week" was the old saved value for what is now "Once a week".
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        if raw == "Every week" {
            self = .onceAWeek
            return
        }
        guard let value = WateringFrequency(rawValue: raw) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unknown frequency: \(raw)")
            )
        }
        self = value
    }
}

enum WaterAmount: String, PlantOption {
    case small = "20-50 ml"
    case medium = "50-100 ml"
    case large = "100-200 ml"
    case extraLarge = "200-300 ml"
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
