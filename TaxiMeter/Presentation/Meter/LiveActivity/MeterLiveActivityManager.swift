//
//  MeterLiveActivityManager.swift
//  TaxiMeter
//

import Foundation
#if canImport(ActivityKit)
import ActivityKit

public final class MeterLiveActivityManager: @unchecked Sendable {
    public static let shared = MeterLiveActivityManager()

    #if os(iOS)
    @available(iOS 16.1, *)
    private var currentActivity: Activity<TaxiMeterActivityAttributes>? {
        get { _currentActivity as? Activity<TaxiMeterActivityAttributes> }
        set { _currentActivity = newValue }
    }
    private var _currentActivity: Any?
    #endif

    private init() {}

    /// Start Live Activity when driving starts
    public func start(regionName: String, initialState: MeterState) {
        #if os(iOS)
        guard #available(iOS 16.1, *) else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // End any existing activities first
        stop()

        let attributes = TaxiMeterActivityAttributes(regionName: regionName)
        let contentState = TaxiMeterActivityAttributes.ContentState(
            currentCost: initialState.currentCost,
            costCounter: initialState.costCounter,
            currentSpeedKph: initialState.currentSpeedKph,
            totalDistanceMeters: initialState.totalDistanceMeters,
            isNightRate: initialState.isNightRate,
            isCityRate: initialState.isCityRate
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            self.currentActivity = activity
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
        #endif
    }

    /// Update Live Activity on each meter tick / state change
    public func update(state: MeterState) {
        #if os(iOS)
        guard #available(iOS 16.1, *) else { return }
        guard let activity = currentActivity else { return }

        let contentState = TaxiMeterActivityAttributes.ContentState(
            currentCost: state.currentCost,
            costCounter: state.costCounter,
            currentSpeedKph: state.currentSpeedKph,
            totalDistanceMeters: state.totalDistanceMeters,
            isNightRate: state.isNightRate,
            isCityRate: state.isCityRate
        )

        Task {
            await activity.update(using: contentState)
        }
        #endif
    }

    /// Stop and dismiss Live Activity when driving ends
    public func stop() {
        #if os(iOS)
        guard #available(iOS 16.1, *) else { return }
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(dismissalPolicy: .immediate)
        }
        self.currentActivity = nil
        #endif
    }
}
#endif
