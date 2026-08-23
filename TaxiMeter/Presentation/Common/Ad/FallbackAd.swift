//
//  FallbackAd.swift
//  TaxiMeter
//

import SwiftUI

/// Fallback advertisement model
public struct FallbackAd: Equatable, Identifiable, Sendable {
    public var id: String { title }
    public let bgColor: Color
    public let textColor: Color
    public let iconName: String
    public let title: String
    public let desc: String
    public let ctaText: String
    public let targetUrl: String?

    public init(
        bgColor: Color = .secondary,
        textColor: Color = .white,
        iconName: String = "car.fill",
        title: String = "Remove Advertisement",
        desc: String = "Enjoy clean meter screen!",
        ctaText: String = "Visit",
        targetUrl: String? = nil
    ) {
        self.bgColor = bgColor
        self.textColor = textColor
        self.iconName = iconName
        self.title = title
        self.desc = desc
        self.ctaText = ctaText
        self.targetUrl = targetUrl
    }
}
