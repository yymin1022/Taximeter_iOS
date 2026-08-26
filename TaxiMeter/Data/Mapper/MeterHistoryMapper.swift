//
//  MeterHistoryMapper.swift
//  TaxiMeter
//

import Foundation

/// Mapper between MeterHistory and MeterHistoryEntity
public enum MeterHistoryMapper {
    public static func toEntity(_ domain: MeterHistory) -> MeterHistoryEntity {
        return MeterHistoryEntity(
            id: domain.id,
            timestamp: domain.timestamp,
            cost: domain.cost,
            distanceMeters: domain.distanceMeters,
            elapsedSeconds: domain.elapsedSeconds
        )
    }

    public static func toDomain(_ entity: MeterHistoryEntity) -> MeterHistory {
        return MeterHistory(
            id: entity.id,
            timestamp: entity.timestamp,
            cost: entity.cost,
            distanceMeters: entity.distanceMeters,
            elapsedSeconds: entity.elapsedSeconds
        )
    }
}
