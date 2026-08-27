//
//  TripDetailView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import MapKit
import SwiftData
import SwiftUI

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
    @State private var notificationService = NotificationService()
    @State private var editingStop: Stop? = nil

    private var viewModel: TripViewModel {
        TripViewModel(context: modelContext)
    }
    //    private var sortedStops: [Stop] {
    //        trip.stops.sorted(by: { $0.order < $1.order })
    //    }
    private var sortedStops: [Stop] {
        trip.stops.sorted { stop1, stop2 in
            switch (stop1.arrivalDate, stop2.arrivalDate) {
            case (let date1?, let date2?):
                return date1 < date2  // both has dates
            case (nil, nil):
                return stop1.order < stop2.order  // both does not have stops
            case (nil, _):
                return false  //stop1 without date — comes after stop2
            case (_, nil):
                return true  //stop1 with date - comes before stop2
            }
        }
    }

    private var sortedPhotos: [TripPhoto] {
        trip.photos.sorted(by: { $0.order < $1.order })
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack(alignment: .top) {
            backgroundImage

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dateLabel)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)

                        Text(trip.name)
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        NavigationLink {
                            TripMapView(trip: trip)
                        } label: {
                            mapTile
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            TripPhotosView(trip: trip, viewModel: viewModel)
                        } label: {
                            photoTile
                        }
                        .buttonStyle(.plain)

                        ForEach(sortedStops) { stop in
                            Button {
                                selectedStop = stop
                            } label: {
                                stopTile(for: stop)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    editingStop = stop
                                } label: {
                                    Label("Edit Stop", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    notificationService.cancelReminder(
                                        for: stop
                                    )
                                    viewModel.deleteStop(stop, from: trip)
                                } label: {
                                    Label("Delete Stop", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding()
                .padding(.top, 20)
            }
        }
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
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        addToCalendar()
                    } label: {
                        Label(
                            "Add to Calendar",
                            systemImage: "calendar.badge.plus"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddStop) {
            AddStopView(trip: trip, stop: nil, viewModel: viewModel)
        }
        .sheet(item: $editingStop) { stop in
            AddStopView(trip: trip, stop: stop, viewModel: viewModel)
        }
        .alert("Calendar", isPresented: $showingCalendarAlerts) {
            Button("OK") {}
        } message: {
            Text(calendarAlertsMessage)
        }
    }
    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return
            "\(formatter.string(from: trip.startDate)) → \(formatter.string(from: trip.endDate)) "
    }
    private var backgroundImage: some View {
        GeometryReader { geometry in
            if let coverPhoto = trip.coverPhoto,
                let uiImage = UIImage(data: coverPhoto)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
            } else {
                LinearGradient(
                    colors: [.purple, .indigo.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
    private var mapTile: some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(.green.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "map.fill")
                        .foregroundStyle(.green)
                }
            Text("Map View")
                .font(.subheadline.bold())
            Text("\(Text("^[\(sortedStops.count) stop](inflect: true)"))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    private var photoTile: some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(.indigo.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "photo.on.rectangle.fill")
                        .foregroundStyle(.indigo)
                }
            Text("Trip Photos")
                .font(.subheadline.bold())
            Text("\(Text("^[\(sortedPhotos.count) photo](inflect: true)"))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    private var stopsCountText: String {
        sortedStops.count == 1 ? "1 stop" : "\(sortedStops.count) stops"
    }
    private func stopTile(for stop: Stop) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                Circle()
                    .fill(.blue.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(.blue)
                    }
                Spacer()
                
                dateBadge(for: stop)
                
             }
            HStack {
                Text(stop.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Spacer()
                Text("\(stop.items.count)")
                    .font(.title3.bold())
            }
            Text(stop.country)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    private func dateBadge(for stop: Stop) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.caption2)
                .foregroundStyle(.secondary)
            if let arrivalDate = stop.arrivalDate {
                Text(arrivalDate, format: .dateTime.month(.abbreviated).day())
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            } else {
                Text("No Date")
                    .font(.caption2)
            }
        }
        .foregroundStyle(stop.arrivalDate != nil ? .primary : .secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            (stop.arrivalDate != nil ? Color.blue : Color.gray)
                .opacity(0.2)
        )
        .clipShape(Capsule())
    }

    private var addStopTile: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.title)
            Text("Add Stop")

        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(minHeight: 115)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    private func addToCalendar() {
        Task {
            do {
                try await eventKitService.addTripToCalendar(
                    name: trip.name,
                    startDate: trip.startDate,
                    endDate: trip.endDate
                )
                calendarAlertsMessage = "Trip added to your calendar!"
            } catch {
                calendarAlertsMessage = error.localizedDescription
            }
            showingCalendarAlerts = true
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Trip.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let trip = Trip(
        name: "Italy",
        startDate: .now,
        endDate: .now.addingTimeInterval(86400 * 7)
    )
    container.mainContext.insert(trip)

    let stop1 = Stop(
        name: "Rome",
        country: "Italy",
        latitude: 41.9,
        longitude: 12.5,
        order: 0
    )
    stop1.trip = trip
    trip.stops.append(stop1)

    let stop2 = Stop(
        name: "Florence",
        country: "Italy",
        latitude: 43.7,
        longitude: 11.2,
        order: 1
    )
    stop2.trip = trip
    trip.stops.append(stop2)

    return NavigationStack {
        TripDetailView(trip: trip)
    }
    .modelContainer(container)
}
