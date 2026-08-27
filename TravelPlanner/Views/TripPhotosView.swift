//
//  TripPhotosView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 04.08.2026.
//

import PhotosUI
import SwiftData
import SwiftUI

struct TripPhotosView: View {

    let trip: Trip
    let viewModel: TripViewModel

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isSelecting = false
    @State private var selectedPhotoIDs: Set<PersistentIdentifier> = []
    @State private var draggedPhoto: TripPhoto?
    @State private var previewPhoto: TripPhoto?

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 2),
        count: 3
    )
    private var sortedPhotos: [TripPhoto] {
        trip.photos.sorted(by: { $0.order < $1.order })
    }

    var body: some View {
        Group {
            if sortedPhotos.isEmpty {
                ContentUnavailableView(
                    "No Photos Yet",
                    systemImage: "photo.on.rectangle",
                    description: Text("Add photos from your library.")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(sortedPhotos) { photo in
                            photoCell(for: photo)
                        }
                    }
                }
            }
        }
        .navigationTitle("Photos")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(
            item: $previewPhoto,
            content: { photo in
                PhotoDetailPreviewView(
                    photo: photo,
                    photos: sortedPhotos,
                    previewPhoto: $previewPhoto
                )
            }
        )
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if isSelecting {
                    Button(role: .destructive) {
                        deleteSelected()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(selectedPhotoIDs.isEmpty)
                } else {
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        matching: .images
                    ) {
                        Image(systemName: "plus")
                    }
                    .onChange(of: selectedPhotoItems) { _, newItems in
                        loadPhotos(from: newItems)
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if !sortedPhotos.isEmpty {
                    Button(isSelecting ? "Cancel" : "Select") {
                        isSelecting.toggle()
                        selectedPhotoIDs.removeAll()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func photoCell(for photo: TripPhoto) -> some View {
        if let uiImage = UIImage(data: photo.photoData) {
            GeometryReader { geometry in
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
            }
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .topTrailing) {
                if isSelecting {
                    Image(
                        systemName: selectedPhotoIDs.contains(
                            photo.persistentModelID
                        ) ? "checkmark.circle.fill" : "circle"
                    )
                    .foregroundStyle(.white, .blue)
                    .font(.title3)
                    .padding(6)
                    .shadow(radius: 2)
                }
            }
            .overlay {
                if isSelecting
                    && selectedPhotoIDs.contains(photo.persistentModelID)
                {
                    Color.blue.opacity(0.25)
                }
            }
            .onTapGesture {
                if isSelecting {
                    toggleSelection(photo)
                } else {
                    previewPhoto = photo
                }
            }
            .onDrag {
                draggedPhoto = photo
                return NSItemProvider(
                    object: "\(photo.persistentModelID.hashValue)"
                        as NSString
                )
            }
            .onDrop(
                of: [.text],
                delegate: PhotoDropDelegate(
                    photo: photo,
                    photos: sortedPhotos,
                    draggedPhoto: $draggedPhoto,
                    onReorder: { newOrder in
                        viewModel.updatePhotoOrder(newOrder)
                    }
                )
            )
        }
    }
    private func toggleSelection(_ photo: TripPhoto) {
        if selectedPhotoIDs.contains(photo.persistentModelID) {
            selectedPhotoIDs.remove(photo.persistentModelID)
        } else {
            selectedPhotoIDs.insert(photo.persistentModelID)
        }
    }

    private func deleteSelected() {
        let toDelete = trip.photos.filter {
            selectedPhotoIDs.contains($0.persistentModelID)
        }
        viewModel.deletePhotos(toDelete, from: trip)
        selectedPhotoIDs.removeAll()
        isSelecting = false
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            var newData: [Data] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self)
                {
                    newData.append(data)
                }
            }
            viewModel.addPhotos(newData, to: trip)
            selectedPhotoItems = []
        }
    }
}

// MARK: - Photo Preview View
struct PhotoDetailPreviewView: View {
    let photo: TripPhoto
    let photos: [TripPhoto]
    @Binding var previewPhoto: TripPhoto?

    @State private var currentIndex: Int = 0

    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset: CGSize = .zero
    @State private var isVerticalDrag: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()

                TabView(selection: $currentIndex) {
                    ForEach(Array(photos.enumerated()), id: \.element.id) {
                        index,
                        item in
                        if let uiImage = UIImage(data: item.photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .tag(index)
                                .offset(
                                    y: isVerticalDrag ? dragOffset.height : 0
                                )
                                .scaleEffect(imageScale)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            let verticalDistance = value.translation.height
                            let horizontalDistance = abs(
                                value.translation.width
                            )
                            if verticalDistance > 10
                                && verticalDistance > horizontalDistance
                            {
                                isVerticalDrag = true
                                dragOffset = value.translation
                            } else if !isVerticalDrag {
                                dragOffset = .zero
                            }
                        }
                        .onEnded { value in
                            if isVerticalDrag {
                                if value.translation.height > 80
                                    || value.predictedEndTranslation.height
                                        > 200
                                {
                                    closePreview()
                                } else {
                                    withAnimation(
                                        .spring(
                                            response: 0.3,
                                            dampingFraction: 0.8
                                        )
                                    ) {
                                        dragOffset = .zero
                                        isVerticalDrag = false
                                    }
                                }
                            } else {
                                dragOffset = .zero
                                isVerticalDrag = false
                            }
                        }
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        previewPhoto = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .onAppear {
                if let initialIndex = photos.firstIndex(where: {
                    $0.persistentModelID == photo.persistentModelID
                }) {
                    currentIndex = initialIndex
                }
            }
        }
    }
    private func closePreview() {
        withAnimation(.easeOut(duration: 0.2)) {
            previewPhoto = nil
            dismiss()
        }
    }

    private var backgroundOpacity: Double {
        let maxDrag: CGFloat = 200
        let currentDrag = max(0, dragOffset.height)
        let progress = min(currentDrag / maxDrag, 1.0)
        return 1.0 - (progress * 0.8)
    }

    private var imageScale: CGFloat {
        let maxDrag: CGFloat = 200
        let currentDrag = max(0, dragOffset.height)
        let progress = min(currentDrag / maxDrag, 1.0)
        return 1.0 - (progress * 0.2)
    }
}
//MARK: - Photo Drop Delegate
struct PhotoDropDelegate: DropDelegate {
    let photo: TripPhoto
    let photos: [TripPhoto]
    @Binding var draggedPhoto: TripPhoto?
    let onReorder: ([TripPhoto]) -> Void

    func performDrop(info: DropInfo) -> Bool {
        draggedPhoto = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedPhoto,
            draggedPhoto.persistentModelID != photo.persistentModelID,
            let fromIndex = photos.firstIndex(where: {
                $0.persistentModelID == draggedPhoto.persistentModelID
            }),
            let toIndex = photos.firstIndex(where: {
                $0.persistentModelID == photo.persistentModelID
            })
        else { return }

        var newOrder = photos
        newOrder.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
        )
        onReorder(newOrder)
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

    return NavigationStack {
        TripPhotosView(
            trip: trip,
            viewModel: TripViewModel(context: container.mainContext)
        )
    }
    .modelContainer(container)
}
