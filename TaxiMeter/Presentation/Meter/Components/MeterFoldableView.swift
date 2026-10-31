//
//  MeterFoldableView.swift
//  TaxiMeter
//

import SwiftUI

/// 폴더블 기기(iPhone Duo 등) 펼침 및 반열림 상태용 미터기 레이아웃 뷰
public struct MeterFoldableView: View {
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

            controlSection
                .padding(.bottom, 16)

            if !uiState.isAdRemoved {
                BannerAdView()
                    .padding(.bottom, 8)
            }
        }
    }

    private var landscapeContent: some View {
        HStack(spacing: 0) {
            VStack(alignment: .trailing, spacing: 0) {
                Spacer()

                displaySection
                    .padding(.bottom, 48)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            VStack(spacing: 0) {
                Spacer()

                infoSection
                    .padding(.vertical, 8)

                controlSection
                    .padding(.bottom, 12)

                if !uiState.isAdRemoved {
                    BannerAdView()
                        .padding(.bottom, 6)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
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

    private var controlSection: some View {
        MeterControlSection(
            isNightRate: uiState.isNightRate,
            isCityRate: uiState.isCityRate,
            onClickStart: onClickStart,
            onClickStop: onClickStop,
            onClickNightRate: onClickNightRate,
            onClickCityRate: onClickCityRate
        )
    }
}
