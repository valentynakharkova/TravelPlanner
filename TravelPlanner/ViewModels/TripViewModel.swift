//  TripItem.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 15.06.2026.
//

import SwiftUI
import SwiftData

@Observable
class TripViewModel {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    //MARK: - Add Trp
    func addTrip(name: String, startDate: Date, endDate: Date) {
        let trip = Trip(name: name, startDate: startDate, endDate: endDate)
        context.insert(trip)
        saveContext()
    }
    
    //MARK: - Delete Trip
    func deleteTrip(_ trip: Trip) {
        context.delete(trip)
        saveContext()
    }
    
    //MARK: - Archive Trip
    func archiveTrip(_ trip: Trip) {
        trip.isArchived.toggle()
        saveContext()
    }
    
    //MARK: - Add Stop
    func addStop(to trip: Trip, name: String, country: String, latitude: Double, longitude: Double, arrivalDate: Date? = nil, departureDate: Date? = nil) {
        let order = trip.stops.count
        let stop = Stop(name: name, country: country, latitude: latitude, longitude: longitude, arrivalDate: arrivalDate, departureDate: departureDate, order: order)
        stop.trip = trip
        trip.stops.append(stop)
        saveContext()
    }
    
    //MARK: - Dele Stop
    func deleteStop(_ stop: Stop, from trip: Trip) {
        trip.stops.removeAll(where: { $0.id == stop.id })
        context.delete(stop)
        saveContext()
    }
    
    //MARK: Reorder Stops
    func reorderStops(in trip: Trip, from sourse: IndexSet, to destination: Int) {
        trip.stops.move(fromOffsets: sourse, toOffset: destination)
        for (index, stop) in trip.stops.enumerated() {
            stop.order = index
        }
        saveContext()
    }
    
    //MARK: - Add Item
    func addItem(to stop: Stop, name: String, type: ItemType, address: String, latitude: Double, longitude: Double, photo: Data? = nil) {
        let item = TripItem(name: name, type: type, address: address, latitude: latitude, longitude: longitude)
        item.photo = photo
        item.stop = stop
        stop.items.append(item)
        saveContext()
    }
    
    //MARK: - Delete Item
    func deleteItem(_ item: TripItem, to stop: Stop) {
        stop.items.removeAll(where: { $0.id == item.id })
        context.delete(item)
        saveContext()
    }
    
    //MARK: - Save Context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("\(error.localizedDescription) - Failed to save context")
        }
    }
}
