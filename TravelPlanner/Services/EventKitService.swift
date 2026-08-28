//
//  EventKitService.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 16.07.2026.
//

import Foundation
import EventKit

@Observable
class EventKitService {
    private let eventStore = EKEventStore()
    
    enum EventKitError: LocalizedError {
        case accessDenied
        
        var errorDescription: String? {
            switch self {
            case .accessDenied:
                return "Access to your calendar is denied. You can enable it in Settings"
            }
        }
    }
    /// Requests full access to the user's calendar.
    /// - Throws: `EventKitError.accessDenied` if the user declines.
    func requestAccess() async throws {
        let granted = try await eventStore.requestFullAccessToEvents()
        if !granted {
            throw EventKitError.accessDenied
        }
    }
    
    /// Adds 'all-day' event to the calendar within trip's dates to the user defaulta calendar.
    /// Requests calendar access if not already granded.
    /// - Parameters:
    ///  - name: Ttitle of the calendar event - trips name.
    ///  - startDate: start date of the trip.
    ///  - endDate: end date of the trip.
    ///  - Throws: `EventJit.accessDenied` if permission was declined.
    /// or an error from `EventKitStore` if the event fails to save.
    func addTripToCalendar(name: String, startDate: Date, endDate: Date) async throws {
        try await requestAccess()
        
        let event = EKEvent(eventStore: eventStore)
        event.title = name
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = true
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        try eventStore.save(event, span: .thisEvent)
    }
    
    
}
