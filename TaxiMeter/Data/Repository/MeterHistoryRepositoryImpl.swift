//
//  MeterHistoryRepositoryImpl.swift
//  TaxiMeter
//

import Foundation

/// Implementation of MeterHistoryRepository
public final class MeterHistoryRepositoryImpl: MeterHistoryRepository, @unchecked Sendable {
    private let database: TaxiMeterDatabase

    public init(database: TaxiMeterDatabase) {
        self.database = database
    }

    public func insertHistory(_ history: MeterHistory) async {
        let entity = MeterHistoryMapper.toEntity(history)
        database.insertMeterHistory(entity)
    }

    public func getAllHistories() -> AsyncStream<[MeterHistory]> {
        let entityStream = database.observeMeterHistories()
        return AsyncStream { continuation in
            let task = Task {
                for await entities in entityStream {
                    let domainList = entities.map { MeterHistoryMapper.toDomain($0) }
                    continuation.yield(domainList)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
