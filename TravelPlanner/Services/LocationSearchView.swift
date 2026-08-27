//
//  LocationSearchView.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 09.07.2026.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    
    @State private var searchText: String = ""
    @State private var searchLocation = LocationSearchService()
    @State private var isSearching = false
    
    let onSelect: (String, String, String, Double, Double) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search for a place", text: $searchText)
                .textFieldStyle(.automatic)
                .onChange(of: searchText) { _, newValue in
                    searchLocation.queryFragment = newValue
                    isSearching = !newValue.isEmpty
                }
            
            if isSearching && !searchLocation.suggestions.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchLocation.suggestions, id: \.self) { suggestion in
                            Button {
                                selectSuggestion(suggestion)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    Text(suggestion.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 6)
                            }
                            if suggestion != searchLocation.suggestions.last {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
    }
    
    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        Task {
            if let result = await searchLocation.resolveLocation(for: suggestion) {
                onSelect(result.name, result.address, result.country, result.latitude, result.longitude)
                searchText = result.name
                isSearching = false
            }
        }
    }
    
}

#Preview {
    LocationSearchView { name, address, country, latitude, longitude in
        print("Selected location: \(name), \(address), \(country), \(latitude), \(longitude)")
    }
}
