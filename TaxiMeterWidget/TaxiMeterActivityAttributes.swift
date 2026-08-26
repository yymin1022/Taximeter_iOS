//
//  TaxiMeterActivityAttributes.swift
//  TaxiMeterWidget
//

import Foundation
import ActivityKit

public struct TaxiMeterActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var currentCost: Int
        public var costCounter: Int
        public var currentSpeedKph: Double
        public var totalDistanceMeters: Double
        public var isNightRate: Bool
        public var isCityRate: Bool

        public init(
            currentCost: Int = 0,
            costCounter: Int = 0,
            currentSpeedKph: Double = 0.0,
            totalDistanceMeters: Double = 0.0,
            isNightRate: Bool = false,
            isCityRate: Bool = false
        ) {
            self.currentCost = currentCost
            self.costCounter = costCounter
            self.currentSpeedKph = currentSpeedKph
            self.totalDistanceMeters = totalDistanceMeters
            self.isNightRate = isNightRate
            self.isCityRate = isCityRate
        }
    }

    public var regionName: String

    public init(regionName: String) {
        self.regionName = regionName
    }
}
