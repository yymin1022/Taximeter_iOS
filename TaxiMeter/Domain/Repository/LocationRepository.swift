//
//  LocationRepository.swift
//  TaxiMeter
//

import Foundation

/// Location Repository Interface
/// - Observe real-time location updates
public protocol LocationRepository: Sendable {
    func observeUpdate() -> AsyncStream<LocationData>
}
