//
//  SpeedData.swift
//  TaxiMeter
//

import Foundation

/// Speed Data Model
/// - Calculated from two consecutive LocationData points
public struct SpeedData: Equatable, Sendable {
    /// Delta distance (m)
    public let distanceDeltaMeters: Double
    /// Delta elapsed time (s)
    public let elapsedDeltaSeconds: Double
    /// Current speed (km/h)
    public let speedKph: Double
    /// GPS Status
    public let status: MeterStatus

    public static let zero = SpeedData(
        distanceDeltaMeters: 0.0,
        elapsedDeltaSeconds: 0.0,
        speedKph: 0.0,
        status: .running
    )

    public init(
        distanceDeltaMeters: Double = 0.0,
        elapsedDeltaSeconds: Double = 0.0,
        speedKph: Double = 0.0,
        status: MeterStatus = .running
    ) {
        self.distanceDeltaMeters = distanceDeltaMeters
        self.elapsedDeltaSeconds = elapsedDeltaSeconds
        self.speedKph = speedKph
        self.status = status
    }
}
