//
//  RecentlyDeleted.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 21.07.2026.
//

import SwiftData
import SwiftUI

struct RecentlyDeleted: View {
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    let viewModel: TripViewModel
    private var deletedTrips: [Trip] {
        trips.filter({ $0.deletedAt != nil })
    }

    var body: some View {
        Group {
            if deletedTrips.isEmpty {
                ContentUnavailableView(
                    "No Deleted Trips",
                    systemImage: "trash",
                    description: Text(
                        "Recently Deleted Trips will appear here."
                    )
                )
            } else {
                List {
                    ForEach(deletedTrips) { trip in
                        NavigationLink {
                            TripDetailView(trip: trip)
                        } label: {
                            TripRowView(trip: trip)
                        }
                        .navigationLinkIndicatorVisibility(.hidden)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.permanentlyDeleteTrip(trip)
                            }
                            Button {
                                viewModel.restoreTrip(trip)
                            } label: {
                                Label(
                                    "Restore",
                                    systemImage: "arrow.uturn.backward"
                                )
                            }
                            .tint(.green)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Recently Deleted")
        .toolbar {
            if !deletedTrips.isEmpty {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Restore All") {
                        viewModel.restoreAllTrips(deletedTrips)
                    }
                    Spacer()
                    Button("Delete All") {
                        viewModel.permanentlyDeleteAllTrips(deletedTrips)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecentlyDeleted(
            viewModel: TripViewModel(
                context: ModelContext(try! ModelContainer(for: Trip.self))
            )
        )
    }
}
