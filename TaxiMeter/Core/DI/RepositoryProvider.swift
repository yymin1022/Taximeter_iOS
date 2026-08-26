//
//  RepositoryProvider.swift
//  TaxiMeter
//

import Foundation

/// Provider for Repositories
public final class RepositoryProvider: @unchecked Sendable {
    public static let shared = RepositoryProvider()

    public let costRepository: CostRepository
    public let settingRepository: SettingRepository
    public let billingRepository: BillingRepository
    public let locationRepository: LocationRepository
    public let meterHistoryRepository: MeterHistoryRepository

    private init() {
        let database = DatabaseProvider.shared.taxiMeterDatabase
        let firestoreDataSource = DataSourceProvider.shared.firestoreDataSource
        let preferenceDataSource = DataSourceProvider.shared.preferenceDataSource

        self.costRepository = CostRepositoryImpl(
            database: database,
            firestoreDataSource: firestoreDataSource,
            preferenceDataSource: preferenceDataSource
        )
        self.settingRepository = SettingRepositoryImpl(
            database: database,
            preferenceDataSource: preferenceDataSource
        )
        self.billingRepository = BillingRepositoryImpl(
            preferenceDataSource: preferenceDataSource
        )
        self.locationRepository = LocationRepositoryImpl()
        self.meterHistoryRepository = MeterHistoryRepositoryImpl(
            database: database
        )
    }
}
