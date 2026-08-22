//
//  MeterView.swift
//  TaxiMeter
//

import SwiftUI

/// Meter Screen View
public struct MeterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.meterColors) private var meterColors
    @State private var viewModel: MeterViewModel

    public init(viewModel: MeterViewModel = MeterViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            meterColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation Bar
                topBar

                // Push all meter content to the bottom (Arrangement.Bottom)
                Spacer()

                // Animation Frame (Right-aligned above cost view)
                HStack {
                    Spacer()
                    MeterAnimationView(
                        animationFrames: viewModel.uiState.animationFrames,
                        speedKph: viewModel.uiState.meterStatus == .running ? viewModel.uiState.currentSpeedKph : 0.0
                    )
                    .frame(width: 90, height: 90)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)

                // Cost Display
                costView
                    .padding(.horizontal, 20)

                // Meter Info (Speed, Status, Distance)
                meterInfoView
                    .padding(.vertical, 24)

                // Control Buttons
                controlView
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }

            // Toast / SnackBar Overlay
            if let snackMessage = viewModel.uiState.snackBarMessage {
                VStack {
                    Spacer()
                    Text(snackMessage)
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
        .alert("Stop driving", isPresented: $viewModel.uiState.showStopDialog) {
            Button("Cancel", role: .cancel) {
                viewModel.onCancelStop()
            }
            Button("OK") {
                viewModel.onConfirmStop()
            }
        } message: {
            Text("Cost: ₩\(formattedCost(viewModel.uiState.currentCost))\nDistance: \(String(format: "%.1f", viewModel.uiState.totalDistanceMeters / 1000.0)) km\nStop driving?")
        }
        .meterTheme()
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack {
            Button(action: {
                if viewModel.uiState.meterStatus != .notRunning {
                    viewModel.onClickStop()
                } else {
                    dismiss()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundColor(meterColors.onBackground)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .glassEffect()
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var costView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("₩\(formattedCost(viewModel.uiState.currentCost))")
                .font(.system(size: 60, weight: .semibold, design: .rounded))
                .foregroundColor(meterColors.onBackground)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(verbatim: "\(viewModel.uiState.costCounter)")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(meterColors.blue)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var meterInfoView: some View {
        HStack(alignment: .top, spacing: 20) {
            // Speed Column
            VStack(alignment: .trailing, spacing: 6) {
                Text("Current Speed")
                    .font(.subheadline)
                    .foregroundColor(meterColors.onBackground)
                Text(String(format: "%.1f km/h", viewModel.uiState.currentSpeedKph))
                    .font(.title3.weight(.bold))
                    .foregroundColor(meterColors.onBackground)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            Divider()
                .frame(height: 70)

            // Status & Distance Column
            VStack(alignment: .leading, spacing: 6) {
                Text("Status")
                    .font(.subheadline)
                    .foregroundColor(meterColors.onBackground)
                Text(statusText(viewModel.uiState.meterStatus))
                    .font(.headline.weight(.semibold))
                    .foregroundColor(meterColors.onBackground)

                Spacer().frame(height: 4)

                Text("Distance")
                    .font(.subheadline)
                    .foregroundColor(meterColors.onBackground)
                Text(String(format: "%.1f km", viewModel.uiState.totalDistanceMeters / 1000.0))
                    .font(.title3.weight(.bold))
                    .foregroundColor(meterColors.onBackground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
    }

    private var controlView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Start Button
                MeterControlButton(
                    text: "Start",
                    color: meterColors.blue,
                    textColor: meterColors.buttonText,
                    onClick: viewModel.onClickStart
                )

                // Stop Button
                MeterControlButton(
                    text: "Stop",
                    color: meterColors.yellow,
                    textColor: meterColors.buttonText,
                    onClick: viewModel.onClickStop
                )
            }

            HStack(spacing: 12) {
                // Night Rate Button
                MeterControlButton(
                    text: viewModel.uiState.isNightRate ? "Night rate ON" : "Night rate OFF",
                    color: meterColors.green,
                    textColor: meterColors.buttonText,
                    onClick: viewModel.onClickNightRate
                )

                // City Rate Button
                MeterControlButton(
                    text: viewModel.uiState.isCityRate ? "City rate ON" : "City rate OFF",
                    color: meterColors.red,
                    textColor: meterColors.buttonText,
                    onClick: viewModel.onClickCityRate
                )
            }
        }
    }

    private func formattedCost(_ cost: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: cost)) ?? "\(cost)"
    }

    private func statusText(_ status: MeterStatus) -> String {
        switch status {
        case .notRunning: return "Not driving"
        case .running: return "Driving..."
        case .gpsError: return "GPS Error"
        }
    }
}

// MARK: - Animation View Component

private struct MeterAnimationView: View {
    let animationFrames: [String]
    let speedKph: Double

    @State private var frameIndex: Int = 0
    @State private var timerTask: Task<Void, Never>?

    var body: some View {
        Group {
            if !animationFrames.isEmpty && animationFrames.indices.contains(frameIndex) {
                Image(animationFrames[frameIndex])
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: speedKph) { _, newSpeed in
            restartTimer(speed: newSpeed)
        }
        .onAppear {
            restartTimer(speed: speedKph)
        }
        .onDisappear {
            timerTask?.cancel()
            timerTask = nil
        }
    }

    private func restartTimer(speed: Double) {
        timerTask?.cancel()
        timerTask = nil

        guard !animationFrames.isEmpty, speed > 0.0 else {
            frameIndex = 0
            return
        }

        let intervalMs: UInt64
        if speed > 50.0 {
            intervalMs = 142
        } else if speed > 30.0 {
            intervalMs = 200
        } else if speed > 20.0 {
            intervalMs = 250
        } else if speed > 10.0 {
            intervalMs = 333
        } else {
            intervalMs = 500
        }

        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: intervalMs * 1_000_000)
                guard !Task.isCancelled else { break }
                frameIndex = (frameIndex + 1) % animationFrames.count
            }
        }
    }
}
