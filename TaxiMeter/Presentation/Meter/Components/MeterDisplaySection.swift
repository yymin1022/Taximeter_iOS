//
//  MeterDisplaySection.swift
//  TaxiMeter
//

import Foundation
import SwiftUI

/// 미터기 주행 애니메이션 및 요금/카운터 표시 섹션
public struct MeterDisplaySection: View {
    @Environment(\.meterColors) private var meterColors

    public let animationFrames: [String]
    public let speedKph: Double
    public let currentCost: Int
    public let costCounter: Int
    public let isLandscape: Bool

    public init(
        animationFrames: [String],
        speedKph: Double,
        currentCost: Int,
        costCounter: Int,
        isLandscape: Bool = false
    ) {
        self.animationFrames = animationFrames
        self.speedKph = speedKph
        self.currentCost = currentCost
        self.costCounter = costCounter
        self.isLandscape = isLandscape
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack {
                Spacer()
                MeterAnimationView(
                    animationFrames: animationFrames,
                    speedKph: speedKph
                )
                .frame(width: 90, height: 90)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, isLandscape ? 4 : 8)

            costView
                .padding(.horizontal, 20)
        }
    }

    private var costView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("₩\(formattedCost(currentCost))")
                .font(.system(size: 60, weight: .semibold, design: .rounded))
                .foregroundColor(meterColors.onBackground)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(verbatim: "\(costCounter)")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(meterColors.blue)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func formattedCost(_ cost: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: cost)) ?? "\(cost)"
    }
}

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
        .onChange(of: speedKph) { newSpeed in
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

        let displaySpeed = Int(speed)
        guard !animationFrames.isEmpty, displaySpeed > 0 else {
            frameIndex = 0
            return
        }

        let intervalMs: UInt64
        if displaySpeed > 50 {
            intervalMs = 142
        } else if displaySpeed > 30 {
            intervalMs = 200
        } else if displaySpeed > 20 {
            intervalMs = 250
        } else if displaySpeed > 10 {
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
