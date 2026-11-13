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
        GeometryReader { geometry in
            let hingeRect = divisionFrame(in: geometry)

            if isVerticalHinge(hingeRect: hingeRect) {
                landscapeContent(in: geometry, hingeRect: hingeRect)
            } else {
                portraitContent(in: geometry, hingeRect: hingeRect)
            }
        }
        .ignoresSafeArea(.container, edges: .horizontal)
    }

    /// 가로 힌지 기준 상/하 분할 (각 영역의 하단에 배치)
    @ViewBuilder
    private func portraitContent(in geometry: GeometryProxy, hingeRect: CGRect?) -> some View {
        if let hingeRect {
            let topHeight = max(0, hingeRect.minY)
            let hingeHeight = max(0, hingeRect.height)
            let bottomHeight = max(0, geometry.size.height - hingeRect.maxY)

            VStack(spacing: 0) {
                VStack(alignment: .trailing, spacing: 0) {
                    Spacer()

                    displaySection
                        .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: topHeight, alignment: .bottomTrailing)

                Spacer()
                    .frame(height: hingeHeight)

                VStack(spacing: 0) {
                    Spacer()

                    infoSection
                        .padding(.vertical, 24)

                    controlSection(layout: .grid2x2)
                        .padding(.bottom, 16)

                    if !uiState.isAdRemoved {
                        BannerAdView()
                            .padding(.bottom, 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: bottomHeight, alignment: .bottom)
            }
        } else {
            VStack(spacing: 0) {
                VStack(alignment: .trailing, spacing: 0) {
                    Spacer()

                    displaySection
                        .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

                VStack(spacing: 0) {
                    Spacer()

                    infoSection
                        .padding(.vertical, 24)

                    controlSection(layout: .grid2x2)
                        .padding(.bottom, 16)

                    if !uiState.isAdRemoved {
                        BannerAdView()
                            .padding(.bottom, 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
    }

    /// 세로 힌지 기준 좌/우 분할 + 하단 1x4 컨트롤 배치
    @ViewBuilder
    private func landscapeContent(in geometry: GeometryProxy, hingeRect: CGRect?) -> some View {
        VStack(spacing: 0) {
            if let hingeRect {
                let leftWidth = max(0, hingeRect.minX)
                let hingeWidth = max(0, hingeRect.width)
                let rightWidth = max(0, geometry.size.width - hingeRect.maxX)

                HStack(alignment: .bottom, spacing: 0) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Spacer()

                        displaySection
                    }
                    .frame(width: leftWidth)
                    .frame(maxHeight: .infinity, alignment: .bottomTrailing)

                    Spacer()
                        .frame(width: hingeWidth)

                    VStack(spacing: 0) {
                        Spacer()

                        infoSection
                    }
                    .frame(width: rightWidth)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .padding(.bottom, 12)
            } else {
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
                .padding(.bottom, 12)
            }

            controlSection(layout: .horizontal1x4)
                .padding(.bottom, 8)

            if !uiState.isAdRemoved {
                BannerAdView()
                    .padding(.bottom, 2)
                    .layoutPriority(1)
            }
        }
    }

    private func divisionFrame(in geometry: GeometryProxy) -> CGRect? {
        if #available(iOS 27.1, tvOS 27.1, visionOS 27.1, *) {
            return geometry.reservedRegions(kind: .division, options: .includeInactive)
                .first?
                .frame
        }
        return nil
    }

    private func isVerticalHinge(hingeRect: CGRect?) -> Bool {
        if let hingeRect {
            return hingeRect.height > hingeRect.width
        }
        return isLandscape
    }

    private var displaySection: some View {
        MeterDisplaySection(
            animationFrames: uiState.animationFrames,
            speedKph: uiState.meterStatus == .running ? uiState.currentSpeedKph : 0.0,
            currentCost: uiState.currentCost,
            costCounter: uiState.costCounter,
            isLandscape: isLandscape
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
