//
//  AddItemView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftData
import SwiftUI
import PhotosUI

struct AddItemView: View {

    let stop: Stop
    let viewModel: TripViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: ItemType = .other
    @State private var address = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingCamera = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Search Location") {
                    LocationSearchView {
                        resolvedName,
                        resolvedAddress,
                        lat,
                        lon in
                        name = resolvedName
                        address = resolvedAddress
                        latitude = lat
                        longitude = lon
                    }
                }
                Section("Item Details") {
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
                    Section("Photos") {
                            if let photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            HStack {
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                                }
                                .onChange(of: selectedPhotoItem) { _, newValue in
                                    loadPhoto(from: newValue)
                                }
                                Spacer()
                                
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    Button {
                                        showingCamera = true
                                    } label: {
                                        Label("Take Photo", systemImage: "camera")
                                    }
                                }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("New Item")
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
                .fullScreenCover(isPresented: $showingCamera) {
                    CameraPicker(imageData: $photoData)
                        .ignoresSafeArea()
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
            longitude: lon,
            photo: photoData
        )
        dismiss()
    }
    
    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                photoData = data
            }
        }
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
