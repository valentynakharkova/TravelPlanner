//
//  AddTripView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddTripView: View {
    
    let trip: Trip?
    let viewModel: TripViewModel
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var startDate: Date = Date.now
    @State private var endDate: Date = Date.now.addingTimeInterval(86400)
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var coverPhotoData: Data?
    @State private var showingCamera = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Trip name", text: $name)
                    DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End date", selection: $endDate, in: startDate..., displayedComponents: .date)
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
            .navigationTitle(trip == nil ? "New Trip" : "Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let trip = trip {
                            trip.name = name
                            trip.startDate = startDate
                            trip.endDate = endDate
                            trip.coverPhoto = coverPhotoData
                            try? modelContext.save()
                        } else {
                            viewModel.addTrip(name: name, startDate: startDate, endDate: endDate, coverPhoto: coverPhotoData)
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraPicker(imageData: $coverPhotoData)
                    .ignoresSafeArea()
            }
            .onAppear {
                if let trip = trip {
                    name = trip.name
                    startDate = trip.startDate
                    endDate = trip.endDate
                    coverPhotoData = trip.coverPhoto
                }
            }
        }
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
    AddTripView(trip: nil, viewModel: TripViewModel(context: ModelContext(try! ModelContainer(for: Trip.self))))
}
