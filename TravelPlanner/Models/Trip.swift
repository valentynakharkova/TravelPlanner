//
//  Trip.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 15.06.2026.
//

import Foundation
import SwiftData

@Model
class Trip {
    var name: String
    var startDate: Date
    var endDate: Date
    var coverPhoto: Data?
    var isArchived: Bool
    var deletedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \Stop.trip)
    var stops: [Stop]
    
    @Relationship(deleteRule: .cascade, inverse: \TripPhoto.trip)
    var photos: [TripPhoto]
    
    init(name: String, startDate: Date, endDate: Date) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.coverPhoto = nil
        self.isArchived = false
        self.stops = []
        self.deletedAt = nil
        self.photos = []
    }
}
