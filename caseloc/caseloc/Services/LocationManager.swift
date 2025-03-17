//
//  LocationManager.swift
//  caseloc
//
//  Created by Toygun Çil on 17.03.2025.
//

import MapKit
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation)
    func locationManager(_ manager: LocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    func locationManager(_ manager: LocationManager, didFailWithError error: Error)
}

class LocationManager: NSObject {
    
    private let locationManager = CLLocationManager()
    private var isTrackingEnabled = true
    
    weak var delegate: LocationManagerDelegate?
    
    var currentLocation: CLLocation? {
        return locationManager.location
    }
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        isTrackingEnabled = true
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        isTrackingEnabled = false
        locationManager.stopUpdatingLocation()
    }
    
    func checkLocationPermission() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    
    func reverseGeocodeLocation(_ location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("Ters jeokodlama hatası: \(error!.localizedDescription)")
                completion(Constants.Messages.addressError)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(Constants.Messages.addressNotFound)
                return
            }
            
            let addressString = self.formatShortAddress(from: placemark)
            completion(addressString)
        }
    }
    
    func getDetailedAddress(for location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("Detaylı adres getirme hatası: \(error!.localizedDescription)")
                completion(Constants.Messages.addressError)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(Constants.Messages.addressNotFound)
                return
            }
            
            let detailedAddress = self.formatDetailedAddress(from: placemark)
            completion(detailedAddress)
        }
    }
    
    private func formatShortAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if addressComponents.isEmpty {
            if let name = placemark.name {
                return name
            } else {
                return Constants.Messages.unknownAddress
            }
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    private func formatDetailedAddress(from placemark: CLPlacemark) -> String {
        var addressDetails: [String] = []
        
        if let name = placemark.name {
            addressDetails.append("Yer: \(name)")
        }
        
        if let thoroughfare = placemark.thoroughfare {
            var street = "Sokak: \(thoroughfare)"
            if let subThoroughfare = placemark.subThoroughfare {
                street += " No: \(subThoroughfare)"
            }
            addressDetails.append(street)
        }
        
        if let subLocality = placemark.subLocality {
            addressDetails.append("Mahalle: \(subLocality)")
        }
        
        if let locality = placemark.locality {
            addressDetails.append("İlçe: \(locality)")
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressDetails.append("İl: \(administrativeArea)")
        }
        
        if let postalCode = placemark.postalCode {
            addressDetails.append("Posta Kodu: \(postalCode)")
        }
        
        if let country = placemark.country {
            addressDetails.append("Ülke: \(country)")
        }
        
        if addressDetails.isEmpty {
            return Constants.Messages.unknownAddress
        }
        
        return addressDetails.joined(separator: "\n")
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        delegate?.locationManager(self, didChangeAuthorizationStatus: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManager(self, didChangeAuthorizationStatus: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTrackingEnabled, let location = locations.last else { return }
        
        let locationAge = -location.timestamp.timeIntervalSinceNow
        if locationAge > 5.0 {
            return
        }
        
        if location.horizontalAccuracy < 0 {
            return
        }
        
        delegate?.locationManager(self, didUpdateLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManager(self, didFailWithError: error)
    }
}
