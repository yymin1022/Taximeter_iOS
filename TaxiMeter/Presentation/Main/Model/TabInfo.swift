//
//  TabInfo.swift
//  TaxiMeter
//

/// Tab Info Enumeration
/// - Defines tabs for Main UI (Home - History - Store - Setting)
public enum TabInfo: String, CaseIterable, Identifiable {
    case home = "Home"
    case history = "History"
    case store = "Store"
    case setting = "Setting"

    public var id: String { rawValue }

    public var systemImageName: String {
        switch self {
        case .home:
            return "house.fill"
        case .history:
            return "clock.arrow.circlepath"
        case .store:
            return "bag.fill"
        case .setting:
            return "gearshape.fill"
        }
    }

    public var title: String {
        rawValue
    }
}
