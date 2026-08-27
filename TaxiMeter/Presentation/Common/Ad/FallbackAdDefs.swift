//
//  FallbackAdDefs.swift
//  TaxiMeter
//

import SwiftUI

/// Utility object managing fallback ad definitions and rotation logic
public enum FallbackAdDefs {
    public static let fallbackAdRotationIntervalMs: UInt64 = 15_000

    public static let fallbackAdDefaultColor = Color.secondary
    public static let fallbackAdDefaultTextColor = Color.white
    public static let fallbackAdDefaultIcon = "car.fill"
    public static let fallbackAdDefaultTitle = "Remove Advertisement"
    public static let fallbackAdDefaultDesc = "Enjoy clean meter screen!"

    public static let defaultAd = FallbackAd(
        bgColor: fallbackAdDefaultColor,
        textColor: fallbackAdDefaultTextColor,
        iconName: fallbackAdDefaultIcon,
        title: fallbackAdDefaultTitle,
        desc: fallbackAdDefaultDesc
    )

    public static let blogAd = FallbackAd(
        bgColor: Color(red: 16 / 255.0, green: 61 / 255.0, blue: 136 / 255.0),
        textColor: .white,
        iconName: "ic_blog_icon",
        title: "Useful Blog",
        desc: "Developer Useful's IT Blog",
        targetUrl: "https://useful-min.dev"
    )

    public static let typerAd = FallbackAd(
        bgColor: Color(red: 252 / 255.0, green: 242 / 255.0, blue: 217 / 255.0),
        textColor: .black,
        iconName: "ic_typer",
        title: "Typer: ASMR Keyboard Smash",
        desc: "Keyboard ASMR & Brick Breaker",
        targetUrl: "https://apps.apple.com/kr/app/typer-asmr-keyboard-smash/id6753107938?utm_source=useful_taximeter&utm_campaign=typer_crosspromo_banner"
    )

    public static var fallbackAdList: [FallbackAd] = [
        defaultAd,
        blogAd,
        typerAd
    ]

    /// Get a random ad from fallbackAdList, optionally excluding the currently displayed ad
    public static func getRandomAd(except: FallbackAd? = nil) -> FallbackAd {
        if fallbackAdList.isEmpty { return defaultAd }
        let candidates = fallbackAdList.filter { $0 != except }
        if candidates.isEmpty {
            return fallbackAdList.first ?? defaultAd
        }
        return candidates.randomElement() ?? defaultAd
    }
}
