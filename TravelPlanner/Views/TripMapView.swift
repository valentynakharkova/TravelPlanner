//
//  TripMapView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 24.07.2026.
//

import SwiftUI
import SwiftData
import MapKit

struct TripMapView: View {
    
    let trip: Trip
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedStopID: PersistentIdentifier?
    @State private var selectedStop: Stop?
    
    private var sortedStops: [Stop] {
        trip.stops.sorted(by: { $0.order < $1.order })
    }
    
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedStopID) {
            ForEach(sortedStops) { stop in
                Annotation(stop.name, coordinate: CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)) {
                    stopPin(for: stop)
                }
                .tag(stop.persistentModelID)
            }
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedStop) { stop in
            StopDetailView(stop: stop)
        }
        .onChange(of: selectedStopID) { _, newValue in
            guard let newValue else { return }
            selectedStop = sortedStops.first(where: {$0.persistentModelID == newValue})
            selectedStopID = nil
        }
    }
    @ViewBuilder
    private func stopPin(for stop: Stop) -> some View {
        if let firstPhoto = stop.stopPhoto.sorted(by: { $0.order < $1.order }).first,
                   let uiImage = UIImage(data: firstPhoto.photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                        .shadow(radius: 3)
                } else {
                    Circle()
                        .fill(.blue)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                        .shadow(radius: 3)
                }
    }
}

#Preview {
    let container = try! ModelContainer(for: Trip.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let trip = Trip(name: "Italy", startDate: .now, endDate: .now.addingTimeInterval(86400*7))
    container.mainContext.insert(trip)
    let stop1 = Stop(name: "Rome", country: "Italy", latitude: 42.9, longitude: 12.3, order: 1)
    stop1.trip = trip
    trip.stops.append(stop1)
    return NavigationStack {
        TripMapView(trip: trip)
    }
    .modelContainer(container)
}
