import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReminderViewModel()
    @State private var showReminder = false
    @State private var goToNoReminders = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("My Plants 🌱")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)

                Divider()
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                Spacer()

                Image("plant_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 330)

                Spacer()

                VStack(spacing: 20) {
                    Text("Start your plant journey!")
                        .font(.system(size: 26, weight: .bold))

                    Text("Now all your plants will be in one place and we will help you take care of them :) 🪴")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                Spacer()

                // Liquid Glass button
                Button {
                    showReminder = true
                } label: {
                    Text("Set Plant Reminder")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .padding(.horizontal, 45)
                .padding(.bottom, 40)
            }
            .onAppear {
                // Plants are saved, so skip the onboarding screen on relaunch.
                if !viewModel.reminders.isEmpty {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) { goToNoReminders = true }
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    viewModel.refreshForNewDay()
                    viewModel.rescheduleNotifications()
                }
            }
            .navigationDestination(isPresented: $goToNoReminders) {
                NoReminders(viewModel: viewModel)
            }
            .sheet(isPresented: $showReminder, onDismiss: {
                // X and Save both return to the plant-list screen.
                goToNoReminders = true
            }) {
                SetReminderView(viewModel: viewModel)
                    .presentationDetents([.large])
            }
        }
    }
}

#Preview("Light") {
    ContentView()
        .tint(Color("PlantGreen"))
}

#Preview("Dark") {
    ContentView()
        .tint(Color("PlantGreen"))
        .preferredColorScheme(.dark)
}
