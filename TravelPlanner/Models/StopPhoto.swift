//
//  StopPhoto.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 21.07.2026.
//

import Foundation
import SwiftData

@Model
class StopPhoto {
    var photoData: Data
    var order: Int
    var stop: Stop?
    
    init(photoData: Data, order: Int) {
        self.photoData = photoData
        self.order = order
        self.stop = nil
    }
}
