//
//  MeterHistory.swift
//  TaxiMeter
//

import Foundation

/// Meter History Domain Model
public struct MeterHistory: Equatable, Identifiable, Sendable {
    public let id: Int64
    public let timestamp: Int64
    public let cost: Int
    public let distanceMeters: Double
    public let elapsedSeconds: Double

    public init(
        id: Int64 = 0,
        timestamp: Int64,
        cost: Int,
        distanceMeters: Double,
        elapsedSeconds: Double
    ) {
        self.id = id
        self.timestamp = timestamp
        self.cost = cost
        self.distanceMeters = distanceMeters
        self.elapsedSeconds = elapsedSeconds
    }
}
