//
//  TravelPlannerTests.swift
//  TravelPlannerTests
//
//  Created by Valentyna Kharkova on 15.06.2026.
//

import XCTest
import SwiftData

@testable import TravelPlanner

final class TripViewModelTests: XCTestCase {
    
    var viewModel: TripViewModel!
    var context: ModelContext!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Trip.self, Stop.self, TripItem.self, configurations: config)
        context = ModelContext(container)
        viewModel = TripViewModel(context: context)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        context = nil
        viewModel = nil
    }
    
    func testAddTrip() throws {
        let start = Date.now
        let end = Date.now.addingTimeInterval(86400 * 5)
        viewModel.addTrip(name: "Japan", startDate: start, endDate: end)
        let trips = try context.fetch(FetchDescriptor<Trip>())
        XCTAssertEqual(trips.count, 1)
        XCTAssertEqual(trips.first?.name, "Japan")
    }
    
    func testAddStop() throws {
        let trip = Trip(name: "Japan", startDate: .now, endDate: .now)
        context.insert(trip)
        viewModel.addStop(to: trip, name: "Tokyo", country: "Japan", latitude: 35.6, longitude: 139.6)
        XCTAssertEqual(trip.stops.count, 1)
        XCTAssertEqual(trip.stops.first?.order, 0)
    }
    
    func testDeleteStop() throws {
        let trip = Trip(name: "Japan", startDate: .now, endDate: .now)
        context.insert(trip)
        viewModel.addStop(to: trip, name: "Tokyo", country: "Japan", latitude: 35.6, longitude: 139.6)
        let stop = trip.stops.first!
        viewModel.deleteStop(stop, from: trip)
        XCTAssertEqual(trip.stops.count, 0)
        let allStops = try context.fetch(FetchDescriptor<Stop>())
        XCTAssertEqual(allStops.count, 0)
    }
    
    func testReorderStop() throws {
        let trip = Trip(name: "Japan", startDate: .now, endDate: .now)
        context.insert(trip)
        viewModel.addStop(to: trip, name: "Tokyo", country: "Japan", latitude: 35.6, longitude: 139.6)
        viewModel.addStop(to: trip, name: "Kyoto", country: "Japan", latitude: 35.0, longitude: 135.0)
        viewModel.addStop(to: trip, name: "Osaka", country: "Japan", latitude: 34.6, longitude: 135.7)
        
        viewModel.reorderStops(in: trip, from: IndexSet(integer: 0), to: 3)
        
        let kyoto = trip.stops.first(where: {$0.name == "Kyoto"})!
        let osaka = trip.stops.first(where: {$0.name == "Osaka"})!
        let tokyo = trip.stops.first(where: {$0.name == "Tokyo"})!
        
        XCTAssertEqual(kyoto.order, 0)
        XCTAssertEqual(osaka.order, 1)
        XCTAssertEqual(tokyo.order, 2)
    }
    
    func testAddItem() throws {
        let stop = Stop(name: "Tokyo", country: "Japan", latitude: 35.6, longitude: 139.6)
        context.insert(stop)
        viewModel.addItem(to: stop, name: "Hotel", type: .hotel, address: "Address", latitude: 35.6, longitude: 139.5)
        XCTAssertEqual(stop.items.count, 1)
        XCTAssertEqual(stop.items.first?.name, "Hotel")
        XCTAssertEqual(stop.items.first?.type, .hotel)
        XCTAssertEqual(stop.items.first?.stop?.id, stop.id)
    }
    
    func testDeleteItem() throws {
        let stop = Stop(name: "Tokyo", country: "Japan", latitude: 35.6, longitude: 139.6)
        context.insert(stop)
        viewModel.addItem(to: stop, name: "Hotel", type: .hotel, address: "Address", latitude: 35.6, longitude: 139.6)
        let item = stop.items.first!
        viewModel.deleteItem(item, from: stop)
        XCTAssertEqual(stop.items.count, 0)
        let allItems = try context.fetch(FetchDescriptor<TripItem >())
        XCTAssertEqual(allItems.count, 0)
    }
    
    func testPermanentlyDeleteAllTrips() throws {
        let trip1 = Trip(name: "Japan", startDate: .now, endDate: .now)
        context.insert(trip1)
        let trip2 = Trip(name: "Italy", startDate: .now, endDate: .now)
        context.insert(trip2)
        let trip3 = Trip(name: "Spain", startDate: .now, endDate: .now)
        context.insert(trip3)
        
        viewModel.permanentlyDeleteAllTrips([trip1, trip2])
        
        let allTrips = try context.fetch(FetchDescriptor<Trip>())
        XCTAssertEqual(allTrips.first?.name, "Spain")
        XCTAssertEqual(allTrips.count, 1)
    }
    
    func testArchiveTrip() throws {
        let trip = Trip(name: "Japan", startDate: .now, endDate: .now)
        context.insert(trip)
        
        XCTAssertEqual(trip.isArchived, false)
        
        viewModel.archiveTrip(trip)
        XCTAssertEqual(trip.isArchived, true)
        
        viewModel.archiveTrip(trip)
        XCTAssertEqual(trip.isArchived, false)
    }
    
    func testAddPhotos() throws {
        let trip = Trip(name: "Japan", startDate: .now, endDate: .now)
        context.insert(trip)
        viewModel.addPhotos([Data()], to: trip)
        XCTAssertEqual(trip.photos.count, 1)
        viewModel.addPhotos([Data()], to: trip)
        XCTAssertEqual(trip.photos.count, 2)
        
        let sortedPhotos = trip.photos.sorted(by: {$0.order < $1.order})
        XCTAssertEqual(sortedPhotos[0].order, 0)
        XCTAssertEqual(sortedPhotos[1].order, 1)
        
    }

}
