//
//  MeterInfoSection.swift
//  TaxiMeter
//

import SwiftUI

/// 미터기 주행 정보(현재 속도, 주행 상태, 주행 거리) 표시 섹션
public struct MeterInfoSection: View {
    @Environment(\.meterColors) private var meterColors

    public let currentSpeedKph: Double
    public let meterStatus: MeterStatus
    public let totalDistanceMeters: Double

    public init(
        currentSpeedKph: Double,
        meterStatus: MeterStatus,
        totalDistanceMeters: Double
    ) {
        self.currentSpeedKph = currentSpeedKph
        self.meterStatus = meterStatus
        self.totalDistanceMeters = totalDistanceMeters
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Speed Column
            VStack(alignment: .trailing, spacing: 6) {
                Text("Current Speed")
                    .font(.subheadline)
                    .foregroundColor(meterColors.onBackground)
                Text(String(format: "%.1f km/h", currentSpeedKph))
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
                Text(LocalizedStringKey(statusText(meterStatus)))
                    .font(.headline.weight(.semibold))
                    .foregroundColor(meterColors.onBackground)

                Spacer().frame(height: 4)

                Text("Distance")
                    .font(.subheadline)
                    .foregroundColor(meterColors.onBackground)
                Text(String(format: "%.1f km", totalDistanceMeters / 1000.0))
                    .font(.title3.weight(.bold))
                    .foregroundColor(meterColors.onBackground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
    }

    private func statusText(_ status: MeterStatus) -> String {
        switch status {
        case .notRunning: return "Not driving"
        case .running: return "Driving..."
        case .gpsError: return "GPS Error"
        }
    }
}
