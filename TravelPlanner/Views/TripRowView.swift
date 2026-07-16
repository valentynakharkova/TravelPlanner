//
//  TripRowView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftUI

struct TripRowView: View {
    
    let trip: Trip
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return "\(formatter.string(from: trip.startDate)) - \(formatter.string(from: trip.endDate))"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.name)
                    .font(.headline)
                
                Text("\(dateRangeText) • \(Text("^[\(trip.stops.count) stop](inflect: true)"))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if trip.isArchived {
                Text("Archived")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .opacity(trip.isArchived ? 0.6 : 1.0)
    }
}

#Preview {
    TripRowView(trip: Trip(name: "Italy 2026", startDate: .now, endDate: .now.addingTimeInterval(86400 * 7)))
}
