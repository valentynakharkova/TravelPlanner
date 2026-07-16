//
//  ItemRowView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftUI

struct ItemRowView: View {
    
    let item: TripItem
    
    var body: some View {
        HStack(spacing: 12) {
            item.type.icon
                .foregroundStyle(item.type.color)
                .frame(width: 30, height: 30)
                .background(item.type.color.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                Text(item.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            
            if item.photo != nil {
                Image(systemName: "photo.fill")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    ItemRowView(item: TripItem(name: "Colosseum", type: .attraction, address: "Piazza del Colosseo, Rome", latitude: 41.89, longitude: 12.49))
}
