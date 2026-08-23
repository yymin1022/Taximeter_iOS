//
//  FallbackAdContent.swift
//  TaxiMeter
//

import SwiftUI

/// Fallback advertisement content view with tap-to-open URL
public struct FallbackAdContent: View {
    public let fallbackAd: FallbackAd

    public init(fallbackAd: FallbackAd) {
        self.fallbackAd = fallbackAd
    }

    public var body: some View {
        Button {
            if let targetUrl = fallbackAd.targetUrl, let url = URL(string: targetUrl) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                // Icon (System symbol or named asset)
                Group {
                    if UIImage(named: fallbackAd.iconName) != nil {
                        Image(fallbackAd.iconName)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: fallbackAd.iconName)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 32, height: 32)
                .accessibilityLabel("Fallback Ad Icon")

                // Title & Description
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(fallbackAd.title))
                        .font(.footnote.weight(.bold))
                        .foregroundColor(fallbackAd.textColor)
                        .lineLimit(1)

                    Text(LocalizedStringKey(fallbackAd.desc))
                        .font(.caption2)
                        .foregroundColor(fallbackAd.textColor.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer()

                // CTA Text
                if fallbackAd.targetUrl != nil {
                    Text(LocalizedStringKey(fallbackAd.ctaText))
                        .font(.caption.weight(.bold))
                        .foregroundColor(fallbackAd.textColor)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(fallbackAd.bgColor)
        }
        .buttonStyle(.plain)
    }
}
