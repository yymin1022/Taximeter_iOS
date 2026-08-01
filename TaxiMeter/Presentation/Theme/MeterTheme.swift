//
//  MeterTheme.swift
//  TaxiMeter
//

import SwiftUI

public struct MeterColors {
    public let buttonText: Color
    public let blue: Color
    public let green: Color
    public let mint: Color
    public let red: Color
    public let yellow: Color
    public let background: Color
    public let onBackground: Color

    public static func colors(isDark: Bool = false) -> MeterColors {
        if isDark {
            return MeterColors(
                buttonText: AppColor.meterButtonTextDark,
                blue: AppColor.meterBlueDark,
                green: AppColor.meterGreenDark,
                mint: AppColor.meterMint,
                red: AppColor.meterRedDark,
                yellow: AppColor.meterYellowDark,
                background: AppColor.meterBackgroundDark,
                onBackground: AppColor.meterTextPrimaryDark
            )
        } else {
            return MeterColors(
                buttonText: AppColor.meterButtonTextLight,
                blue: AppColor.meterBlueLight,
                green: AppColor.meterGreenLight,
                mint: AppColor.meterMint,
                red: AppColor.meterRedLight,
                yellow: AppColor.meterYellowLight,
                background: AppColor.meterBackgroundLight,
                onBackground: AppColor.meterTextPrimaryLight
            )
        }
    }
}

private struct MeterColorsKey: EnvironmentKey {
    static let defaultValue: MeterColors = MeterColors.colors(isDark: false)
}

public extension EnvironmentValues {
    var meterColors: MeterColors {
        get { self[MeterColorsKey.self] }
        set { self[MeterColorsKey.self] = newValue }
    }
}

public struct MeterThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        let meterColors = MeterColors.colors(isDark: isDark)
        content
            .environment(\.meterColors, meterColors)
    }
}

public extension View {
    func meterTheme() -> some View {
        self.modifier(MeterThemeModifier())
    }
}
