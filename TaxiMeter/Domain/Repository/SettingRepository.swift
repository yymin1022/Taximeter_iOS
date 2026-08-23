//
//  SettingRepository.swift
//  TaxiMeter
//

import Foundation

/// Setting Repository Interface
/// - Get region / theme value
/// - Set region / theme value
public protocol SettingRepository: Sendable {
    // Custom Cost
    func setCustomCostInfo(_ value: CostInfo) async

    // Region
    func getCurrentRegion() -> RegionSetting
    func setRegion(_ value: RegionSetting)

    // Theme
    func getCurrentTheme() -> ThemeSetting
    func setTheme(_ value: ThemeSetting)

    // Ad
    func isAdRemoved() -> Bool
    func setAdRemoved(_ value: Bool)

    // First Launch
    func isFirstLaunch() -> Bool
    func setFirstLaunch(_ value: Bool)
}
