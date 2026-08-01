//
//  AppColor.swift
//  TaxiMeter
//

import SwiftUI

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255.0,
            green: Double((hex >> 8) & 0xff) / 255.0,
            blue: Double(hex & 0xff) / 255.0,
            opacity: alpha
        )
    }
}

public struct AppColor {
    // App UI Colors
    public static let black = Color.black
    public static let white = Color.white
    public static let blue80 = Color(hex: 0xD1E4FF)
    public static let blue40 = Color(hex: 0x0061A4)
    public static let grey10 = Color(hex: 0x1A1C1E)
    public static let grey90 = Color(hex: 0xE2E2E6)

    // Meter UI Colors
    public static let meterBackgroundDark = Color(hex: 0x111111)
    public static let meterBackgroundLight = Color(hex: 0xF0F0F0)
    public static let meterTextPrimaryDark = Color(hex: 0xEEEEEE)
    public static let meterTextPrimaryLight = Color(hex: 0x111111)
    public static let meterTextSecondaryDark = Color(hex: 0xCCCCCC)
    public static let meterTextSecondaryLight = Color(hex: 0x444444)

    // Meter Colors
    public static let meterButtonTextDark = meterBackgroundDark
    public static let meterButtonTextLight = meterBackgroundLight
    public static let meterBlueDark = Color(hex: 0x87CEEB)
    public static let meterBlueLight = Color(hex: 0x4F88D1)
    public static let meterGreenDark = Color(hex: 0x99EE90)
    public static let meterGreenLight = Color(hex: 0x66AA6A)
    public static let meterMint = Color(hex: 0x61D0BB)
    public static let meterRedDark = Color(hex: 0xDB7093)
    public static let meterRedLight = Color(hex: 0xD81B60)
    public static let meterYellowDark = Color(hex: 0xFFFFED83)
    public static let meterYellowLight = Color(hex: 0xFBA02D)
}
