//
//  MeterView.swift
//  TaxiMeter
//

import Foundation
import SwiftUI

/// Meter Screen View
public struct MeterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.meterColors) private var meterColors
    @StateObject private var viewModel: MeterViewModel

    public init(viewModel: MeterViewModel = MeterViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                meterColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Navigation Bar
                    topBar

                    if isLandscape {
                        landscapeContent
                    } else {
                        portraitContent
                    }
                }

                // Toast / SnackBar Overlay
                if let snackMessage = viewModel.uiState.snackBarMessage {
                    VStack {
                        Spacer()
                        Text(LocalizedStringKey(snackMessage))
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color.black.opacity(0.8)))
                            .padding(.bottom, 32)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.easeInOut, value: viewModel.uiState.snackBarMessage)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            viewModel.clearSnackBar()
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.checkFirstLaunch()
            viewModel.loadAdRemovalStatus()
        }
        .alert("Stop driving", isPresented: $viewModel.uiState.showStopDialog) {
            Button("Cancel", role: .cancel) {
                viewModel.onCancelStop()
            }
            Button("OK") {
                viewModel.onConfirmStop()
            }
        } message: {
            Text(stopDialogMessage)
        }
        .alert("Stop driving", isPresented: $viewModel.uiState.showBackDialog) {
            Button("Cancel", role: .cancel) {
                viewModel.onCancelBack()
            }
            Button("OK") {
                viewModel.onConfirmBack(onDismiss: { dismiss() })
            }
        } message: {
            Text("The meter is currently running. Do you want to stop driving and go back?")
        }
        .alert("Notice", isPresented: $viewModel.uiState.showFirstLaunchDialog) {
            Button("OK") {
                viewModel.onConfirmFirstLaunch()
            }
        } message: {
            Text("Measurement errors may occur depending on GPS status.\nPlease use this app for reference only as differences from actual taxi meters may occur.")
        }
        .meterTheme()
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    // MARK: - Portrait & Landscape Contents

    private var portraitContent: some View {
        VStack(spacing: 0) {
            // Push all meter content to the bottom (Arrangement.Bottom)
            Spacer()

            displaySection

            infoSection
                .padding(.vertical, 24)

            controlSection
                .padding(.bottom, 16)

            if !viewModel.uiState.isAdRemoved {
                BannerAdView()
                    .padding(.bottom, 8)
            }
        }
    }

    private var landscapeContent: some View {
        HStack(spacing: 0) {
            // Left Column: Animation & Cost (Aligned to bottom-end matching Android)
            VStack(alignment: .trailing, spacing: 0) {
                Spacer()

                displaySection
                    .padding(.bottom, 48)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            // Right Column: Info & Control Buttons
            VStack(spacing: 0) {
                Spacer()

                infoSection
                    .padding(.vertical, 8)

                controlSection
                    .padding(.bottom, 12)

                if !viewModel.uiState.isAdRemoved {
                    BannerAdView()
                        .padding(.bottom, 6)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    // MARK: - Subviews

    private var displaySection: some View {
        MeterDisplaySection(
            animationFrames: viewModel.uiState.animationFrames,
            speedKph: viewModel.uiState.meterStatus == .running ? viewModel.uiState.currentSpeedKph : 0.0,
            currentCost: viewModel.uiState.currentCost,
            costCounter: viewModel.uiState.costCounter
        )
    }

    private var infoSection: some View {
        MeterInfoSection(
            currentSpeedKph: viewModel.uiState.currentSpeedKph,
            meterStatus: viewModel.uiState.meterStatus,
            totalDistanceMeters: viewModel.uiState.totalDistanceMeters
        )
    }

    private var controlSection: some View {
        MeterControlSection(
            isNightRate: viewModel.uiState.isNightRate,
            isCityRate: viewModel.uiState.isCityRate,
            onClickStart: viewModel.onClickStart,
            onClickStop: viewModel.onClickStop,
            onClickNightRate: viewModel.onClickNightRate,
            onClickCityRate: viewModel.onClickCityRate
        )
    }

    private var topBar: some View {
        HStack {
            Button(action: {
                viewModel.onClickBack(onDismiss: { dismiss() })
            }) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundColor(meterColors.onBackground)
                    .frame(width: 40, height: 40)
                    .applyGlassEffect(in: Circle())
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var stopDialogMessage: String {
        let cost = formattedCost(viewModel.uiState.currentCost)
        let dist = String(format: "%.1f", viewModel.uiState.totalDistanceMeters / 1000.0)
        let format = NSLocalizedString("meter_dialog_stop_content", comment: "")
        if format != "meter_dialog_stop_content" {
            return String(format: format, cost, dist)
        }
        let fallbackFormat = NSLocalizedString("Cost: ₩%@\nDistance: %@ km\nStop driving?", comment: "")
        return String(format: fallbackFormat, cost, dist)
    }

    private func formattedCost(_ cost: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: cost)) ?? "\(cost)"
    }
}
