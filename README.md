# 🌱 Planto

A SwiftUI app that helps you take care of your plants. Add your plants, set how often they need water, and get a daily reminder so none of them go thirsty.

## 📱 Screenshots

<p align="center">
  <img width="300" alt="Start screen" src="https://github.com/user-attachments/assets/f1022ada-0435-4221-abbb-93fca9ce4ec3" />
  &nbsp;&nbsp;
  <img width="300" alt="My Plants screen" src="https://github.com/user-attachments/assets/de4f5372-2468-4b7e-b910-ee1625938c8b" />
</p>


## ✨ Features

- **Plant reminders:** add a plant with its name, room, light, watering frequency and water amount.
- **Edit & delete:** tap a plant to edit it, or delete it from the edit screen or by swiping.
- **Daily progress:** tick off each plant when you water it and watch the progress bar fill up. The checkmarks reset every new day.
- **Notifications:** a local notification reminds you to water your plants.

## 🧱 Architecture (MVVM)

| Layer | Files | Role |
|---|---|---|
| Model | `PlantReminder.swift` | `PlantReminder` struct and the enums `Room`, `Light`, `WateringFrequency`, `WaterAmount` |
| ViewModel | `ReminderViewModel.swift` | add / update / delete, daily progress, saving to `UserDefaults` |
| Service | `PlantNotificationManager.swift` | permission and scheduling of local notifications |
| Views | `ContentView`, `NoReminders`, `SetReminderView` | start screen, plants list, add / edit sheet |

## 🛠 Tech Stack

- Swift & SwiftUI
- MVVM
- UserNotifications
- Liquid Glass (`.glass` / `.glassProminent`)

## 🚀 Getting Started

1. Clone the repo.
2. Open `PlantsTask.xcodeproj` in Xcode.
3. Pick an iPhone simulator and press **Cmd + R**.
