//
//  MeterControlSection.swift
//  TaxiMeter
//

import SwiftUI

/// 미터기 조작 버튼 섹션
public struct MeterControlSection: View {
    @Environment(\.meterColors) private var meterColors

    public let isNightRate: Bool
    public let isCityRate: Bool
    public let onClickStart: () -> Void
    public let onClickStop: () -> Void
    public let onClickNightRate: () -> Void
    public let onClickCityRate: () -> Void

    public init(
        isNightRate: Bool,
        isCityRate: Bool,
        onClickStart: @escaping () -> Void,
        onClickStop: @escaping () -> Void,
        onClickNightRate: @escaping () -> Void,
        onClickCityRate: @escaping () -> Void
    ) {
        self.isNightRate = isNightRate
        self.isCityRate = isCityRate
        self.onClickStart = onClickStart
        self.onClickStop = onClickStop
        self.onClickNightRate = onClickNightRate
        self.onClickCityRate = onClickCityRate
    }

    public var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Start Button
                MeterControlButton(
                    text: "Start",
                    color: meterColors.blue,
                    textColor: meterColors.buttonText,
                    onClick: onClickStart
                )

                // Stop Button
                MeterControlButton(
                    text: "Stop",
                    color: meterColors.yellow,
                    textColor: meterColors.buttonText,
                    onClick: onClickStop
                )
            }

            HStack(spacing: 12) {
                // Night Rate Button
                MeterControlButton(
                    text: isNightRate ? "Night rate ON" : "Night rate OFF",
                    color: meterColors.green,
                    textColor: meterColors.buttonText,
                    onClick: onClickNightRate
                )

                // City Rate Button
                MeterControlButton(
                    text: isCityRate ? "City rate ON" : "City rate OFF",
                    color: meterColors.red,
                    textColor: meterColors.buttonText,
                    onClick: onClickCityRate
                )
            }
        }
        .padding(.horizontal, 16)
    }
}
