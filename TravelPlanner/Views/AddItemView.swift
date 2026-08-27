//
//  AddItemView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftData
import SwiftUI

struct AddItemView: View {

    let stop: Stop
    let viewModel: TripViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: ItemType = .other
    @State private var address = ""
    @State private var latitude: Double?
    @State private var longitude: Double?

    var body: some View {
        NavigationStack {
            Form {
                Section("Search Location") {
                    LocationSearchView {
                        resolvedName,
                        resolvedAddress,
                        resolvedCountry,
                        lat,
                        lon in
                        name = resolvedName
                        address = resolvedAddress
                        latitude = lat
                        longitude = lon
                    }
                }
                Section("Place Details") {
                    TextField("Name", text: $name)
                    TextField("Address", text: $address)
                    Picker("Type", selection: $type) {
                        ForEach(ItemType.allCases, id: \.self) { itemType in
                            HStack {
                                itemType.icon
                                    .foregroundStyle(itemType.color)
                                Text(itemType.label)
                            }
                            .tag(itemType)
                        }
                    }
                    if let latitude, let longitude {
                        Text(
                            "📍 \(latitude, specifier: "%.4f"), \(longitude, specifier: "%.4f")"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Place")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !address.trimmingCharacters(in: .whitespaces).isEmpty
            && latitude != nil && longitude != nil
    }

    private func saveItem() {
        guard let lat = latitude, let lon = longitude else { return }
        viewModel.addItem(
            to: stop,
            name: name,
            type: type,
            address: address,
            latitude: lat,
            longitude: lon
        )
        dismiss()
    }
}

#Preview {
    AddItemView(
        stop: Stop(
            name: "Rome",
            country: "Italy",
            latitude: 41.9,
            longitude: 12.5
        ),
        viewModel: TripViewModel(
            context: ModelContext(try! ModelContainer(for: Trip.self))
        )
    )
}
