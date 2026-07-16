//
//  StopRowView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftUI

struct StopRowView: View {
    
    let stop: Stop
    
    private var dateRangeText: String? {
        guard let arrivalDate = stop.arrivalDate else { return nil}
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        
        if let departure = stop.departureDate {
            return "\(formatter.string(from: arrivalDate)) - \(formatter.string(from: departure))"
        }
        return formatter.string(from: arrivalDate)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stop.name)
                    .font(.headline)
                Text(stop.country)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let dateRangeText = dateRangeText {
                    Text(dateRangeText)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            
            Text("\(stop.items.count)")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.blue.opacity(0.15))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    StopRowView(stop: Stop(name: "Rome", country: "Italy", latitude: 41.9, longitude: 12.5, arrivalDate: .now, departureDate: .now.addingTimeInterval(8640*3)))
}
