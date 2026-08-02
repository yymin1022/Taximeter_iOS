//
//  DatabaseProvider.swift
//  TaxiMeter
//

import Foundation

/// Provider for Local Database
public final class DatabaseProvider {
    public static let shared = DatabaseProvider()

    public let taxiMeterDatabase: TaxiMeterDatabase = TaxiMeterDatabase()

    private init() {}
}
