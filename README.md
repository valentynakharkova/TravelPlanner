# TravelPlanner

A native iOS app for planning multi-stop trips — built with SwiftUI and SwiftData as part of an iOS developer portfolio.

## Overview

TravelPlanner lets users organize a trip as a hierarchy of stops and items — plan a route across multiple cities, attach hotels, restaurants, and attractions to each stop, and get calendar and notification reminders as the trip approaches.

## Icon
<img width="259" height="289" alt="IMG_9219" src="https://github.com/user-attachments/assets/33904a05-253a-43e5-a99e-0e09609e1afa" />

## Screenshots
<img width="660" height="1434" alt="IMG_9221" src="https://github.com/user-attachments/assets/2bdd6be8-0932-42eb-92d3-130c57c45b5e" />
<img width="660" height="1434" alt="IMG_9221" src="https://github.com/user-attachments/assets/70e5c267-c7ef-4853-9792-173d23e76114" />
<img width="660" height="1434" alt="IMG_9222" src="https://github.com/user-attachments/assets/74d4ae8a-990a-41d6-88d7-da520f125f95" />
<img width="660" height="1434" alt="IMG_9223" src="https://github.com/user-attachments/assets/ece165d7-c171-49ea-a3a7-11bdde8aed26" />
<img width="660" height="1434" alt="IMG_9224" src="https://github.com/user-attachments/assets/ad6a4387-c0de-48e9-9ad0-563b06d61c4a" />
<img width="660" height="1434" alt="IMG_9225" src="https://github.com/user-attachments/assets/1e6137db-bd6f-4850-9e05-e90102c92f5e" />
<img width="660" height="1434" alt="IMG_9226" src="https://github.com/user-attachments/assets/c61fa4d1-61ed-4c60-b0df-2e5329ce8927" />
<img width="660" height="1434" alt="IMG_9227" src="https://github.com/user-attachments/assets/30fc7e89-61e1-4962-b524-9a5d6c504d31" />
<img width="660" height="1434" alt="IMG_9228" src="https://github.com/user-attachments/assets/b937932e-b9ce-40c4-ba95-827d5f2a752e" />
<img width="660" height="1434" alt="IMG_9230" src="https://github.com/user-attachments/assets/de5de2bf-8077-49eb-a8cf-acd02e62486e" />
<img width="660" height="1434" alt="IMG_9233" src="https://github.com/user-attachments/assets/90b9bfb9-184c-4cfc-8d7e-8a28a8ec0b62" />
<img width="660" height="1434" alt="IMG_9234" src="https://github.com/user-attachments/assets/bdde29b8-41b6-4b9f-aac3-02ef33363a91" />
<img width="660" height="1434" alt="IMG_9235" src="https://github.com/user-attachments/assets/e59fe8cf-363f-4640-a605-00cadbee7d08" />
<img width="660" height="1434" alt="IMG_9236" src="https://github.com/user-attachments/assets/74c46d40-a03b-43ba-8fd9-bdaced79fe39" />
<img width="660" height="1434" alt="IMG_9239" src="https://github.com/user-attachments/assets/d65c6d5d-5565-46d8-8d72-5a5147f0e359" />

## Video Recording

https://github.com/user-attachments/assets/1de05eaf-d6e7-4f5b-b9c7-678b27be6323

## Features
- Trip management — create, edit, archive, and soft-delete trips, with cover photos
- Stops & items — organize each trip into stops (cities), each with items like hotels, restaurants, and attractions
- Location search — find real places via MapKit and MKLocalSearchCompleter, with live autocomplete suggestions
- Interactive maps — view all items for a stop on a map, grouped and annotated by type
- Photos — add cover and gallery photos via PhotosUI, or capture new ones with the camera
- Calendar integration — add a trip to the system calendar via EventKit
- Reminders — schedule a local notification the day before arriving at a stop, via UserNotifications
- Smart sorting — stops with a set arrival date are automatically sorted chronologically; stops without a date stay grouped separately, avoiding the need for manual drag-and-drop reordering

