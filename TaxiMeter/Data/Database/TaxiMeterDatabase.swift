//
//  TaxiMeterDatabase.swift
//  TaxiMeter
//

import Foundation

/// Local Database Store for TaxiMeter Cost Info
public final class TaxiMeterDatabase: @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let storageKey = "com.yong.taximeter.database.cost_info"
    private let queue = DispatchQueue(label: "com.yong.taximeter.database", attributes: .concurrent)

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

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
}
