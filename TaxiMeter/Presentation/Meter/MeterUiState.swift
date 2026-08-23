//
//  MeterUiState.swift
//  TaxiMeter
//

import Foundation

/// UI State for MeterViewModel
public struct MeterUiState: Equatable, Sendable {
    /// Current cost (KRW)
    public var currentCost: Int
    /// Cost counter remaining (m)
    public var costCounter: Int
    /// Current speed (km/h)
    public var currentSpeedKph: Double
    /// Total drove distance (m)
    public var totalDistanceMeters: Double
    /// Meter status
    public var meterStatus: MeterStatus
    /// Whether city rate is applied
    public var isCityRate: Bool
    /// Whether night rate is applied
    public var isNightRate: Bool

    /// Animation image asset names
    public var animationFrames: [String]

    /// Show stop confirmation dialog
    public var showStopDialog: Bool

    /// SnackBar / Toast message
    public var snackBarMessage: String?

    /// Whether advertisement is removed
    public var isAdRemoved: Bool

    public init(
        currentCost: Int = 0,
        costCounter: Int = 0,
        currentSpeedKph: Double = 0.0,
        totalDistanceMeters: Double = 0.0,
        meterStatus: MeterStatus = .notRunning,
        isCityRate: Bool = false,
        isNightRate: Bool = false,
        animationFrames: [String] = [],
        showStopDialog: Bool = false,
        snackBarMessage: String? = nil,
        isAdRemoved: Bool = false
    ) {
        self.currentCost = currentCost
        self.costCounter = costCounter
        self.currentSpeedKph = currentSpeedKph
        self.totalDistanceMeters = totalDistanceMeters
        self.meterStatus = meterStatus
        self.isCityRate = isCityRate
        self.isNightRate = isNightRate
        self.animationFrames = animationFrames
        self.showStopDialog = showStopDialog
        self.snackBarMessage = snackBarMessage
        self.isAdRemoved = isAdRemoved
    }
}
