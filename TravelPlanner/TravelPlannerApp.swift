//
//  TravelPlannerApp.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 15.06.2026.
//

import SwiftUI
import SwiftData

@main
struct TravelPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            TripListView()
        }
        .modelContainer(for: [Trip.self, Stop.self, TripItem.self])
    }
}
