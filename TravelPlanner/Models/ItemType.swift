//
//  ItemType.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 15.06.2026.
//

import SwiftUI

enum ItemType: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case hotel, museum, restaurant, other
    
    var label: String {
        switch self {
        case .hotel:
            "Hotel"
        case .museum:
            "Museum"
        case .restaurant:
            "Restaurant"
        case .other:
            "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .hotel:
            "bed.double.fill"
        case .museum:
            "building.columns.fill"
        case .restaurant:
            "fork.knife"
        case .other:
            "mappin"
        }
    }
    
    var icon: Image {
        Image(systemName: iconName)
    }
    
    var color: Color {
        switch self {
        case .hotel:
                .blue
        case .museum:
                .orange
        case .restaurant:
                .green
        case .other:
                .indigo
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .hotel:
            1
        case .museum:
            2
        case .restaurant:
            3
        case .other:
            4
        }
    }
}

