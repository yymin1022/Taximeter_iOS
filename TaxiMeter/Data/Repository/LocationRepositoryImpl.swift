//
//  LocationRepositoryImpl.swift
//  TaxiMeter
//

import Foundation
import CoreLocation

public final class LocationRepositoryImpl: NSObject, LocationRepository, CLLocationManagerDelegate, @unchecked Sendable {
    private let locationManager: CLLocationManager
    private var continuations: [UUID: AsyncStream<LocationData>.Continuation] = [:]
    private let lock = NSLock()

    public override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.pausesLocationUpdatesAutomatically = false

        // Only enable background location updates if UIBackgroundModes contains "location" to prevent NSInternalInconsistencyException crash
        if let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String],
           backgroundModes.contains("location") {
            self.locationManager.allowsBackgroundLocationUpdates = true
        }
    }

    public func observeUpdate() -> AsyncStream<LocationData> {
        let id = UUID()
        return AsyncStream { continuation in
            lock.lock()
            let shouldStart = continuations.isEmpty
            continuations[id] = continuation
            lock.unlock()

            if shouldStart {
                DispatchQueue.main.async {
                    let status = self.locationManager.authorizationStatus
                    if status == .notDetermined {
                        self.locationManager.requestWhenInUseAuthorization()
                    } else if status == .authorizedWhenInUse || status == .authorizedAlways {
                        self.locationManager.startUpdatingLocation()
                    }
                }
            }

            continuation.onTermination = { [weak self] _ in
                guard let self = self else { return }
                self.lock.lock()
                self.continuations.removeValue(forKey: id)
                let shouldStop = self.continuations.isEmpty
                self.lock.unlock()

                if shouldStop {
                    DispatchQueue.main.async {
                        self.locationManager.stopUpdatingLocation()
                    }
                }
            }
        }
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            break
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let locationData = LocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracyMeters: location.horizontalAccuracy,
            timestampMillis: Int64(location.timestamp.timeIntervalSince1970 * 1000)
        )

        lock.lock()
        let activeContinuations = Array(continuations.values)
        lock.unlock()

        for continuation in activeContinuations {
            continuation.yield(locationData)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location manager error
    }
}
