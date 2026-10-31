//
//  MeterControlSection.swift
//  TaxiMeter
//

import SwiftUI

/// 미터기 조작 버튼 섹션
public struct MeterControlSection: View {
    public enum Layout {
        case grid2x2
        case horizontal1x4
    }

    @Environment(\.meterColors) private var meterColors

    public let layout: Layout
    public let isNightRate: Bool
    public let isCityRate: Bool
    public let onClickStart: () -> Void
    public let onClickStop: () -> Void
    public let onClickNightRate: () -> Void
    public let onClickCityRate: () -> Void

    public init(
        layout: Layout = .grid2x2,
        isNightRate: Bool,
        isCityRate: Bool,
        onClickStart: @escaping () -> Void,
        onClickStop: @escaping () -> Void,
        onClickNightRate: @escaping () -> Void,
        onClickCityRate: @escaping () -> Void
    ) {
        self.layout = layout
        self.isNightRate = isNightRate
        self.isCityRate = isCityRate
        self.onClickStart = onClickStart
        self.onClickStop = onClickStop
        self.onClickNightRate = onClickNightRate
        self.onClickCityRate = onClickCityRate
    }

    public var body: some View {
        Group {
            switch layout {
            case .grid2x2:
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        startButton
                        stopButton
                    }

                    HStack(spacing: 12) {
                        nightRateButton
                        cityRateButton
                    }
                }
            case .horizontal1x4:
                HStack(spacing: 12) {
                    startButton
                    stopButton
                    nightRateButton
                    cityRateButton
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var startButton: some View {
        MeterControlButton(
            text: "Start",
            color: meterColors.blue,
            textColor: meterColors.buttonText,
            onClick: onClickStart
        )
    }

    private var stopButton: some View {
        MeterControlButton(
            text: "Stop",
            color: meterColors.yellow,
            textColor: meterColors.buttonText,
            onClick: onClickStop
        )
    }

    private var nightRateButton: some View {
        MeterControlButton(
            text: isNightRate ? "Night rate ON" : "Night rate OFF",
            color: meterColors.green,
            textColor: meterColors.buttonText,
            onClick: onClickNightRate
        )
    }

    private var cityRateButton: some View {
        MeterControlButton(
            text: isCityRate ? "City rate ON" : "City rate OFF",
            color: meterColors.red,
            textColor: meterColors.buttonText,
            onClick: onClickCityRate
        )
    }
}
