//
//  MeterStandardView.swift
//  TaxiMeter
//

import SwiftUI

/// 일반 기기(iPhone / iPad) 및 폴더블 커버 화면용 미터기 레이아웃 뷰
public struct MeterStandardView: View {
    public let isLandscape: Bool
    public let uiState: MeterUiState
    public let onClickStart: () -> Void
    public let onClickStop: () -> Void
    public let onClickNightRate: () -> Void
    public let onClickCityRate: () -> Void

    public init(
        isLandscape: Bool,
        uiState: MeterUiState,
        onClickStart: @escaping () -> Void,
        onClickStop: @escaping () -> Void,
        onClickNightRate: @escaping () -> Void,
        onClickCityRate: @escaping () -> Void
    ) {
        self.isLandscape = isLandscape
        self.uiState = uiState
        self.onClickStart = onClickStart
        self.onClickStop = onClickStop
        self.onClickNightRate = onClickNightRate
        self.onClickCityRate = onClickCityRate
    }

    public var body: some View {
        if isLandscape {
            landscapeContent
        } else {
            portraitContent
        }
    }

    private var portraitContent: some View {
        VStack(spacing: 0) {
            Spacer()

            displaySection

            infoSection
                .padding(.vertical, 24)

            controlSection(layout: .grid2x2)
                .padding(.bottom, 16)

            if !uiState.isAdRemoved {
                BannerAdView()
                    .padding(.bottom, 8)
            }
        }
    }

    private var landscapeContent: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .trailing, spacing: 0) {
                    Spacer()

                    displaySection
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

                VStack(spacing: 0) {
                    Spacer()

                    infoSection
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .padding(.bottom, 24)

            controlSection(layout: .horizontal1x4)
                .padding(.bottom, 12)

            if !uiState.isAdRemoved {
                BannerAdView()
                    .padding(.bottom, 6)
            }
        }
    }

    private var displaySection: some View {
        MeterDisplaySection(
            animationFrames: uiState.animationFrames,
            speedKph: uiState.meterStatus == .running ? uiState.currentSpeedKph : 0.0,
            currentCost: uiState.currentCost,
            costCounter: uiState.costCounter
        )
    }

    private var infoSection: some View {
        MeterInfoSection(
            currentSpeedKph: uiState.currentSpeedKph,
            meterStatus: uiState.meterStatus,
            totalDistanceMeters: uiState.totalDistanceMeters
        )
    }

    private func controlSection(layout: MeterControlSection.Layout) -> some View {
        MeterControlSection(
            layout: layout,
            isNightRate: uiState.isNightRate,
            isCityRate: uiState.isCityRate,
            onClickStart: onClickStart,
            onClickStop: onClickStop,
            onClickNightRate: onClickNightRate,
            onClickCityRate: onClickCityRate
        )
    }
}
