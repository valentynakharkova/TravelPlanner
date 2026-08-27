//
//  TripPhoto.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 04.08.2026.
//

import Foundation
import SwiftData

@Model
class TripPhoto {
    var photoData: Data
    var order: Int
    var trip: Trip?
    
    init(photoData: Data, order: Int, ) {
        self.photoData = photoData
        self.order = order
        self.trip = nil
    }
    
}
