//
//  CostInfoMapper.swift
//  TaxiMeter
//

import Foundation

/// Cost Info Mapper
/// - DTO -> Entity
/// - Entity -> Domain Model
public enum CostInfoMapper {
    /// Map DTO -> Entity
    public static func toEntity(_ item: CostInfoItem) -> CostInfoEntity {
        let data = item.data
        return CostInfoEntity(
            region: item.region ?? "",
            costBase: data?.costBase ?? 0,
            distBase: data?.distBase ?? 0,
            costRunPer: data?.costRunPer ?? 0,
            costTimePer: data?.costTimePer ?? 0,
            extraRateCity: data?.extraRateCity ?? 0,
            extraRateNight1: data?.extraRateNight1 ?? 0,
            extraRateNight2: data?.extraRateNight2 ?? 0,
            nightStartHour1: data?.nightStartHour1 ?? 0,
            nightStartHour2: data?.nightStartHour2 ?? 0,
            nightEndHour1: data?.nightEndHour1 ?? 0,
            nightEndHour2: data?.nightEndHour2 ?? 0
        )
    }

    /// Map Entity -> Domain Model
    public static func toDomain(_ entity: CostInfoEntity) -> CostInfo {
        return CostInfo(
            region: entity.region,
            costBase: entity.costBase,
            distBase: entity.distBase,
            costRunPer: entity.costRunPer,
            costTimePer: entity.costTimePer,
            extraRateCity: entity.extraRateCity,
            extraRateNight1: entity.extraRateNight1,
            extraRateNight2: entity.extraRateNight2,
            nightStartHour1: entity.nightStartHour1,
            nightStartHour2: entity.nightStartHour2,
            nightEndHour1: entity.nightEndHour1,
            nightEndHour2: entity.nightEndHour2
        )
    }
}
