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

    
    private var viewModel: TripViewModel {
        TripViewModel(context: modelContext)
    }
    
    var body: some View {
        VStack {
            Map(position: $cameraPosition) {
                ForEach(stop.items) { item in
                    Annotation(item.name, coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                        Circle()
                            .fill(item.type.color)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
            }
            .frame(height: 300)
            
            List {
                ForEach(ItemType.allCases, id: \.self) { type in
                    let items = stop.items.filter {$0.type == type}
                    if !items.isEmpty {
                        Section(type.label) {
                            ForEach(items) { item in
                                ItemRowView(item: item)
                            }
                            .onDelete { offsets in
                                deleteItems(items, at: offsets)
                            }
                        }
                    }
                }
            }
            .navigationTitle(stop.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(stop: stop, viewModel: viewModel)
            }
        }
    }
    
    private func deleteItems(_ items: [TripItem],at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteItem(items[index], to: stop)
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
    let attraction = TripItem(name: "Colosseum", type: .attraction, address: "Piazza del Colosseo", latitude: 41.89, longitude: 12.49)
    attraction.stop = stop
    stop.items.append(attraction)
    
    return NavigationStack {
        StopDetailView(stop: stop)
    }
    .modelContainer(container)
    
}
