//
//  PreferenceDataSource.swift
//  TaxiMeter
//

import Foundation

/// Preference Data Source
/// - Get / Set each preference values using UserDefaults
/// - Bool, Double, Int, String types are supported with strict type safety
public final class PreferenceDataSource {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Getter / Setter for Boolean value
    public func getBoolean(key: String, defaultValue: Bool) -> Bool {
        return userDefaults.object(forKey: key) as? Bool ?? defaultValue
    }

    public func setBoolean(key: String, value: Bool) {
        userDefaults.set(value, forKey: key)
    }

    /// Getter / Setter for Double value
    public func getDouble(key: String, defaultValue: Double) -> Double {
        return userDefaults.object(forKey: key) as? Double ?? defaultValue
    }

    public func setDouble(key: String, value: Double) {
        userDefaults.set(value, forKey: key)
    }

    /// Getter / Setter for Int value
    public func getInt(key: String, defaultValue: Int) -> Int {
        return userDefaults.object(forKey: key) as? Int ?? defaultValue
    }

    public func setInt(key: String, value: Int) {
        userDefaults.set(value, forKey: key)
    }

    /// Getter / Setter for String value
    public func getString(key: String, defaultValue: String) -> String {
        return userDefaults.string(forKey: key) ?? defaultValue
    }

    public func setString(key: String, value: String) {
        userDefaults.set(value, forKey: key)
    }
}
