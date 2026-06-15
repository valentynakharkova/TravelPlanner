//
//  ItemType.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 15.06.2026.
//

import SwiftUI

enum ItemType: String, CaseIterable, Codable {
    case hotel, attraction, restaurant, other
    
    var label: String {
        switch self {
        case .hotel:
            "Hotel"
        case .attraction:
            "Attraction"
        case .restaurant:
            "Restaurant"
        case .other:
            "Other"
        }
    }
    
    var icon: Image {
        switch self {
        case .hotel:
            Image(systemName: "bed.double.fill")
        case .attraction:
            Image(systemName: "star.fill")
        case .restaurant:
            Image(systemName: "fork.knife")
        case .other:
            Image(systemName: "mappin")
        }
    }
    
    var color: Color {
        switch self {
        case .hotel:
                .blue
        case .attraction:
                .orange
        case .restaurant:
                .green
        case .other:
                .gray
        }
    }
}

