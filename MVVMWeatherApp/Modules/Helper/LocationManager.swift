//
//  LocationManager.swift
//  WeatherApp
//
//  Created by khalifa on 1/23/21.
//

import Foundation
import CoreLocation

protocol LocationManager {
    var delegate: LocationManagerDelegate? { get set }
    func getUserLocation()
    func askUserForLocationPermission()
    func getCityName(lat: Double, long: Double, completion: @escaping (String?) -> Void)
}

protocol LocationManagerDelegate: class {
    func onLocationLoaded(lat: Double, long: Double)
    func onError(_ error: String)
    func onPermissionNeeded()
    func onPermissionDenied()
    func onPermissionGiven()
}

class LocationManagerImpl: NSObject, LocationManager {
    private var manager: CLLocationManager
    weak var delegate: LocationManagerDelegate?
    
    init(delegate: LocationManagerDelegate?) {
        let manager = CLLocationManager()
        self.manager = manager
        self.delegate = delegate
        super.init()
        manager.delegate = self
    }
    
    func getUserLocation() {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: manager.requestLocation()
        case .denied, .restricted: delegate?.onPermissionDenied()
        case .notDetermined: delegate?.onPermissionNeeded()
        default: break
        }
    }
    
    func askUserForLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: delegate?.onPermissionGiven()
        case .denied, .restricted: delegate?.onPermissionDenied()
        default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.onError(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else {
            delegate?.onError("Couldn't load location.")
            return
        }
        delegate?.onLocationLoaded(lat: location.latitude, long: location.longitude)
    }
    
    func getCityName(lat: Double, long: Double, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(.init(latitude: lat, longitude: long)) {(placemarks, error) in
            guard let placemarks = placemarks, let placemark = placemarks.first else {
                completion(nil)
                return }
            completion(placemark.locality ?? placemark.administrativeArea)
        }
    }    
}

extension LocationManagerImpl: CLLocationManagerDelegate {
}
