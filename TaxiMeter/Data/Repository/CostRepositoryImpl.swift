//
//  CostRepositoryImpl.swift
//  TaxiMeter
//

import Foundation

public final class CostRepositoryImpl: CostRepository, @unchecked Sendable {
    private let database: TaxiMeterDatabase
    private let firestoreDataSource: FirestoreDataSource
    private let preferenceDataSource: PreferenceDataSource

    private static let firestoreCollectionKeyCost = "cost"
    private static let firestoreDocumentKeyInfo = "info"
    private static let firestoreDocumentKeyVersion = "version"

    public init(
        database: TaxiMeterDatabase,
        firestoreDataSource: FirestoreDataSource,
        preferenceDataSource: PreferenceDataSource
    ) {
        self.database = database
        self.firestoreDataSource = firestoreDataSource
        self.preferenceDataSource = preferenceDataSource
    }

    /// Get local cost version from Preference (returns empty string if not set yet)
    public func getLocalVersion() -> String {
        return preferenceDataSource.getString(
            key: PreferenceDefs.prefKeyCostVersion,
            defaultValue: ""
        )
    }

    /// Get remote cost version from Firestore
    public func getRemoteVersion() async -> String? {
        let versionDto = await firestoreDataSource.getDocument(
            collection: Self.firestoreCollectionKeyCost,
            document: Self.firestoreDocumentKeyVersion,
            as: CostVersionDTO.self
        )
        return versionDto?.version
    }

    /// Get remote cost version from Firestore and update local cost info
    public func updateToLatest() async -> Bool {
        let costListDto = await firestoreDataSource.getDocument(
            collection: Self.firestoreCollectionKeyCost,
            document: Self.firestoreDocumentKeyInfo,
            as: CostInfoDTO.self
        )

        guard let data = costListDto?.data, !data.isEmpty else { return false }

        // Filter out invalid items (missing region key or data)
        let validItems = data.filter { item in
            guard let region = item.region, !region.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return false
            }
            return item.data != nil
        }

        guard !validItems.isEmpty else { return false }

        // Convert DTO to entity and update local DB
        let costEntityList = validItems.map { CostInfoMapper.toEntity($0) }
        database.updateRemoteCost(costEntityList)

        // Only update local cost version if a valid remote version was fetched
        if let remoteVersion = await getRemoteVersion() {
            preferenceDataSource.setString(key: PreferenceDefs.prefKeyCostVersion, value: remoteVersion)
        }

        return true
    }

    /// Get cost info for specific region (returns default fallback for custom if not saved yet)
    public func getCostInfo(regionKey: String) -> CostInfo? {
        if let entity = database.getByRegion(regionKey) {
            return CostInfoMapper.toDomain(entity)
        }

        // Default fallback for custom region when no custom cost has been saved yet
        if regionKey == RegionSetting.custom.rawValue {
            return CostInfo(
                region: RegionSetting.custom.rawValue,
                costBase: 4800,
                distBase: 1600,
                costRunPer: 131,
                costTimePer: 30,
                extraRateCity: 20,
                extraRateNight1: 20,
                extraRateNight2: 40,
                nightStartHour1: 22,
                nightStartHour2: 23,
                nightEndHour1: 4,
                nightEndHour2: 2
            )
        }

        return nil
    }
}
