//
//  SettingViewModel.swift
//  TaxiMeter
//

import Combine
import Foundation
import SwiftUI

public final class SettingViewModel: ObservableObject {
    @Published public var uiState: SettingUiState = SettingUiState()

    private let costRepository: CostRepository
    private let settingRepository: SettingRepository

    private static let urlDeveloperBlog = "https://useful-min.dev"
    private static let urlDeveloperGithub = "https://github.com/yymin1022"
    private static let urlDeveloperLinkedin = "https://linkedin.com/in/yymin1022"
    private static let urlPrivacyPolicy = "https://defcon.or.kr/privacy"

    public init(
        costRepository: CostRepository = RepositoryProvider.shared.costRepository,
        settingRepository: SettingRepository = RepositoryProvider.shared.settingRepository
    ) {
        self.costRepository = costRepository
        self.settingRepository = settingRepository
        loadSettingGroups()
    }

    /// Load all setting groups
    public func loadSettingGroups() {
        var groups: [SettingItemGroup] = []

        // 1. Meter Setting Group
        groups.append(loadMeterSettingGroup())

        // 2. Cost Info Setting Group
        groups.append(loadCostInfoSettingGroup())

        // 3. Developer Info Setting Group
        groups.append(loadDeveloperInfoSettingGroup())

        uiState.isAdRemoved = settingRepository.isAdRemoved()
        uiState.settingGroups = groups
    }

    /// Dismiss current dialog
    public func dismissDialog() {
        uiState.showDialog = .nothing
    }

    /// Clear open URL request
    public func clearOpenUrlRequest() {
        uiState.openUrlRequest = nil
    }

    // MARK: - Meter Setting Group
    private func loadMeterSettingGroup() -> SettingItemGroup {
        let currentRegion = settingRepository.getCurrentRegion()
        let curRegionText = currentRegion.displayName
        let curThemeText = settingRepository.getCurrentTheme().displayName
        let curThemeModeText = settingRepository.getThemeMode().displayName

        return SettingItemGroup(
            title: "Meter Setting",
            items: [
                SettingItem(
                    title: "Region",
                    subtitle: curRegionText,
                    onClick: { [weak self] in self?.onClickRegionSettingItem() }
                ),
                SettingItem(
                    title: "Meter Type",
                    subtitle: curThemeText,
                    onClick: { [weak self] in self?.onClickThemeSettingItem() }
                ),
                SettingItem(
                    title: "App Theme",
                    subtitle: curThemeModeText,
                    onClick: { [weak self] in self?.onClickThemeModeSettingItem() }
                )
            ]
        )
    }

    private func onClickRegionSettingItem() {
        let items = RegionSetting.allCases.map { $0.displayName }
        let currentRegion = settingRepository.getCurrentRegion()
        let selectedIndex = RegionSetting.allCases.firstIndex(of: currentRegion) ?? 0

        uiState.showDialog = .radioSelectDialog(
            title: "Select region",
            items: items,
            selectedIndex: selectedIndex,
            onComplete: { [weak self] idx in
                self?.onCompleteRegionSetting(idx)
            }
        )
    }

    private func onCompleteRegionSetting(_ idx: Int) {
        guard idx >= 0 && idx < RegionSetting.allCases.count else { return }
        let selectedRegion = RegionSetting.allCases[idx]
        settingRepository.setRegion(selectedRegion)
        loadSettingGroups()
        dismissDialog()
    }

    private func onClickCustomCostSettingItem() {
        uiState.showDialog = .customCostDialog(
            title: "Set custom cost",
            onComplete: { [weak self] costInfo in
                self?.onCompleteCustomCostSetting(costInfo)
            }
        )
    }

    private func onCompleteCustomCostSetting(_ costInfo: CostInfo) {
        Task { @MainActor in
            await settingRepository.setCustomCostInfo(costInfo)
            settingRepository.setRegion(.custom)
            loadSettingGroups()
            dismissDialog()
        }
    }

    private func onClickThemeSettingItem() {
        let items = ThemeSetting.allCases.map { $0.displayName }
        let currentTheme = settingRepository.getCurrentTheme()
        let selectedIndex = ThemeSetting.allCases.firstIndex(of: currentTheme) ?? 0

        uiState.showDialog = .radioSelectDialog(
            title: "Select Meter Type",
            items: items,
            selectedIndex: selectedIndex,
            onComplete: { [weak self] idx in
                self?.onCompleteThemeSetting(idx)
            }
        )
    }

    private func onCompleteThemeSetting(_ idx: Int) {
        guard idx >= 0 && idx < ThemeSetting.allCases.count else { return }
        let selectedTheme = ThemeSetting.allCases[idx]
        settingRepository.setTheme(selectedTheme)
        loadSettingGroups()
        dismissDialog()
    }

