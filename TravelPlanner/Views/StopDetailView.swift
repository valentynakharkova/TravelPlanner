//
//  StopDetailView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 07.07.2026.
//

import SwiftUI
import SwiftData
import MapKit

struct StopDetailView: View {
    
    let stop: Stop
    
    @Environment(\.modelContext) var modelContext
    @State private var showingAddItem = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var notificationService = NotificationService()
    @State private var showingNotificationAlert = false
    @State private var notificationAlertMessage = ""
    
    private var viewModel: TripViewModel {
        TripViewModel(context: modelContext)
    }
    private var items: [TripItem] {
        stop.items
    }
    
    private var groupedItems: [ItemType: [TripItem]] {
        Dictionary(grouping: items, by: {$0.type})
    }
    
    private var sortedTypes: [ItemType] {
        groupedItems.keys.sorted { $0.sortOrder < $1.sortOrder }
    }
        
    var body: some View {
        VStack(spacing: 0) {
            Map(position: $cameraPosition) {
                ForEach(stop.items) { item in
                    Annotation(item.name, coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(item.type.color, lineWidth: 2))
                            
                            item.type.icon
                                .font(.title2)
                                .foregroundStyle(item.type.color)
                        }
                    }
                }
            }
        
        .containerRelativeFrame(.vertical) { length, _ in
            length * 0.70
        }
        
        VStack(spacing: 8) {
            List {
                ForEach(sortedTypes, id: \.self) { type in
                    if let itemsInGroup = groupedItems[type], !itemsInGroup.isEmpty {
                        Section {
                            ForEach(itemsInGroup) { item in
                                ItemRowView(item: item)
                            }
                            .onDelete { offsets in
                                deleteItems(at: offsets, in: itemsInGroup)
                            }
                        } header: {
                            Text(type.label)
                        }

                    }
                }
            }
            .listStyle(.plain)
        }
    }
        .ignoresSafeArea()
        .navigationTitle(stop.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddItem = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        scheduleAlert()
                    } label: {
                        Label("Remind Me", systemImage: "bell.badge")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(stop: stop, viewModel: viewModel)
        }
        .alert("Reminder", isPresented: $showingNotificationAlert) {
            Button("OK") {}
        } message: {
            Text(notificationAlertMessage)
        }
    }
    private func typeTile(for type: ItemType, count: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(type.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay {
                        type.icon
                            .foregroundStyle(type.color)
                    }
                Spacer()
                Text("\(count)")
                    .font(.title3.bold())
            }
            Text(type.label)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
                
            }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
            
    }
    
    private func scheduleAlert() {
        Task {
            do {
                try await notificationService.scheduleArrivalReminder(for: stop)
                notificationAlertMessage = "Reminder set for the day before arrival!"
            } catch {
                notificationAlertMessage = error.localizedDescription
            }
            showingNotificationAlert = true
        }
    }
    
    private func deleteItems(at offsets: IndexSet, in sectionItem: [TripItem]) {
        for index in offsets {
            viewModel.deleteItem(sectionItem[index], from: stop)
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Stop.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let stop = Stop(name: "Rome", country: "Italy", latitude: 41.9, longitude: 12.5)
    container.mainContext.insert(stop)
    
    let hotel = TripItem(name: "Hotel Artemide", type: .hotel, address: "Via Nazionale", latitude: 41.90, longitude: 12.49)
    hotel.stop = stop
    stop.items.append(hotel)
    let attraction = TripItem(name: "Colosseum", type: .museum, address: "Piazza del Colosseo", latitude: 41.89, longitude: 12.49)
    attraction.stop = stop
    stop.items.append(attraction)
    
    return NavigationStack {
        StopDetailView(stop: stop)
    }
    .modelContainer(container)
    
}

