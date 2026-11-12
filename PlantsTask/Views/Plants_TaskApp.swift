//
//  Plant_TaskApp.swift
//  Plant Task
//
//  Created by Mashael on 30/05/1448 AH.
//
import SwiftUI

@main
struct Plants_TaskApp: App {

    init() {
        // Makes sure the notification delegate is set before any notification arrives.
        _ = PlantNotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
