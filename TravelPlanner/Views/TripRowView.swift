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
        return
            "\(formatter.string(from: trip.startDate)) - \(formatter.string(from: trip.endDate))"
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let coverPhoto = trip.coverPhoto,
                let uiImage = UIImage(data: coverPhoto)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                LinearGradient(
                    colors: [.indigo.opacity(0.6), .purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(dateRangeText)
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.85))

                HStack {
                    Text(trip.name)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    TripRowView(
        trip: Trip(
            name: "Italy 2026",
            startDate: .now,
            endDate: .now.addingTimeInterval(86400 * 7)
        )
    )
}
