//
//  ArchivedTrips.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.08.2026.
//

import SwiftData
import SwiftUI

struct ArchivedTrips: View {
    @Query(sort: \Trip.startDate) private var trips: [Trip]
    let viewModel: TripViewModel

    @State private var editingTrip: Trip? = nil

    private var archivedTrips: [Trip] {
        trips.filter({ $0.isArchived && $0.deletedAt == nil })
    }

    var body: some View {
        Group {
            if archivedTrips.isEmpty {
                ContentUnavailableView(
                    "No Archived Trips",
                    systemImage: "archivebox",
                    description: Text("Trips you archive will appear here.")
                )

            } else {
                List {
                    ForEach(archivedTrips) { trip in
                        NavigationLink {
                            TripDetailView(trip: trip)
                        } label: {
                            TripRowView(trip: trip)
                        }
                        .navigationLinkIndicatorVisibility(.hidden)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button {
                                viewModel.archiveTrip(trip)
                            } label: {
                                Label("Unarchive", systemImage: "archivebox")
                            }
                            .tint(.orange)
                            Button(role: .destructive) {
                                viewModel.deleteTrip(trip)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                editingTrip = trip
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Archived Trips")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                if !archivedTrips.isEmpty {
                    Button("Unarchive All") {
                        for trip in archivedTrips {
                            viewModel.archiveTrip(trip)
                        }
                    }
                    Spacer()
                    Button("Delete All") {
                        for trip in archivedTrips {
                            viewModel.deleteTrip(trip)
                        }
                    }
                }
            }
        }
        .sheet(item: $editingTrip) { trip in
            AddTripView(trip: trip, viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationStack {
        ArchivedTrips(
            viewModel: TripViewModel(
                context: ModelContext(try! ModelContainer(for: Trip.self))
            )
        )
    }
}
