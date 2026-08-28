//
//  TaxiMeterWidgetLiveActivity.swift
//  TaxiMeterWidget
//
//  Created by 유용민 on 8/27/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

public struct TaxiMeterWidgetLiveActivity: Widget {
    public init() {}

    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: TaxiMeterActivityAttributes.self) { context in
            // Lock screen / Banner UI
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.85))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                            .foregroundColor(.white)
                        Text(LocalizedStringKey("Taxi Meter"))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 8)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 4) {
                        if context.state.isNightRate {
                            Text(LocalizedStringKey("Night"))
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        if context.state.isCityRate {
                            Text(LocalizedStringKey("Out city"))
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.trailing, 8)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .bottom, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(format: "%.1f km", context.state.totalDistanceMeters / 1000.0))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            Text(String(format: "%.0f km/h", context.state.currentSpeedKph))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }

                        Spacer()

                        Text(formattedCost(context.state.currentCost))
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                }
            } compactLeading: {
                HStack(spacing: 2) {
                    Image(systemName: "car.fill")
                        .foregroundColor(.white)
                    Text(formattedCost(context.state.currentCost))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            } compactTrailing: {
                Text(String(format: "%.1fkm", context.state.totalDistanceMeters / 1000.0))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            } minimal: {
                Image(systemName: "car.fill")
                    .foregroundColor(.white)
            }
            .keylineTint(Color.white)
        }
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TaxiMeterActivityAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "car.fill")
                        .foregroundColor(.white)
                    Text(LocalizedStringKey("Taxi Meter"))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if context.state.isNightRate {
                        Text(LocalizedStringKey("Night"))
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    if context.state.isCityRate {
                        Text(LocalizedStringKey("Out city"))
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 8) {
                    Text(String(format: "%.1f km", context.state.totalDistanceMeters / 1000.0))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.0f km/h", context.state.currentSpeedKph))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            Spacer()

            Text(formattedCost(context.state.currentCost))
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding()
    }
}

private func formattedCost(_ cost: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let costString = formatter.string(from: NSNumber(value: cost)) ?? "\(cost)"
    let format = NSLocalizedString("live_activity_cost_format", comment: "")
    return String(format: format, costString)
}
