//
//  LocationData.swift
//  TaxiMeter
//

import Foundation

/// Location Data Model
public struct LocationData: Equatable, Sendable {
    /// Latitude value
    public let latitude: Double
    /// Longitude value
    public let longitude: Double
    /// GPS Accuracy (meter)
    public let accuracyMeters: Double
    /// GPS Timestamp (ms)
    public let timestampMillis: Int64

    public init(
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        accuracyMeters: Double = 0.0,
        timestampMillis: Int64 = 0
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracyMeters = accuracyMeters
        self.timestampMillis = timestampMillis
    }
}
