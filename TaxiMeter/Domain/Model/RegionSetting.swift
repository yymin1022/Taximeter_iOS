//
//  RegionSetting.swift
//  TaxiMeter
//

import Foundation

/// Region Setting Enum
/// - key: Unique key for each region
public enum RegionSetting: String, CaseIterable, Identifiable, Codable, Sendable {
    case seoul = "seoul"
    case gangwon = "gangwon"
    case gyeonggi = "gyeonggi"
    case gyeongbuk = "gyeongbuk"
    case gyeongnam = "gyeongnam"
    case gwangju = "gwangju"
    case daegu = "daegu"
    case daejeon = "daejeon"
    case busan = "busan"
    case ulsan = "ulsan"
    case incheon = "incheon"
    case jeonbuk = "jeonbuk"
    case jeonnam = "jeonnam"
    case jeju = "jeju"
    case chungbuk = "chungbuk"
    case chungnam = "chungnam"
    case custom = "custom"

    public var id: String { rawValue }
    public var key: String { rawValue }

    public var displayName: String {
        switch self {
        case .seoul: return "Seoul"
        case .gangwon: return "Gangwon"
        case .gyeonggi: return "Gyeonggi"
        case .gyeongbuk: return "Gyeongbuk"
        case .gyeongnam: return "Gyeongnam"
        case .gwangju: return "Gwangju"
        case .daegu: return "Daegu"
        case .daejeon: return "Daejeon"
        case .busan: return "Busan"
        case .ulsan: return "Ulsan"
        case .incheon: return "Incheon"
        case .jeonbuk: return "Jeonbuk"
        case .jeonnam: return "Jeonnam"
        case .jeju: return "Jeju"
        case .chungbuk: return "Chungbuk"
        case .chungnam: return "Chungnam"
        case .custom: return "Custom"
        }
    }
}
