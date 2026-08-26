//
//  CostInfoEntity.swift
//  TaxiMeter
//

import Foundation

/// Cost Info Entity
/// - Local Database Entity
/// - Schema aligned with Android Room 'cost_info' table
public struct CostInfoEntity: Codable, Equatable, Sendable {
    // Region Key
    public var region: String

    // Base cost info
    public var costBase: Int
    public var distBase: Int

    // Info for cost calculation
    public var costRunPer: Int
    public var costTimePer: Int

    // Extra rate info
    public var extraRateCity: Int
    public var extraRateNight1: Int
    public var extraRateNight2: Int
    public var nightStartHour1: Int
    public var nightStartHour2: Int
    public var nightEndHour1: Int
    public var nightEndHour2: Int

    // Custom flag
    public var isCustom: Bool

    public enum CodingKeys: String, CodingKey {
        case region
        case costBase = "cost_base"
        case distBase = "dist_base"
        case costRunPer = "cost_run_per"
        case costTimePer = "cost_time_per"
        case extraRateCity = "extra_rate_city"
        case extraRateNight1 = "extra_rate_night_1"
        case extraRateNight2 = "extra_rate_night_2"
        case nightStartHour1 = "night_start_hour_1"
        case nightStartHour2 = "night_start_hour_2"
        case nightEndHour1 = "night_end_hour_1"
        case nightEndHour2 = "night_end_hour_2"
        case isCustom = "is_custom"
    }

    public init(
        region: String,
        costBase: Int,
        distBase: Int,
        costRunPer: Int,
        costTimePer: Int,
        extraRateCity: Int,
        extraRateNight1: Int,
        extraRateNight2: Int,
        nightStartHour1: Int,
        nightStartHour2: Int,
        nightEndHour1: Int,
        nightEndHour2: Int,
        isCustom: Bool = false
    ) {
        self.region = region
        self.costBase = costBase
        self.distBase = distBase
        self.costRunPer = costRunPer
        self.costTimePer = costTimePer
        self.extraRateCity = extraRateCity
        self.extraRateNight1 = extraRateNight1
        self.extraRateNight2 = extraRateNight2
        self.nightStartHour1 = nightStartHour1
        self.nightStartHour2 = nightStartHour2
        self.nightEndHour1 = nightEndHour1
        self.nightEndHour2 = nightEndHour2
        self.isCustom = isCustom
    }
}
