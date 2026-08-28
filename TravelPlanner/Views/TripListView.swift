//
//  TripListView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftData
import SwiftUI

struct TripListView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    @State private var showingAddTrip = false
    @State private var editingTrip: Trip? = nil
    @State private var showArchived = false
    @State private var showDeleted = false

    private var viewModel: TripViewModel {
        TripViewModel(context: modelContext)
    }
    private var activeTrips: [Trip] {
        trips.filter({ !$0.isArchived && $0.deletedAt == nil })
    }

    var body: some View {
        NavigationStack {
            Group {
                
            if activeTrips.isEmpty {
                ContentUnavailableView("No Trips", systemImage: "airplane", description: Text("Add trip to get started."))
            } else {
                List {
                    ForEach(activeTrips) { trip in
                        tripRow(for: trip)
                    }
                }
                .listRowSeparator(.hidden)
                .listStyle(.plain)
            }
        }
                .navigationTitle("My Trips")
                .navigationDestination(for: Trip.self) { trip in
                    TripDetailView(trip: trip)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddTrip = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                showArchived = true
                            } label: {
                                Label("Archived Trips", systemImage: "archivebox")
                            }
                            
                            Button {
                                showDeleted = true
                            } label: {
                                Label("Recently Deleted", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .sheet(isPresented: $showingAddTrip) {
                    AddTripView(trip: nil, viewModel: viewModel)
                }
                .sheet(item: $editingTrip) { trip in
                    AddTripView(trip: trip, viewModel: viewModel)
                }
                .navigationDestination(isPresented: $showArchived) {
                    ArchivedTrips(viewModel: viewModel)
                }
                .navigationDestination(isPresented: $showDeleted) {
                    RecentlyDeleted(viewModel: viewModel)
                }
        }
    }

    @ViewBuilder
    private func tripRow(for trip: Trip) -> some View {
        NavigationLink(value: trip) {
            TripRowView(trip: trip)
        }
        .listRowSeparator(.hidden)
        .navigationLinkIndicatorVisibility(.hidden)
        .swipeActions(edge: .trailing) {
            Button {
                viewModel.archiveTrip(trip)
            } label: {
                Label(
                    trip.isArchived ? "Unarchive" : "Archive",
                    systemImage: "archivebox"
                )
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

#Preview {
    TripListView()
}
