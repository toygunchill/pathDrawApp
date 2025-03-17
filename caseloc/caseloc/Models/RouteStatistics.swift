//
//  route.swift
//  caseloc
//
//  Created by Toygun Çil on 18.03.2025.
//

import MapKit

struct RouteStatistics {
    let totalDistance: CLLocationDistance
    let totalDuration: TimeInterval
    let averageSpeed: Double
    let startTime: Date?
    let endTime: Date?
    
    init(locations: [SavedLocation]) {
        guard locations.count >= 2 else {
            self.totalDistance = 0
            self.totalDuration = 0
            self.averageSpeed = 0
            self.startTime = nil
            self.endTime = nil
            return
        }
        
        let sortedLocations = locations.sorted { $0.timestamp < $1.timestamp }
        
        self.startTime = sortedLocations.first?.timestamp
        self.endTime = sortedLocations.last?.timestamp
        
        if let startTime = self.startTime, let endTime = self.endTime {
            self.totalDuration = endTime.timeIntervalSince(startTime)
        } else {
            self.totalDuration = 0
        }
        
        var distance: CLLocationDistance = 0
        for i in 0..<(sortedLocations.count - 1) {
            let currentLocation = CLLocation(latitude: sortedLocations[i].latitude, longitude: sortedLocations[i].longitude)
            let nextLocation = CLLocation(latitude: sortedLocations[i+1].latitude, longitude: sortedLocations[i+1].longitude)
            
            distance += currentLocation.distance(from: nextLocation)
        }
        self.totalDistance = distance
        self.averageSpeed = totalDuration > 0 ? totalDistance / totalDuration : 0
    }
}
