//
//  TabInfo.swift
//  TaxiMeter
//

/// Tab Info Enumeration
/// - Defines tabs for Main UI (Setting - Home - Store)
public enum TabInfo: String, CaseIterable, Identifiable {
    case setting = "Setting"
    case home = "Home"
    case store = "Store"

    public var id: String { rawValue }

    public var systemImageName: String {
        switch self {
        case .setting:
            return "gearshape.fill"
        case .home:
            return "house.fill"
        case .store:
            return "bag.fill"
        }
    }

    public var title: String {
        rawValue
    }
}
