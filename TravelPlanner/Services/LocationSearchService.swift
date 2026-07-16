//
//  LocationSearchService.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 09.07.2026.
//

import Foundation
import MapKit
import CoreLocation

@Observable
class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate {
    private let completer: MKLocalSearchCompleter
    private let locationManager: CLLocationManager
    
    var queryFragment: String = "" {
        didSet {
            completer.queryFragment = queryFragment
        }
    }
    
    var suggestions: [MKLocalSearchCompletion] = []
    
    override init() {
        self.completer = MKLocalSearchCompleter()
        self.locationManager = CLLocationManager()
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        print("Search completer failed: \(error.localizedDescription)")
        suggestions = []
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        completer.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 50000,
            longitudinalMeters: 50000
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func resolveLocation(for completion: MKLocalSearchCompletion) async -> (name: String, address: String, latitude: Double, longitude: Double)? {
        
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            guard let mapItem = response.mapItems.first else { return nil}
            
            let name = mapItem.name ?? completion.title
            let address = mapItem.address?.fullAddress ?? completion.subtitle
            let coordinate = mapItem.location.coordinate
            
            return (name, address, coordinate.latitude, coordinate.longitude)
        } catch {
            print("Search failed: \(error.localizedDescription)")
            return nil
        }
    }
}

