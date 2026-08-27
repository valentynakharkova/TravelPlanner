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
            if let photoData = item.photo, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                item.type.icon
                    .foregroundStyle(item.type.color)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                Text(item.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    ItemRowView(item: TripItem(name: "Colosseum", type: .museum, address: "Piazza del Colosseo, Rome", latitude: 41.89, longitude: 12.49))
}
