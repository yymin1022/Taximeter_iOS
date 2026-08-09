//
//  SettingItem.swift
//  TaxiMeter
//

import Foundation

public struct SettingItem: Identifiable, Sendable, Equatable {
    public let id: String = UUID().uuidString
    public let title: String
    public let subtitle: String?
    public let onClick: (@Sendable () -> Void)?

    public init(
        title: String,
        subtitle: String? = nil,
        onClick: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.onClick = onClick
    }

    public static func == (lhs: SettingItem, rhs: SettingItem) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }
}
