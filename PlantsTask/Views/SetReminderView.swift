import SwiftUI

struct SetReminderView: View {
    @ObservedObject var viewModel: ReminderViewModel
    @Environment(\.dismiss) private var dismiss

    private let reminder: PlantReminder?

    @State private var plantName: String
    @State private var selectedRoom: String
    @State private var selectedLight: String
    @State private var selectedDays: String
    @State private var selectedWater: String

    private let green = Color(red: 0.16, green: 0.55, blue: 0.44)

    init(viewModel: ReminderViewModel, reminder: PlantReminder? = nil) {
        self.viewModel = viewModel
        self.reminder = reminder
        _plantName = State(initialValue: reminder?.plantName ?? "")
        _selectedRoom = State(initialValue: reminder?.room ?? "Bedroom")
        _selectedLight = State(initialValue: reminder?.light ?? "Full sun")
        _selectedDays = State(initialValue: reminder?.wateringDays ?? "Every day")
        _selectedWater = State(initialValue: reminder?.waterAmount ?? "20-50 ml")
    }

    var body: some View {
        VStack(spacing: 22) {
            // MARK: - Navigation Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }

                Spacer()
                Text(reminder == nil ? "Set Reminder" : "Edit Plant")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()

                Button {
                    saveReminder()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(green)
                        .clipShape(Circle())
                }
                .disabled(plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 4)

            // MARK: - Plant Name
            HStack(spacing: 6) {
                Text("Plant Name")
                    .foregroundColor(.white)
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 1, height: 14)
                TextField("Pothos", text: $plantName)
                    .textInputAutocapitalization(.words)
                    .foregroundColor(.white)
            }
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Color.white.opacity(0.09))
            .clipShape(Capsule())

            // MARK: - Plant Settings
            VStack(spacing: 0) {
                settingRow(icon: "location", title: "Room", selection: $selectedRoom,
                           options: ["Bedroom", "Living Room", "Kitchen"])
                Divider().overlay(Color.white.opacity(0.08))
                settingRow(icon: "sun.max", title: "Light", selection: $selectedLight,
                           options: ["Full sun", "Partial sun", "Shade"])
            }
            .padding(.horizontal, 18)
            .background(Color.white.opacity(0.09))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // MARK: - Water Settings
            VStack(spacing: 0) {
                settingRow(icon: "drop", title: "Watering Days", selection: $selectedDays,
                           options: ["Every day", "Every 2 days", "Every week"])
                Divider().overlay(Color.white.opacity(0.08))
                settingRow(icon: "drop", title: "Water", selection: $selectedWater,
                           options: ["20-50 ml", "50-100 ml", "100-200 ml"])
            }
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.09))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // MARK: - Delete
            if reminder != nil {
                Button(role: .destructive) {
                    if let reminder {
                        viewModel.deleteReminder(id: reminder.id)
                    }
                    dismiss()
                } label: {
                    Text("Delete Reminder")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color.white.opacity(0.09))
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .background(Color(red: 0.11, green: 0.11, blue: 0.12).ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    // MARK: - Save
    private func saveReminder() {
        let name = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        if var existingReminder = reminder {
            existingReminder.plantName = name
            existingReminder.room = selectedRoom
            existingReminder.light = selectedLight
            existingReminder.wateringDays = selectedDays
            existingReminder.waterAmount = selectedWater
            viewModel.updateReminder(existingReminder)
        } else {
            let newReminder = PlantReminder(
                plantName: name,
                room: selectedRoom,
                light: selectedLight,
                wateringDays: selectedDays,
                waterAmount: selectedWater
            )
            viewModel.addReminder(newReminder)
        }
        dismiss()
    }

    // MARK: - Reusable Setting Row
    private func settingRow(
        icon: String,
        title: String,
        selection: Binding<String>,
        options: [String]
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 16)
            Text(title)
                .font(.system(size: 16))
            Spacer()
            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .font(.system(size: 12))
            .tint(.gray)
        }
        .foregroundColor(.white)
        .frame(height: 42)
    }
}

#Preview {
    SetReminderView(viewModel: ReminderViewModel())
        .preferredColorScheme(.dark)
}
