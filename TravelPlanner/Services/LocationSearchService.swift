//
//  LocationSearchService.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 09.07.2026.
//

import Foundation
import MapKit
import CoreLocation

/// Provides live location search suggestions as the user types and resolves
/// a selective suggestion into full location details (coordinates, address, country).
/// Combines `MKLocalSearchCompleter` for autocomplete suggestions with `CLLocationManager`
/// to bias search results toward the user's current location.
@Observable
class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate {
    private let completer: MKLocalSearchCompleter
    private let locationManager: CLLocationManager
    
    /// The current search text. Setting this updates `suggestions` asynchronously
    /// via the completer delegate.
    var queryFragment: String = "" {
        didSet {
            completer.queryFragment = queryFragment
        }
    }
    
    /// Autocomplete suggestions matching the current `queryFragment`
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
    
    /// Resolves a selected autocomplete suggestion into full location details.
    /// - Parameter completion: The suggestion the user selected from `suggestions`.
    /// - Returns: a tuple with the location name, address, country and coordinates,
    /// or nil if the search fails or return no results.
    func resolveLocation(for completion: MKLocalSearchCompletion) async -> (name: String, address: String, country: String, latitude: Double, longitude: Double)? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            guard let mapItem = response.mapItems.first else { return nil }
            
            let name = mapItem.name ?? completion.title
            let address = mapItem.address?.fullAddress ?? completion.subtitle
            let coordinate = mapItem.location.coordinate
            let country = await reverseGeocodingCountry(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            return (name, address, country, coordinate.latitude, coordinate.longitude)
        } catch {
            print("Search failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Looks up the country name for a given coordinate via reverse geocoding.
    /// - Returns: the coutry name or an empty string if lookup fails.
    func reverseGeocodingCountry(latitude: Double, longitude: Double) async -> String {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        guard let request = MKReverseGeocodingRequest(location: location) else {
            return ""
        }
        
        do {
            let mapItems = try await request.mapItems
            
            guard let fullAddress = mapItems.first?.address?.fullAddress else {
                return ""
            }
            let components = fullAddress.components(separatedBy: ", ")
            return components.last ?? ""
        } catch {
            print("Reverse geocoding failed: \(error.localizedDescription)")
            return ""
        }
    }
}

