//
//  MeterControlButton.swift
//  TaxiMeter
//

import SwiftUI

/// Standardized Reusable Meter Control Button
public struct MeterControlButton: View {
    public let text: String
    public let color: Color
    public let textColor: Color
    public let onClick: () -> Void

    public init(
        text: String,
        color: Color,
        textColor: Color = .white,
        onClick: @escaping () -> Void
    ) {
        self.text = text
        self.color = color
        self.textColor = textColor
        self.onClick = onClick
    }

    public var body: some View {
        Button(action: onClick) {
            Text(text)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color, in: Capsule())
        }
    }
}
