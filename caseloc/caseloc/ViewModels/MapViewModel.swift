//
//  MapViewModel.swift
//  caseloc
//
//  Created by Toygun Çil on 17.03.2025.
//

import MapKit

protocol MapViewModelDelegate: AnyObject {
    func viewModel(_ viewModel: MapViewModel, didUpdateMarkers markers: [MKPointAnnotation])
    func viewModel(_ viewModel: MapViewModel, didChangeTrackingState isTracking: Bool)
    func viewModel(didResetRoute viewModel: MapViewModel)
    func viewModel(_ viewModel: MapViewModel, needsPermissionAlert message: String)
    func viewModel(_ viewModel: MapViewModel, didToggleRouteVisibility isVisible: Bool, routePolyline: MKPolyline?)
    func viewModel(_ viewModel: MapViewModel, didCalculateRouteStatistics statistics: RouteStatistics)
}

class MapViewModel: NSObject {
    
    // MARK: - Properties
    private let locationManager: LocationManager
    private var savedLocations: [SavedLocation] = []
    private var locationMarkers: [MKPointAnnotation] = []
    private var lastLocation: CLLocation?
    private var isRouteVisible = false
    private var isTrackingEnabled: Bool = true {
        didSet {
            delegate?.viewModel(self, didChangeTrackingState: isTrackingEnabled)
        }
    }
    
    weak var delegate: MapViewModelDelegate?
    
    // MARK: - Initialization
    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        loadSavedRoute()
    }
    
    // MARK: - Route Methods
    
    func toggleRouteVisibility() {
        isRouteVisible = !isRouteVisible
        
        if isRouteVisible && locationMarkers.count >= 2 {
            let polyline = createRoutePolyline()
            delegate?.viewModel(self, didToggleRouteVisibility: isRouteVisible, routePolyline: polyline)
            
            let statistics = calculateRouteStatistics()
            delegate?.viewModel(self, didCalculateRouteStatistics: statistics)
        } else {
            delegate?.viewModel(self, didToggleRouteVisibility: isRouteVisible, routePolyline: nil)
        }
    }
    
    private func calculateRouteStatistics() -> RouteStatistics {
        return RouteStatistics(locations: savedLocations)
    }
    
    private func createRoutePolyline() -> MKPolyline {
        let coordinates = locationMarkers.map { $0.coordinate }
        
        var coords = coordinates
        
        guard coords.count >= 2 else {
            let dummyCoords = [
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                CLLocationCoordinate2D(latitude: 0, longitude: 0.001)
            ]
            return MKPolyline(coordinates: dummyCoords, count: 2)
        }
        
        return MKPolyline(coordinates: coords, count: coords.count)
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() {
        locationManager.requestLocationPermission()
    }
    
    func checkLocationPermission() {
        let status = locationManager.checkLocationPermission()
        handleAuthorizationStatus(status)
    }
    
    func setTracking(enabled: Bool) {
        isTrackingEnabled = enabled
        
        if isTrackingEnabled {
            locationManager.startTracking()
        } else {
            locationManager.stopTracking()
        }
    }
    
    func resetRoute() {
        locationMarkers.removeAll()
        lastLocation = nil
        savedLocations.removeAll()
        saveRouteToUserDefaults()
        delegate?.viewModel(didResetRoute: self)
    }
    
    func getDetailedAddress(for annotation: MKAnnotation, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        locationManager.getDetailedAddress(for: location, completion: completion)
    }
    
    func isUserAtStartingPosition() -> Bool {
        return lastLocation == nil
    }
    
    func getCurrentLocation() -> CLLocation? {
        return locationManager.currentLocation
    }
    
    // MARK: - Private Methods
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestLocationPermission()
        case .restricted, .denied:
            delegate?.viewModel(self, needsPermissionAlert: Constants.Messages.permissionMessage)
        case .authorizedWhenInUse, .authorizedAlways:
            if isTrackingEnabled {
                locationManager.startTracking()
            }
        @unknown default:
            break
        }
    }
    
    private func checkLocationChange(newLocation: CLLocation) {
        guard let lastLocation = lastLocation else {
            self.lastLocation = newLocation
            addMarkerAt(location: newLocation, title: Constants.Messages.startingPoint)
            return
        }

        let distance = lastLocation.distance(from: newLocation)
        
        if distance >= Constants.Map.minimumDistanceThreshold {
            addMarkerAt(location: newLocation, title: formattedTime())
            self.lastLocation = newLocation
        }
    }
    
    private func addMarkerAt(location: CLLocation, title: String) {
        let marker = MKPointAnnotation()
        marker.coordinate = location.coordinate
        marker.title = title
        marker.subtitle = String(format: "Konum: %.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude)
        
        locationMarkers.append(marker)
        let savedLocation = SavedLocation(location: location, title: title, subtitle: marker.subtitle)
        savedLocations.append(savedLocation)
        

        delegate?.viewModel(self, didUpdateMarkers: locationMarkers)
        saveRouteToUserDefaults()
        
        locationManager.reverseGeocodeLocation(location) { [weak self] addressString in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                marker.subtitle = addressString
                
                if let index = self.savedLocations.firstIndex(where: { $0.latitude == location.coordinate.latitude && $0.longitude == location.coordinate.longitude }) {
                    let updatedLocation = SavedLocation(
                        location: location,
                        title: title,
                        subtitle: addressString,
                        timestamp: self.savedLocations[index].timestamp
                    )
                    self.savedLocations[index] = updatedLocation
                }
                
                self.delegate?.viewModel(self, didUpdateMarkers: self.locationMarkers)
                self.saveRouteToUserDefaults()
            }
        }
    }
    
    private func formattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DateFormats.timeOnly
        return dateFormatter.string(from: Date())
    }
    
    // MARK: - UserDefaults Methods
    private func saveRouteToUserDefaults() {
        savedLocations = locationMarkers.map { SavedLocation(marker: $0) }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(savedLocations)
            
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.savedRouteKey)
        } catch {
            print("Rota kaydedilemedi: \(error.localizedDescription)")
        }
    }
    
    private func loadSavedRoute() {
        guard let data = UserDefaults.standard.data(forKey: Constants.UserDefaults.savedRouteKey) else {
            print("Kaydedilmiş rota bulunamadı")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            savedLocations = try decoder.decode([SavedLocation].self, from: data)
            
            locationMarkers = savedLocations.map { $0.toMarker() }
            
            if let lastSavedLocation = savedLocations.last {
                lastLocation = CLLocation(latitude: lastSavedLocation.latitude, longitude: lastSavedLocation.longitude)
            }
            
            delegate?.viewModel(self, didUpdateMarkers: locationMarkers)
            
            print("Rota yüklendi, \(savedLocations.count) konum var")
        } catch {
            print("Rota yüklenemedi: \(error.localizedDescription)")
        }
    }
}

// MARK: - LocationManagerDelegate
extension MapViewModel: LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation) {
        if isTrackingEnabled {
            checkLocationChange(newLocation: location)
        }
    }
    
    func locationManager(_ manager: LocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        handleAuthorizationStatus(status)
    }
    
    func locationManager(_ manager: LocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
    }
}
