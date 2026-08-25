//
//  MeterHistoryEntity.swift
//  TaxiMeter
//

import Foundation

/// Meter History Database Entity Table
/// Aligned with Android Room schema 'meter_history'
public struct MeterHistoryEntity: Codable, Equatable, Sendable {
    public let id: Int64
    public let timestamp: Int64
    public let cost: Int
    public let distanceMeters: Double
    public let elapsedSeconds: Double

    public enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case cost
        case distanceMeters = "distance_meters"
        case elapsedSeconds = "elapsed_seconds"
    }

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
