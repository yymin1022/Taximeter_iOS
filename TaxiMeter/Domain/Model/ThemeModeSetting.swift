//
//  ThemeModeSetting.swift
//  TaxiMeter
//

import Foundation

/// App UI Theme Mode Setting Enum
public enum ThemeModeSetting: String, CaseIterable, Identifiable, Codable, Sendable {
    case system = "system"
    case dark = "dark"
    case light = "light"

    public var id: String { rawValue }
    public var key: String { rawValue }

    public var displayName: String {
        switch self {
        case .system: return "System default"
        case .dark: return "Dark theme"
        case .light: return "Light theme"
        }
    }
}
