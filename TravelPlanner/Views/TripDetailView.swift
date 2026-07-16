//
//  TripDetailView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftData
import SwiftUI
import MapKit

struct TripDetailView: View {

    let trip: Trip

    @Environment(\.modelContext) private var modelContext
    @State private var showingAddStop = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedStopID: PersistentIdentifier?
    @State private var selectedStop: Stop?
    @State private var eventKitService = EventKitService()
    @State private var showingCalendarAlerts = false
    @State private var calendarAlertsMessage = ""
    
    private var viewModel: TripViewModel {
        TripViewModel(context: modelContext)
    }
    private var sortedStops: [Stop] {
        trip.stops.sorted(by: { $0.order < $1.order })
    }

    var body: some View {
        VStack(spacing: 0) {
            Map(position: $cameraPosition, selection: $selectedStopID) {
                ForEach(sortedStops) { stop in
                    Marker(stop.name, coordinate: CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop
                        .longitude))
                    .tag(stop.persistentModelID)
                }
            }
            .frame(height: 300)
            .onChange(of: selectedStopID) { _, newValue in
                guard let newValue else { return }
                selectedStop = sortedStops.first(where: { $0.persistentModelID == newValue })
                selectedStopID = nil
            }
            List {
                ForEach(sortedStops) { stop in
                    Button {
                        selectedStop = stop
                    } label: {
                        StopRowView(stop: stop)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                }
                .onDelete(perform: deleteStops)
                .onMove(perform: moveStops)
            }
        }
        .navigationTitle(trip.name)
        .navigationDestination(item: $selectedStop) { stop in
            StopDetailView(stop: stop)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddStop = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        addToCalendar()
                    } label: {
                        Label("Add to Calendar", systemImage: "calendar.badge.plus")
                    }
                } label: {
                    Image(systemName: "ellispis.circle")
                } 
            }
            
        }
        .sheet(isPresented: $showingAddStop) {
            AddStopView(trip: trip, viewModel: viewModel)
        }
        .alert("Calendar", isPresented: $showingCalendarAlerts) {
            Button("OK") {}
        } message: {
            Text("Calendat Alert Message")
        }
    }
    
    private func addToCalendar() {
        Task {
            do {
                try await eventKitService.addTripToCalendar(name: trip.name, startDate: trip.startDate, endDate: trip.endDate)
            } catch {
                calendarAlertsMessage = error.localizedDescription
            }
            showingCalendarAlerts = true
        }
    }

    private func deleteStops(at offsets: IndexSet) {
        let sortedStops = trip.stops.sorted(by: { $0.order < $1.order })
        for index in offsets {
            viewModel.deleteStop(sortedStops[index], from: trip)
        }
    }
    private func moveStops(from sourse: IndexSet, to destination: Int) {
        viewModel.reorderStops(in: trip, from: sourse, to: destination)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Trip.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let trip = Trip(name: "Italy", startDate: .now, endDate: .now.addingTimeInterval(86400*7))
    container.mainContext.insert(trip)
    
    let stop1 = Stop(name: "Rome", country: "Italy", latitude: 41.9, longitude: 12.5, order: 0)
    stop1.trip = trip
    trip.stops.append(stop1)
    
    let stop2 = Stop(name: "Florence", country: "Italy", latitude: 43.7, longitude: 11.2, order: 1)
    stop2.trip = trip
    trip.stops.append(stop2)
    
    return NavigationStack {
        TripDetailView(trip: trip)
    }
    .modelContainer(container)
}
