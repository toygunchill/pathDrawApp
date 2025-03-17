//
//  LocationModel.swift
//  caseloc
//
//  Created by Toygun Çil on 17.03.2025.
//

import MapKit

// MARK: - SavedLocation Model
struct SavedLocation: Codable {
    let latitude: Double
    let longitude: Double
    let title: String
    let subtitle: String?
    let timestamp: Date
    
    init(marker: MKPointAnnotation, timestamp: Date = Date()) {
        self.latitude = marker.coordinate.latitude
        self.longitude = marker.coordinate.longitude
        self.title = marker.title ?? "Konum"
        self.subtitle = marker.subtitle
        self.timestamp = timestamp
    }
    
    init(location: CLLocation, title: String, subtitle: String? = nil, timestamp: Date = Date()) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.title = title
        self.subtitle = subtitle
        self.timestamp = timestamp
    }
    
    func toMarker() -> MKPointAnnotation {
        let marker = MKPointAnnotation()
        marker.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.subtitle = subtitle
        return marker
    }
    
    func toLocation() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