## Architecture

The app follows MVVM, with SwiftData as the persistence layer. Data model hierarchy:

- Trip
  - Stop
    - TripItem
    - StopPhoto
  - TripPhoto
- Views (SwiftUI) — declarative UI, no business logic
- TripViewModel (@Observable) — owns all SwiftData operations (create/update/delete/reorder) so views stay thin and testable
- Services — isolated wrappers around system frameworks (EventKitService, NotificationService, LocationSearchService), each independently responsible for a single external capability


## Project Structure
### TravelPlanner/
```
TravelPlanner/
├── Models/
│   ├── Trip.swift                    — SwiftData model; trip dates, cover photo, archive/soft-delete state
│   ├── Stop.swift                    — SwiftData model; a city within a trip, with order and optional dates
│   ├── TripItem.swift                — SwiftData model; hotel/restaurant/museum/other attached to a stop
│   ├── TripPhoto.swift               — SwiftData model; ordered photo in a trip's gallery
│   ├── StopPhoto.swift               — SwiftData model; ordered photo attached to a stop
│   └── ItemType.swift                — Enum for item categories, with icon/color/sort order
│
├── ViewModels/
│   └── TripViewModel.swift           — Owns all SwiftData operations: CRUD, archive, reorder, photos
│
├── Services/
│   ├── LocationSearchService.swift   — MKLocalSearchCompleter + CoreLocation; live place autocomplete
│   ├── EventKitService.swift         — Adds a trip to the system calendar via EKEventStore
│   ├── NotificationService.swift     — Schedules a local reminder the day before a stop's arrival
│   └── CameraPicker.swift            — UIViewControllerRepresentable wrapper for UIImagePickerController
│
├── Views/
│   ├── TripListView.swift            — Root screen; list of trips, navigation entry point
│   ├── TripRowView.swift             — Single trip row in the list
│   ├── AddTripView.swift             — Sheet for creating a new trip
│   ├── ArchivedTrips.swift           — Archived trips screen
│   ├── RecentlyDeleted.swift         — Soft-deleted trips; restore or permanently delete
│   ├── TripDetailView.swift          — Trip overview; grid of stops, map/photos tiles
│   ├── StopDetailView.swift          — Items within a stop, grouped by type, with map annotations
│   ├── AddStopView.swift             — Sheet for creating/editing a stop, with location search
│   ├── LocationSearchView.swift      — Search field + live suggestion list, backed by LocationSearchService
│   ├── TripMapView.swift             — Full trip map with photo-thumbnail pins per stop
│   ├── TripPhotosView.swift          — Trip's photo gallery grid
│   ├── AddItemView.swift             — Sheet for adding an item to a stop
│   └── ItemRowView.swift             — Single item row within a stop's grouped list
│
└── TravelPlannerApp.swift            — App entry point; SwiftData ModelContainer setup

TravelPlannerTests/
└── TripViewModelTests.swift          — Unit tests for TripViewModel (see Testing section below)
```
Each layer has a single responsibility: Models define the SwiftData schema, ViewModels own all data mutations, Services isolate system-framework dependencies (MapKit, EventKit, UserNotifications, UIKit), and Views stay declarative with no direct ModelContext logic beyond reading data through the view model.

## Tech Stack
- SwiftUI, SwiftData
- MapKit, MKLocalSearch, CoreLocation
- PhotosUI, UIKit (UIImagePickerController via UIViewControllerRepresentable)
- EventKit
- UserNotifications
- XCTest

Minimum deployment target: iOS 26 (uses iOS 26 APIs such as .glassEffect() and MKAddress)

## Testing

TripViewModel is covered by a suite of XCTest unit tests, using an in-memory ModelContainer to isolate each test from real persisted data.

## Tests cover:

- Creating and deleting trips, stops, and items
- Archiving (toggle) behavior
- Bulk deletion, verifying only the targeted objects are removed
- Reordering stops and verifying the resulting order.

## Author 
Valentyna Kharkova — Junior iOS Developer Building a native iOS portfolio | 2026
