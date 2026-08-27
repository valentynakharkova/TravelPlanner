//
//  NotificationService.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 17.07.2026.
//

import Foundation
import UserNotifications
import SwiftData

@Observable
class NotificationService {
    private let center = UNUserNotificationCenter.current()
    
    enum NotificationError: LocalizedError {
        case accessDenied
        case noDateSet
        
        var errorDescription: String? {
            switch self {
            case .accessDenied:
                return "Notification access was denied. You can enable it in Settings."
            case .noDateSet:
                return "This stop doesn't have an arrival date set."
            }
        }
    }
    
    /// Request permission to show alerts, sounds and badges
    /// - Throws: `NotificationError.accessDenied` if the user declines
    func requestAuthorization() async throws {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        if !granted {
            throw NotificationError.accessDenied
        }
    }
    
    /// Request a local notification e day before the stops's arrival date.
    /// Requests notification authorization if not already granted.
    /// - Parameter stop: The stop to schedule a reminder for. The stop must have an `arrivaleDate`.
    /// - Throws: `NotificationError.noDateSet` if stop doesn't have `arrivalDate`.
    /// - or `NotificationError.acessDenied` if permission was declined.
    func scheduleArrivalReminder(for stop: Stop) async throws {
        guard let arrivalDate = stop.arrivalDate else {
            throw NotificationError.noDateSet
        }
        try await requestAuthorization()
        
        let content = UNMutableNotificationContent()
        content.title = "Arriving tomorrow"
        content.body = "You arrive in \(stop.name) tomorrow."
        content.sound = .default
        
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: arrivalDate) else { return }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: stop.id.hashValue.description, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    /// Cancels previously arrival reminder for the given stop.
    func cancelReminder(for stop: Stop) {
        center.removePendingNotificationRequests(withIdentifiers: [stop.id.hashValue.description])
    }
}


