//
//  Stop.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 15.06.2026.
//

import SwiftData
import Foundation

@Model
class Stop {
    var name: String
    var country: String
    var latitude: Double
    var longitude: Double
    var arrivalDate: Date?
    var departureDate: Date?
    var order: Int
    var trip: Trip?
    
    @Relationship(deleteRule: .cascade, inverse: \TripItem.stop)
    var items: [TripItem]
    
    init(name: String, country: String, latitude: Double, longitude: Double, arrivalDate: Date? = nil, departureDate: Date? = nil, order: Int = 0) {
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
        self.order = order
        self.trip = nil
        self.items = []
    }
}
