//
//  AddStopView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddStopView: View {

    let trip: Trip
    let stop: Stop?
    let viewModel: TripViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var country = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var arrivalDate = Date.now
    @State private var departureDate = Date.now.addingTimeInterval(86400)
    @State private var hasDates = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var coverPhotoData: Data?
    @State private var showingCamera = false


    var body: some View {
        NavigationStack {
            Form {
                Section("Search Location") {
                    LocationSearchView { resolvedName, address, resolvedCountry, lat, lon in
                        name = resolvedName
                        country = resolvedCountry
                        latitude = lat
                        longitude = lon
                    }
                }
                Section("Stop Details") {
                    TextField("City name", text: $name)
                    TextField("Country", text: $country)
                    
                    if let latitude, let longitude {
                        Text("📍 \(latitude, specifier: "%.4f") / \(longitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Section {
                    Toggle("Set dates", isOn: $hasDates)
                    
                    if hasDates {
                        DatePicker("Arrival", selection: $arrivalDate, displayedComponents: .date)
                        DatePicker("Departure", selection: $departureDate, in: arrivalDate..., displayedComponents: .date)
                    }
                }
                Section("Add Photo") {
                    if let coverPhotoData, let uiImage = UIImage(data: coverPhotoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                    }
                    .onChange(of: selectedPhotoItem) { _, newValue in
                        loadPhoto(from: newValue)
                    }
                    
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            showingCamera = true
                        } label: {
                            Label("Take Photo", systemImage: "photo")
                        }
                    }
                }
            }
            .environment(\.locale, Locale(identifier: "en_UK"))
            .navigationTitle(stop == nil ? "New Stop" : "Edit Stop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStop()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let stop = stop {
                    name = stop.name
                    country = stop.country
                    latitude = stop.latitude
                    longitude = stop.longitude
                    
                    if let arrival = stop.arrivalDate, let departure = stop.departureDate {
                        hasDates = true
                        arrivalDate = arrival
                        departureDate = departure
                    } else {
                        hasDates = false
                    }
                    
                    if let firstPhoto = stop.stopPhoto.sorted(by: {$0.order < $1.order}).first {
                        coverPhotoData = firstPhoto.photoData
                    }
                }
            }
        }
    }
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !country.trimmingCharacters(in: .whitespaces).isEmpty &&
        latitude != nil &&
        longitude != nil
    }
    private func saveStop() {
        guard let lat = latitude, let lon = longitude else { return }
        if let stop {
            stop.name = name
            stop.country = country
            stop.latitude = lat
            stop.longitude = lon
            stop.arrivalDate = hasDates ? arrivalDate : nil
            stop.departureDate = hasDates ? departureDate : nil
            if let coverPhotoData {
                viewModel.addStopPhotos(coverPhotoData, to: stop)
            }
            viewModel.saveContext()
        } else {
            viewModel.addStop(
                to: trip,
                name: name,
                country: country,
                latitude: lat,
                longitude: lon,
                arrivalDate: hasDates ? arrivalDate : nil,
                departureDate: hasDates ? departureDate : nil
            )
        }
        
        dismiss()
    }
    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                coverPhotoData = data
            }
        }
    }
}

#Preview {
    AddStopView(
        trip: Trip(
            name: "Italy 2026",
            startDate: .now,
            endDate: .now.addingTimeInterval(86400 * 7)
        ),
        stop: nil,
        viewModel: TripViewModel(context: ModelContext(try! ModelContainer(for: Trip.self)))
    )
}
