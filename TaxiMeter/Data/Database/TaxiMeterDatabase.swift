//
//  TaxiMeterDatabase.swift
//  TaxiMeter
//

import Foundation

/// Local Database Store for TaxiMeter Cost Info and Meter History
public final class TaxiMeterDatabase: @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let storageKey = "com.yong.taximeter.database.cost_info"
    private let historyStorageKey = "com.yong.taximeter.database.meter_history"
    private let queue = DispatchQueue(label: "com.yong.taximeter.database", attributes: .concurrent)

    private var historyContinuations: [UUID: AsyncStream<[MeterHistoryEntity]>.Continuation] = [:]
    private let historyLock = NSLock()

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Cost Info Database

    /// Get CostInfoEntity by region key
    public func getByRegion(_ regionKey: String) -> CostInfoEntity? {
        queue.sync {
            let entities = loadEntities()
            return entities.first { $0.region == regionKey }
        }
    }

    /// Insert custom cost entity (isCustom = true)
    public func insertCustomCost(_ cost: CostInfoEntity) {
        queue.sync(flags: .barrier) {
            var entities = self.loadEntities()
            if let index = entities.firstIndex(where: { $0.region == cost.region }) {
                entities[index] = cost
            } else {
                entities.append(cost)
            }
            self.saveEntities(entities)
        }
    }

    /// Insert or update list of cost entities (synchronous barrier write)
    public func insertAll(_ costs: [CostInfoEntity]) {
        queue.sync(flags: .barrier) {
            var entities = self.loadEntities()
            for cost in costs {
                if let index = entities.firstIndex(where: { $0.region == cost.region }) {
                    entities[index] = cost
                } else {
                    entities.append(cost)
                }
            }
            self.saveEntities(entities)
        }
    }

    /// Delete all remote cost entities (isCustom == false) (synchronous barrier write)
    public func deleteAllRemoteCost() {
        queue.sync(flags: .barrier) {
            var entities = self.loadEntities()
            entities.removeAll(where: { !$0.isCustom })
            self.saveEntities(entities)
        }
    }

    /// Update remote cost list (synchronous barrier write guarantees completion before returning)
    public func updateRemoteCost(_ costs: [CostInfoEntity]) {
        queue.sync(flags: .barrier) {
            var entities = self.loadEntities()
            entities.removeAll(where: { !$0.isCustom })
            for cost in costs {
                if let index = entities.firstIndex(where: { $0.region == cost.region }) {
                    entities[index] = cost
                } else {
                    entities.append(cost)
                }
            }
            self.saveEntities(entities)
        }
    }

    private func loadEntities() -> [CostInfoEntity] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([CostInfoEntity].self, from: data)) ?? []
    }

    private func saveEntities(_ entities: [CostInfoEntity]) {
        if let encoded = try? JSONEncoder().encode(entities) {
            userDefaults.set(encoded, forKey: storageKey)
        }
    }

    // MARK: - Meter History Database

    /// Insert meter history entity
    public func insertMeterHistory(_ history: MeterHistoryEntity) {
        queue.sync(flags: .barrier) {
            var entities = self.loadHistoryEntities()
            let newId = (entities.map { $0.id }.max() ?? 0) + 1
            let entityWithId = MeterHistoryEntity(
                id: history.id > 0 ? history.id : newId,
                timestamp: history.timestamp,
                cost: history.cost,
                distanceMeters: history.distanceMeters,
                elapsedSeconds: history.elapsedSeconds
            )
            entities.append(entityWithId)
            self.saveHistoryEntities(entities)
            self.notifyHistoryObservers(entities)
        }
    }

    /// Get all meter histories ordered by timestamp descending
    public func getAllMeterHistories() -> [MeterHistoryEntity] {
        queue.sync {
            let entities = loadHistoryEntities()
            return entities.sorted(by: { $0.timestamp > $1.timestamp })
        }
    }

    /// Observe all meter histories
    public func observeMeterHistories() -> AsyncStream<[MeterHistoryEntity]> {
        let id = UUID()
        return AsyncStream { continuation in
            historyLock.lock()
            historyContinuations[id] = continuation
            historyLock.unlock()

            continuation.yield(getAllMeterHistories())

            continuation.onTermination = { [weak self] _ in
                guard let self = self else { return }
                self.historyLock.lock()
                self.historyContinuations.removeValue(forKey: id)
                self.historyLock.unlock()
            }
        }
    }

    private func notifyHistoryObservers(_ entities: [MeterHistoryEntity]) {
        let sorted = entities.sorted(by: { $0.timestamp > $1.timestamp })
        historyLock.lock()
        let continuations = Array(historyContinuations.values)
        historyLock.unlock()
        for continuation in continuations {
            continuation.yield(sorted)
        }
    }

    private func loadHistoryEntities() -> [MeterHistoryEntity] {
        guard let data = userDefaults.data(forKey: historyStorageKey) else { return [] }
        return (try? JSONDecoder().decode([MeterHistoryEntity].self, from: data)) ?? []
    }

    private func saveHistoryEntities(_ entities: [MeterHistoryEntity]) {
        if let encoded = try? JSONEncoder().encode(entities) {
            userDefaults.set(encoded, forKey: historyStorageKey)
        }
    }
}
