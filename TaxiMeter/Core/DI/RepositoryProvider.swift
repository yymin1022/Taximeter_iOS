//
//  RepositoryProvider.swift
//  TaxiMeter
//

import Foundation

/// Provider for Repositories
public final class RepositoryProvider {
    public static let shared = RepositoryProvider()

    public let costRepository: CostRepository

    private init() {
        self.costRepository = CostRepositoryImpl(
            database: DatabaseProvider.shared.taxiMeterDatabase,
            firestoreDataSource: DataSourceProvider.shared.firestoreDataSource,
            preferenceDataSource: DataSourceProvider.shared.preferenceDataSource
        )
    }
}
