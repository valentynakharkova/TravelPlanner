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
    
    func requestAccess() async throws {
        let granded = try await eventStore.requestFullAccessToEvents()
        if !granded {
            throw EventKitError.accessDenied
        }
    }
    
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
