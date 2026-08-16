//
//  CostInfo.swift
//  TaxiMeter
//

import Foundation

/// Cost Info Model
public struct CostInfo: Equatable, Sendable {
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

    public var isNightExtra2step: Bool {
        (nightStartHour1 != nightStartHour2) || (nightEndHour1 != nightEndHour2)
    }

    public init(
        region: String = "",
        costBase: Int = 4800,
        distBase: Int = 1600,
        costRunPer: Int = 131,
        costTimePer: Int = 30,
        extraRateCity: Int = 20,
        extraRateNight1: Int = 20,
        extraRateNight2: Int = 40,
        nightStartHour1: Int = 22,
        nightStartHour2: Int = 23,
        nightEndHour1: Int = 4,
        nightEndHour2: Int = 2
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
    }
}
