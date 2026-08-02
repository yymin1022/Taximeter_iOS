//
//  CostInfoDTO.swift
//  TaxiMeter
//

import Foundation

/// Cost Info DTO
/// - Firebase Firestore -> DTO
public struct CostInfoDTO: Decodable, Sendable {
    public let data: [CostInfoItem]?

    public init(data: [CostInfoItem]? = nil) {
        self.data = data
    }
}

public struct CostInfoItem: Decodable, Sendable {
    // Region Key
    public let region: String?

    // Cost Info Data
    public let data: CostInfoData?

    public init(region: String? = nil, data: CostInfoData? = nil) {
        self.region = region
        self.data = data
    }
}

public struct CostInfoData: Decodable, Sendable {
    // Base cost info
    public let costBase: Int?
    public let distBase: Int?

    // Info for cost calculation
    public let costRunPer: Int?
    public let costTimePer: Int?

    // Extra rate info
    public let extraRateCity: Int?
    public let extraRateNight1: Int?
    public let extraRateNight2: Int?
    public let nightStartHour1: Int?
    public let nightStartHour2: Int?
    public let nightEndHour1: Int?
    public let nightEndHour2: Int?

    public init(
        costBase: Int? = 0,
        distBase: Int? = 0,
        costRunPer: Int? = 0,
        costTimePer: Int? = 0,
        extraRateCity: Int? = 0,
        extraRateNight1: Int? = 0,
        extraRateNight2: Int? = 0,
        nightStartHour1: Int? = 0,
        nightStartHour2: Int? = 0,
        nightEndHour1: Int? = 0,
        nightEndHour2: Int? = 0
    ) {
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
