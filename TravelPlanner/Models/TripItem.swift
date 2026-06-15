//
//  TripItem.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 15.06.2026.
//

import SwiftData
import Foundation

@Model
class TripItem {
    var name: String
    var type: ItemType
    var address: String
    var latitude: Double
    var longitude: Double
    var notes: String?
    var date: Date?
    var photo: Data?
    var stop: Stop?
        
    init(name: String, type: ItemType, address: String, latitude: Double, longitude: Double) {
        self.name = name
        self.type = type
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.notes = nil
        self.date = nil
        self.photo = nil
        self.stop = nil
    }
}
