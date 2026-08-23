//
//  SettingRepositoryImpl.swift
//  TaxiMeter
//

import Foundation

public final class SettingRepositoryImpl: SettingRepository, @unchecked Sendable {
    private let database: TaxiMeterDatabase
    private let preferenceDataSource: PreferenceDataSource

    private static let prefKeySettingRegion = "PREF_KEY_SETTING_REGION"
    private static let prefKeySettingTheme = "PREF_KEY_SETTING_THEME"

    private static let defaultRegion = RegionSetting.seoul
    private static let defaultTheme = ThemeSetting.horse

    public init(
        database: TaxiMeterDatabase,
        preferenceDataSource: PreferenceDataSource
    ) {
        self.database = database
        self.preferenceDataSource = preferenceDataSource
    }

    /// Save custom cost info into local DB
    public func setCustomCostInfo(_ value: CostInfo) async {
        let costEntity = CostInfoMapper.toEntity(value)
        database.insertCustomCost(costEntity)
    }

    /// Get current region setting from Preference
    public func getCurrentRegion() -> RegionSetting {
        let regionKey = preferenceDataSource.getString(
            key: Self.prefKeySettingRegion,
            defaultValue: Self.defaultRegion.key
        )
        return RegionSetting.allCases.first(where: { $0.key == regionKey }) ?? Self.defaultRegion
    }

    /// Set region setting into Preference
    public func setRegion(_ value: RegionSetting) {
        preferenceDataSource.setString(key: Self.prefKeySettingRegion, value: value.key)
    }

    /// Get current theme setting from Preference
    public func getCurrentTheme() -> ThemeSetting {
        let themeKey = preferenceDataSource.getString(
            key: Self.prefKeySettingTheme,
            defaultValue: Self.defaultTheme.key
        )
        return ThemeSetting.allCases.first(where: { $0.key == themeKey }) ?? Self.defaultTheme
    }

    /// Set theme setting into Preference
    public func setTheme(_ value: ThemeSetting) {
        preferenceDataSource.setString(key: Self.prefKeySettingTheme, value: value.key)
    }

    /// Get ad removal status from Preference
    public func isAdRemoved() -> Bool {
        return preferenceDataSource.getBoolean(
            key: PreferenceDefs.prefKeyAdRemove,
            defaultValue: false
        )
    }

    /// Set ad removal status into Preference
    public func setAdRemoved(_ value: Bool) {
        preferenceDataSource.setBoolean(
            key: PreferenceDefs.prefKeyAdRemove,
            value: value
        )
    }
}
