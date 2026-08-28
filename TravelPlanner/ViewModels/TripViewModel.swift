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
    
    //MARK: - Add Trip
    /// Creates a new trip and saves it to the model context
    /// - Parameters:
    /// - name: Display name of the trip;
    /// - startDate: Trip start date.;
    /// - endDate: Trip end date;
    /// - coverPhoto: Optional cover image data shown as the trip's background.
    func addTrip(name: String, startDate: Date, endDate: Date, coverPhoto: Data? = nil) {
        let trip = Trip(name: name, startDate: startDate, endDate: endDate)
        trip.coverPhoto = coverPhoto
        context.insert(trip)
        saveContext()
    }
    
    //MARK: - Soft Delete Trip
    /// Marks trip as deleted without removing it from from the database.
    /// The trip can be restored in via `restoreTrip`, and it's exspected
    /// to be permanently deleted after 30 days period.
    func deleteTrip(_ trip: Trip) {
        trip.deletedAt = .now
        saveContext()
    }
    
    //MARK: - Restore Trip
    /// Restores single trip from the soft deleted by clearing it's `deletedAt' date
    func restoreTrip(_ trip: Trip) {
        trip.deletedAt = nil
        saveContext()
    }
    
    //MARK: - Restore All Trips
    /// Restores all trips at once
    /// - Parameter trips: The trips to restore.
    func restoreAllTrips(_ trips: [Trip]) {
        for trip in trips {
            trip.deletedAt = nil
        }
        saveContext()
    }
    
    //MARK: - Permanently Delete Trip
    /// Permanently deletes single trip from the database.
    func permanentlyDeleteTrip(_ trip: Trip) {
        context.delete(trip)
        saveContext()
    }
    
    //MARK: - Permanently Delete All Trips
    /// Permanently deletes all trips from the database.
    /// - Parameter trips: The trips to permanently delete.
    func permanentlyDeleteAllTrips(_ trips: [Trip]) {
        for trip in trips {
            context.delete(trip)
        }
        saveContext()
    }
    
    //MARK: - Archive Trip
    /// Toggles a trip's archived state (archived <-> unarchived)
    func archiveTrip(_ trip: Trip) {
        trip.isArchived.toggle()
        saveContext()
    }
    
    //MARK: - Add Stop
    /// Creates a new stop and append it to trip's stop list.
    /// The stops `order` is set to place current stop count and place new stop at the end.
    /// - Parameters:
    /// - trip: the trip this stop belongs to;
    /// - name: Displays name of the stop;
    /// - country: Displays country of the stop;
    /// - latitude: Displays latitude coordinate of the stop;
    /// - longitude: Displays longitude coordinate of the stop;
    /// - arrivalDate: Optional that displays arrival date of the stop;
    /// - departureDate: Optional that displays departure date of the stop.
    @discardableResult
    func addStop(to trip: Trip, name: String, country: String, latitude: Double, longitude: Double, arrivalDate: Date? = nil, departureDate: Date? = nil) -> Stop {
        let order = trip.stops.count
        let stop = Stop(name: name, country: country, latitude: latitude, longitude: longitude, arrivalDate: arrivalDate, departureDate: departureDate, order: order)
        stop.trip = trip
        trip.stops.append(stop)
        saveContext()
        return stop
    }
    
    //MARK: - Delete Stop
    /// Removes the stop from the trip and deletes stop from the database.
    func deleteStop(_ stop: Stop, from trip: Trip) {
        trip.stops.removeAll(where: { $0.id == stop.id })
        context.delete(stop)
        saveContext()
    }
    
    //MARK: Reorder Stops
    /// Reorder trip stops and updates it's `order` to match it's new position.
    /// - Parameters:
    /// - trip: The trip those stops are being reordered;
    /// - source: Index Set of the stops being moved (form the sorted list);
    /// - destionation: The index to move the stops to.
    func reorderStops(in trip: Trip, from source: IndexSet, to destination: Int) {
        var sortedStops = trip.stops.sorted(by: {$0.order < $1.order})
        sortedStops.move(fromOffsets: source, toOffset: destination)
        for (index, stop) in sortedStops.enumerated() {
            stop.order = index
        }
        saveContext()
    }
    
    //MARK: - Add Item
    /// Creates a new item place (hotel, restaurant, museum, other) and adds it to the stop.
    /// - Parameters:
    /// - stop: The stop this item belongs to;
    /// - name: Display name of the item;
    /// - type: Displays category of the item - hotel, museum, restaurent, other;
    /// - address: Displays address of the item;
    /// - latitude: Displays latitude coordinate of the item;
    /// - longitude: Displays longitude coordinate of the item;
    /// - photo: Optional photo for the item place.
    func addItem(to stop: Stop, name: String, type: ItemType, address: String, latitude: Double, longitude: Double, photo: Data? = nil) {
        let item = TripItem(name: name, type: type, address: address, latitude: latitude, longitude: longitude)
        item.photo = photo
        item.stop = stop
        stop.items.append(item)
        saveContext()
    }
    
    //MARK: - Delete Item
    /// Removes item from the stop and deletes this place from the database.
    func deleteItem(_ item: TripItem, from stop: Stop) {
        stop.items.removeAll(where: { $0.id == item.id })
        context.delete(item)
        saveContext()
    }
    
    //MARK: - Add Photos
    /// Adds one or more photos to the trip's gallery.
    /// New photos are appending after the existing photos, in the `order` sequence.
    /// - Parameters:
    /// - photosData: Raw image of data of each photo to add;
    /// - trip: the trip photos belong to.
    func addPhotos(_ photosData: [Data], to trip: Trip) {
        let startOrder = trip.photos.count
        for (index, data) in photosData.enumerated() {
            let photo = TripPhoto(photoData: data, order: startOrder + index)
            photo.trip = trip
            trip.photos.append(photo)
        }
        saveContext()
    }
    
    //MARK: - Delete Photos
    /// Removes each photos from the gallery and deletes it from the database.
    func deletePhotos(_ photos: [TripPhoto], from trip: Trip) {
        for photo in photos {
            trip.photos.removeAll { $0.persistentModelID == photo.persistentModelID }
            context.delete(photo)
        }
        saveContext()
    }
    
    //MARK: - Update Photo Order
    /// Updates the photo `order` to match it's position in the array.
    /// It's calls after user manually use drag-and-drop in the gallery.
    /// - Parameter: photos in the new desired order.
    func updatePhotoOrder(_ photos: [TripPhoto]) {
        for (index, photo) in photos.enumerated() {
            photo.order = index
        }
        saveContext()
    }
    
    //MARK: - Add Stop Photos
    /// Adding raw image data to the stop icon in trip map.
    func addStopPhotos(_ photoData: Data, to stop: Stop) {
        let photo = StopPhoto(photoData: photoData, order: stop.stopPhoto.count)
        photo.stop = stop
        stop.stopPhoto.append(photo)
        saveContext()
    }
    
    //MARK: - Save Context
    /// Persists pending changes to the model context.
    /// Errors are logged but not thrown, since save failures here are not user-facing.
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("\(error.localizedDescription) - Failed to save context")
        }
    }
}
