//
//  SettingItemGroup.swift
//  TaxiMeter
//

import Foundation

public struct SettingItemGroup: Identifiable, Sendable, Equatable {
    public let id: String = UUID().uuidString
    public let title: String
    public let items: [SettingItem]

    public init(title: String, items: [SettingItem]) {
        self.title = title
        self.items = items
    }

    public static func == (lhs: SettingItemGroup, rhs: SettingItemGroup) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.items == rhs.items
    }
}
