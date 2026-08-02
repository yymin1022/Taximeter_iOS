//
//  CostInfoEntity.swift
//  TaxiMeter
//

import Foundation

/// Cost Info Entity
/// - Local Database Entity
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
