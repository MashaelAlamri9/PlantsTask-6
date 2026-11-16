import SwiftUI

struct SetReminderView: View {
    @ObservedObject var viewModel: ReminderViewModel
    @Environment(\.dismiss) private var dismiss

    private let reminder: PlantReminder?

    @State private var plantName: String
    @State private var selectedRoom: Room
    @State private var selectedLight: Light
    @State private var selectedDays: WateringFrequency
    @State private var selectedWater: WaterAmount

    init(viewModel: ReminderViewModel, reminder: PlantReminder? = nil) {
        self.viewModel = viewModel
        self.reminder = reminder
        _plantName = State(initialValue: reminder?.plantName ?? "")
        _selectedRoom = State(initialValue: reminder?.room ?? .bedroom)
        _selectedLight = State(initialValue: reminder?.light ?? .fullSun)
        _selectedDays = State(initialValue: reminder?.wateringDays ?? .everyDay)
        _selectedWater = State(initialValue: reminder?.waterAmount ?? .small)
    }

    private var isNameEmpty: Bool {
        plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                // MARK: - Plant Name
                HStack(spacing: 6) {
                    Text("Plant Name")
                    Rectangle()
                        .fill(.secondary)
                        .frame(width: 1, height: 14)
                    TextField("Pothos", text: $plantName)
                        .textInputAutocapitalization(.words)
                        .foregroundStyle(.tint)
                }
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(.quaternary, in: Capsule())

                // MARK: - Plant Settings
                VStack(spacing: 0) {
                    settingRow(icon: "location", title: "Room", selection: $selectedRoom)
                    Divider()
                    settingRow(icon: "sun.max", title: "Light", selection: $selectedLight)
                }
                .padding(.horizontal, 18)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 20))

                // MARK: - Water Settings
                VStack(spacing: 0) {
                    settingRow(icon: "drop", title: "Watering Days", selection: $selectedDays)
                    Divider()
                    settingRow(icon: "drop", title: "Water", selection: $selectedWater)
                }
                .padding(.horizontal, 18)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 20))

                // MARK: - Delete (Liquid Glass)
                if let reminder {
                    Button(role: .destructive) {
                        viewModel.deleteReminder(id: reminder.id)
                        dismiss()
                    } label: {
                        Text("Delete Reminder")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .tint(.red)
                    .padding(.top, 8)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .navigationTitle(reminder == nil ? "Set Reminder" : "Edit Plant")
            .navigationBarTitleDisplayMode(.inline)
            // Toolbar buttons get the Liquid Glass look automatically.
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                    .tint(.primary)

                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        saveReminder()
                    }
                    .disabled(isNameEmpty)
                }
            }
        }
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

    // MARK: - Reusable Setting Row (works with any enum option)
    private func settingRow<Option: PlantOption>(
        icon: String,
        title: String,
        selection: Binding<Option>
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 16)
            Text(title)
                .font(.system(size: 16))
            Spacer()
            Picker(title, selection: selection) {
                ForEach(Array(Option.allCases)) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .font(.system(size: 12))
            .tint(.secondary)
        }
        .frame(height: 42)
    }
}

#Preview("Light") {
    SetReminderView(viewModel: ReminderViewModel())
        .tint(Color("PlantGreen"))
}

#Preview("Dark") {
    SetReminderView(viewModel: ReminderViewModel())
        .tint(Color("PlantGreen"))
        .preferredColorScheme(.dark)
}
