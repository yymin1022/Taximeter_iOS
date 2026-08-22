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
        self.locationManager.activityType = .automotiveNavigation
        self.locationManager.pausesLocationUpdatesAutomatically = false
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
                    if status == .authorizedWhenInUse || status == .authorizedAlways {
                        self.startLocationUpdates()
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
                        self.stopLocationUpdates()
                    }
                }
            }
        }
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            lock.lock()
            let hasListeners = !continuations.isEmpty
            lock.unlock()
            if hasListeners {
                startLocationUpdates()
            }
        case .denied, .restricted, .notDetermined:
            break
        @unknown default:
            break
        }
    }

    private func startLocationUpdates() {
        enableBackgroundLocationUpdatesIfSupported()
        self.locationManager.startUpdatingLocation()
    }

    private func stopLocationUpdates() {
        #if os(iOS)
        self.locationManager.allowsBackgroundLocationUpdates = false
        self.locationManager.showsBackgroundLocationIndicator = false
        #endif
        self.locationManager.stopUpdatingLocation()
    }

    private func enableBackgroundLocationUpdatesIfSupported() {
        #if os(iOS)
        let rawModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes")
        let hasLocationMode: Bool
        if let arrayModes = rawModes as? [String] {
            hasLocationMode = arrayModes.contains("location")
        } else if let stringMode = rawModes as? String {
            hasLocationMode = stringMode.contains("location")
        } else {
            hasLocationMode = false
        }

        if hasLocationMode {
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.showsBackgroundLocationIndicator = true
        }
        #endif
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