    private func onClickThemeModeSettingItem() {
        let items = ThemeModeSetting.allCases.map { $0.displayName }
        let currentMode = settingRepository.getThemeMode()
        let selectedIndex = ThemeModeSetting.allCases.firstIndex(of: currentMode) ?? 0

        uiState.showDialog = .radioSelectDialog(
            title: "Select App Theme",
            items: items,
            selectedIndex: selectedIndex,
            onComplete: { [weak self] idx in
                self?.onCompleteThemeModeSetting(idx)
            }
        )
    }

    private func onCompleteThemeModeSetting(_ idx: Int) {
        guard idx >= 0 && idx < ThemeModeSetting.allCases.count else { return }
        let selectedMode = ThemeModeSetting.allCases[idx]
        settingRepository.setThemeMode(selectedMode)
        loadSettingGroups()
        dismissDialog()
    }

    // MARK: - Cost Info Setting Group
    private func loadCostInfoSettingGroup() -> SettingItemGroup {
        let currentRegion = settingRepository.getCurrentRegion()
        let costInfo = costRepository.getCostInfo(regionKey: currentRegion.rawValue)

        var items: [SettingItem] = []

        // 1. Cost Info Item
        var subtitleText = ""
        if let info = costInfo {
            let distKm = Double(info.distBase) / 1000.0
            let formatKey = info.isNightExtra2step ? "setting_content_cost_info_format_step2" : "setting_content_cost_info_format"
            let format = NSLocalizedString(formatKey, comment: "")
            if format != formatKey {
                if info.isNightExtra2step {
                    subtitleText = String(
                        format: format,
                        formattedNumber(info.costBase), String(format: "%.1f", distKm),
                        formattedNumber(info.costRunPer), formattedNumber(info.costTimePer),
                        formattedNumber(info.extraRateCity),
                        formattedNumber(info.extraRateNight1), info.nightStartHour1, info.nightEndHour1,
                        formattedNumber(info.extraRateNight2), info.nightStartHour2, info.nightEndHour2
                    )
                } else {
                    subtitleText = String(
                        format: format,
                        formattedNumber(info.costBase), String(format: "%.1f", distKm),
                        formattedNumber(info.costRunPer), formattedNumber(info.costTimePer),
                        formattedNumber(info.extraRateCity),
                        formattedNumber(info.extraRateNight1), info.nightStartHour1, info.nightEndHour1
                    )
                }
            } else {
                subtitleText = String(
                    format: "Base: KRW %d (First %.1fkm)\nDistance cost: KRW 100 per %d meters\nTime cost: KRW 100 per %d seconds\nOut city extra: %d%%\nNight extra\n- %d%% (%02d:00 ~ %02d:00)",
                    info.costBase, distKm, info.costRunPer, info.costTimePer, info.extraRateCity,
                    info.extraRateNight1, info.nightStartHour1, info.nightEndHour1
                )
            }

            items.append(
                SettingItem(
                    title: "Cost Info",
                    subtitle: subtitleText.isEmpty ? nil : subtitleText
                )
            )
        }

        // 2. Set Custom Cost Item
        let isCustom = (currentRegion == .custom)
        items.append(
            SettingItem(
                title: "Set custom cost parameter",
                subtitle: isCustom ? "Setup your own cost values" : "To use, set region as custom",
                onClick: isCustom ? { [weak self] in self?.onClickCustomCostSettingItem() } : nil
            )
        )

        // 3. Cost DB Version Item
        let curCostVersion = costRepository.getLocalVersion()
        items.append(
            SettingItem(
                title: "Cost DB Version",
                subtitle: curCostVersion.isEmpty ? nil : curCostVersion
            )
        )

        return SettingItemGroup(
            title: "Cost Info",
            items: items
        )
    }

    // MARK: - Developer Info Setting Group
    private func loadDeveloperInfoSettingGroup() -> SettingItemGroup {
        return SettingItemGroup(
            title: "Developer Info",
            items: [
                SettingItem(
                    title: "Useful",
                    subtitle: "Chung-Ang University Dept. Software (2019 ~ 2025)"
                ),
                SettingItem(
                    title: "Developer's Blog",
                    subtitle: Self.urlDeveloperBlog,
                    onClick: { [weak self] in self?.sendOpenUrlRequest(Self.urlDeveloperBlog) }
                ),
                SettingItem(
                    title: "Developer's GitHub",
                    subtitle: Self.urlDeveloperGithub,
                    onClick: { [weak self] in self?.sendOpenUrlRequest(Self.urlDeveloperGithub) }
                ),
                SettingItem(
                    title: "Developer's LinkedIn",
                    subtitle: Self.urlDeveloperLinkedin,
                    onClick: { [weak self] in self?.sendOpenUrlRequest(Self.urlDeveloperLinkedin) }
                ),
                SettingItem(
                    title: "Privacy Policy",
                    subtitle: Self.urlPrivacyPolicy,
                    onClick: { [weak self] in self?.sendOpenUrlRequest(Self.urlPrivacyPolicy) }
                )
            ]
        )
    }

    private func sendOpenUrlRequest(_ urlString: String) {
        if let url = URL(string: urlString) {
            uiState.openUrlRequest = url
        }
    }

    private func formattedNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }
}
