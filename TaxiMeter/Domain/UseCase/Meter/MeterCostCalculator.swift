//
//  MeterCostCalculator.swift
//  TaxiMeter
//

import Foundation

/// Meter Cost Calculator
/// - Calculates and accumulates cost from SpeedData
/// - Dynamic calculation of total cost based only on internal state
public struct MeterCostCalculator: Equatable, Sendable {
    public let costInfo: CostInfo
    public let accumulatedExtraCost: Int
    public let costCounter: Int
    public let totalDistanceMeters: Double
    public let totalElapsedSeconds: Double
    public let currentSpeedKph: Double
    public let status: MeterStatus
    public let isNightRate: Bool
    public let isCityRate: Bool
    public let surchargeRate: Int

    /// Dynamic calculation of total cost based only on internal state
    public var cost: Int {
        let baseSurcharge = Int((Int64(costInfo.costBase) * Int64(surchargeRate)) / 100)
        return costInfo.costBase + baseSurcharge + accumulatedExtraCost
    }

    public init(
        costInfo: CostInfo,
        accumulatedExtraCost: Int = 0,
        costCounter: Int,
        totalDistanceMeters: Double = 0.0,
        totalElapsedSeconds: Double = 0.0,
        currentSpeedKph: Double = 0.0,
        status: MeterStatus = .notRunning,
        isNightRate: Bool = false,
        isCityRate: Bool = false,
        surchargeRate: Int = 0
    ) {
        self.costInfo = costInfo
        self.accumulatedExtraCost = accumulatedExtraCost
        self.costCounter = costCounter
        self.totalDistanceMeters = totalDistanceMeters
        self.totalElapsedSeconds = totalElapsedSeconds
        self.currentSpeedKph = currentSpeedKph
        self.status = status
        self.isNightRate = isNightRate
        self.isCityRate = isCityRate
        self.surchargeRate = surchargeRate
    }

    /// Init MeterCostCalculator instance with CostInfo
    public static func newWithCostInfo(_ costInfo: CostInfo) -> MeterCostCalculator {
        return MeterCostCalculator(
            costInfo: costInfo,
            accumulatedExtraCost: 0,
            costCounter: costInfo.distBase,
            totalDistanceMeters: 0.0,
            totalElapsedSeconds: 0.0,
            currentSpeedKph: 0.0,
            status: .notRunning,
            isNightRate: false,
            isCityRate: false,
            surchargeRate: 0
        )
    }

    /// Convert to MeterState
    public func toMeterState() -> MeterState {
        return MeterState(
            currentCost: cost,
            costCounter: costCounter,
            totalDistanceMeters: totalDistanceMeters,
            totalElapsedSeconds: totalElapsedSeconds,
            currentSpeedKph: currentSpeedKph,
            status: status,
            isNightRate: isNightRate,
            isCityRate: isCityRate
        )
    }

    /// Update cost and distance with SpeedData
    /// - Drain cost counter by distance and time
    /// - Increase cost by MeterDefs.costUnit when counter reaches 0
    public func update(speedData: SpeedData, isCityRate: Bool) -> MeterCostCalculator {
        let newDistance = totalDistanceMeters + speedData.distanceDeltaMeters
        let newElapsed = totalElapsedSeconds + speedData.elapsedDeltaSeconds

        // Drain counter by distance
        let distanceDrain = Int(speedData.distanceDeltaMeters)

        // Drain counter by time when speed is below threshold (15 km/h)
        let timeDrain: Int
        if speedData.speedKph < MeterDefs.speedThresholdKph && costInfo.costTimePer > 0 {
            timeDrain = Int((Double(costInfo.costRunPer) / Double(costInfo.costTimePer)) * speedData.elapsedDeltaSeconds)
        } else {
            timeDrain = 0
        }

        // Get current hour once to maintain state consistency
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())

        // Check if night rate is enabled at current time
        let isNightRate = checkIsNightRate(hour: hour)
        let newSurchargeRate = calculateSurchargeRate(isCityRate: isCityRate, isNightRate: isNightRate, hour: hour)

        var newAccumulatedExtra = accumulatedExtraCost
        var newCounter = costCounter - distanceDrain - timeDrain

        // Increase cost by unit when counter reaches 0
        while newCounter <= 0 {
            let unitSurcharge = Int((Int64(MeterDefs.costUnit) * Int64(newSurchargeRate)) / 100)
            newAccumulatedExtra += MeterDefs.costUnit + unitSurcharge

            newCounter += costInfo.costRunPer
            if newCounter < 0 {
                newCounter = 0
            }
        }

        return MeterCostCalculator(
            costInfo: costInfo,
            accumulatedExtraCost: newAccumulatedExtra,
            costCounter: newCounter,
            totalDistanceMeters: newDistance,
            totalElapsedSeconds: newElapsed,
            currentSpeedKph: speedData.speedKph,
            status: speedData.status,
            isNightRate: isNightRate,
            isCityRate: isCityRate,
            surchargeRate: newSurchargeRate
        )
    }

    /// Update surcharge states only without draining any cost counter
    public func updateSurcharge(isCityRate: Bool) -> MeterCostCalculator {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let isNightRate = checkIsNightRate(hour: hour)
        let newSurchargeRate = calculateSurchargeRate(isCityRate: isCityRate, isNightRate: isNightRate, hour: hour)

        return MeterCostCalculator(
            costInfo: costInfo,
            accumulatedExtraCost: accumulatedExtraCost,
            costCounter: costCounter,
            totalDistanceMeters: totalDistanceMeters,
            totalElapsedSeconds: totalElapsedSeconds,
            currentSpeedKph: currentSpeedKph,
            status: status,
            isNightRate: isNightRate,
            isCityRate: isCityRate,
            surchargeRate: newSurchargeRate
        )
    }

    /// Calculate total surcharge rate based on active surcharges
    private func calculateSurchargeRate(isCityRate: Bool, isNightRate: Bool, hour: Int) -> Int {
        var surchargeRate = 0
        if isNightRate {
            surchargeRate += getNightSurchargeRate(hour: hour)
        }
        if isCityRate {
            surchargeRate += costInfo.extraRateCity
        }
        return surchargeRate
    }

    /// Get active night surcharge rate based on current hour
    private func getNightSurchargeRate(hour: Int) -> Int {
        if costInfo.isNightExtra2step {
            if isInNightRange(hour: hour, start: costInfo.nightStartHour2, end: costInfo.nightEndHour2) {
                return costInfo.extraRateNight2
            } else if isInNightRange(hour: hour, start: costInfo.nightStartHour1, end: costInfo.nightEndHour1) {
                return costInfo.extraRateNight1
            } else {
                return costInfo.extraRateNight1
            }
        } else {
            return costInfo.extraRateNight1
        }
    }

    /// Check if night rate is applicable based on current hour
    private func checkIsNightRate(hour: Int) -> Bool {
        if costInfo.isNightExtra2step {
            return isInNightRange(hour: hour, start: costInfo.nightStartHour1, end: costInfo.nightEndHour1)
                || isInNightRange(hour: hour, start: costInfo.nightStartHour2, end: costInfo.nightEndHour2)
        } else {
            return isInNightRange(hour: hour, start: costInfo.nightStartHour1, end: costInfo.nightEndHour1)
        }
    }

    /// Check if hour is in night range (handles midnight crossing e.g. 23 ~ 02)
    private func isInNightRange(hour: Int, start: Int, end: Int) -> Bool {
        if start > end {
            return hour >= start || hour < end
        } else {
            return hour >= start && hour < end
        }
    }
}
