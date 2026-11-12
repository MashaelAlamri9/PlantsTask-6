import SwiftUI

struct NoReminders: View {
    @ObservedObject var viewModel: ReminderViewModel
    @State private var activeSheet: ReminderSheet?

    private let green = Color(red: 0.20, green: 0.70, blue: 0.56)

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Text("My Plants 🌱")
                    .font(.system(size: 32, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Divider()
                .overlay(Color.white.opacity(0.13))
                .padding(.top, 16)

            // MARK: - Today Progress
            if !viewModel.reminders.isEmpty && !allCompleted {
                VStack(spacing: 10) {
                    Text(progressMessage)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                            Capsule()
                                .fill(green)
                                .frame(width: geometry.size.width * viewModel.progress)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 32)
                .padding(.top, 28)
                .padding(.bottom, 24)
            }

            // MARK: - Plant List
            if viewModel.reminders.isEmpty {
                Spacer()
                Text("No reminders set yet..")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            } else if allCompleted {
                allDoneView
            } else {
                List {
                    ForEach(viewModel.reminders) { reminder in
                        plantRow(reminder)
                            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                            .listRowBackground(Color.black)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteReminder(id: reminder.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .labelStyle(.iconOnly)
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }

            // MARK: - Add Button
            HStack {
                Spacer()
                Button {
                    activeSheet = .add
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 42, height: 42)
                        .background(Color(red: 0.16, green: 0.55, blue: 0.44))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add plant reminder")
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .add:
                SetReminderView(viewModel: viewModel)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(Color(red: 0.11, green: 0.11, blue: 0.12))
            case .edit(let reminder):
                SetReminderView(viewModel: viewModel, reminder: reminder)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(Color(red: 0.11, green: 0.11, blue: 0.12))
            }
        }
    }

    private var allCompleted: Bool {
        !viewModel.reminders.isEmpty && viewModel.completedCount == viewModel.reminders.count
    }

    // MARK: - All Done
    private var allDoneView: some View {
        VStack(spacing: 10) {
            Spacer()
            Image("plant_placeholder")
                .resizable()
                .scaledToFit()
                .frame(width: 190, height: 190)
            Text("All Done! 🎉")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text("All Reminders Completed")
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var progressMessage: String {
        if viewModel.completedCount == 0 {
            return "Your plants are waiting for a sip 💦"
        }
        return "\(viewModel.completedCount) of your plants feel loved today ✨"
    }

    @ViewBuilder
    private func plantRow(_ reminder: PlantReminder) -> some View {
        HStack(spacing: 16) {
            Button {
                viewModel.toggleCompletion(for: reminder)
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(reminder.isCompleted ? green : .gray)
                    .frame(width: 26, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(reminder.isCompleted ? "Mark as not done" : "Mark as done")

            // Tap the row to edit or delete the plant.
            Button {
                activeSheet = .edit(reminder)
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.northwest")
                            .font(.system(size: 11))
                        Text("in \(reminder.room)")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.gray)
                    .opacity(reminder.isCompleted ? 0.5 : 1)

                    Text(reminder.plantName)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(reminder.isCompleted ? .gray : .white)

                    HStack(spacing: 8) {
                        infoTag(icon: "sun.max", text: reminder.light, color: .yellow)
                        infoTag(icon: "drop", text: reminder.waterAmount, color: Color(red: 0.55, green: 0.80, blue: 0.90))
                    }
                    .opacity(reminder.isCompleted ? 0.5 : 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 6)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.13))
                .frame(height: 0.5)
        }
    }

    private func infoTag(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

private enum ReminderSheet: Identifiable {
    case add
    case edit(PlantReminder)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let reminder):
            return reminder.id.uuidString
        }
    }
}

#Preview {
    NavigationStack {
        NoReminders(viewModel: ReminderViewModel())
            .preferredColorScheme(.dark)
    }
}
