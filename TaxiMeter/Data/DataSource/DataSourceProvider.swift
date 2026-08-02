//
//  DataSourceProvider.swift
//  TaxiMeter
//

import Foundation

/// Provider for DataSources
public final class DataSourceProvider {
    public static let shared = DataSourceProvider()

    public let preferenceDataSource: PreferenceDataSource = PreferenceDataSource()
    public let firestoreDataSource: FirestoreDataSource = FirestoreDataSource()

    private init() {}
}
