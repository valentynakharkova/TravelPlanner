//
//  AddStopView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftUI
import SwiftData

struct AddStopView: View {

    let trip: Trip
    let viewModel: TripViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var country = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var arrivalDate = Date.now
    @State private var departureDate = Date.now.addingTimeInterval(86400)
    @State private var hasDates = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Search Location") {
                    LocationSearchView { resolvedName, address, lat, lon in
                        name = resolvedName
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
            }
            .environment(\.locale, Locale(identifier: "en_UK"))
            .navigationTitle("New Stop")
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
        viewModel.addStop(
            to: trip,
            name: name,
            country: country,
            latitude: lat,
            longitude: lon,
            arrivalDate: hasDates ? arrivalDate : nil,
            departureDate: hasDates ? departureDate : nil
        )
        dismiss()
    }
}

#Preview {
    AddStopView(
        trip: Trip(
            name: "Italy 2026",
            startDate: .now,
            endDate: .now.addingTimeInterval(86400 * 7)
        ),
        viewModel: TripViewModel(context: ModelContext(try! ModelContainer(for: Trip.self)))
    )
}
