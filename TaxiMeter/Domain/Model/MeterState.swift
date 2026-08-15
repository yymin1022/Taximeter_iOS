//
//  MeterState.swift
//  TaxiMeter
//

import Foundation

/// Meter State Data Model
public struct MeterState: Equatable, Sendable {
    /// Current cost (KRW)
    public let currentCost: Int
    /// Drove distance (m)
    public let totalDistanceMeters: Double
    /// Drove time (s)
    public let totalElapsedSeconds: Double
    /// Current speed (km/h)
    public let currentSpeedKph: Double
    /// Meter status
    public let status: MeterStatus
    /// Whether night rate is applied
    public let isNightRate: Bool
    /// Whether city rate is applied
    public let isCityRate: Bool

    public init(
        currentCost: Int = 0,
        totalDistanceMeters: Double = 0.0,
        totalElapsedSeconds: Double = 0.0,
        currentSpeedKph: Double = 0.0,
        status: MeterStatus = .notRunning,
        isNightRate: Bool = false,
        isCityRate: Bool = false
    ) {
        self.currentCost = currentCost
        self.totalDistanceMeters = totalDistanceMeters
        self.totalElapsedSeconds = totalElapsedSeconds
        self.currentSpeedKph = currentSpeedKph
        self.status = status
        self.isNightRate = isNightRate
        self.isCityRate = isCityRate
    }
}
