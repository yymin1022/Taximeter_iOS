//
//  ThemeSetting.swift
//  TaxiMeter
//

import Foundation

/// Theme Setting Enum
/// - key: Unique key for each theme
public enum ThemeSetting: String, CaseIterable, Identifiable, Codable, Sendable {
    case circle = "circle"
    case horse = "horse"

    public var id: String { rawValue }
    public var key: String { rawValue }

    public var displayName: String {
        switch self {
        case .circle: return "Circle"
        case .horse: return "Horse"
        }
    }
}
