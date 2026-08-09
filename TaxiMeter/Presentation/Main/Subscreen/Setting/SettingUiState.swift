//
//  SettingUiState.swift
//  TaxiMeter
//

import Foundation

public struct SettingUiState: Equatable {
    public var settingGroups: [SettingItemGroup]
    public var showDialog: ShowDialog
    public var openUrlRequest: URL?

    public init(
        settingGroups: [SettingItemGroup] = [],
        showDialog: ShowDialog = .nothing,
        openUrlRequest: URL? = nil
    ) {
        self.settingGroups = settingGroups
        self.showDialog = showDialog
        self.openUrlRequest = openUrlRequest
    }
}
