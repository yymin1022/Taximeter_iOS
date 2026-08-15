//
//  MeterDefs.swift
//  TaxiMeter
//

import Foundation

/// Meter Definitions & Constants
public struct MeterDefs {
    /// Cost increasing unit (KRW)
    public static let costUnit: Int = 100

    /// GPS accuracy permit threshold (meters) - Aligned with Flutter/Android PR #15
    public static let gpsAccuracyThreshold: Double = 50.0

    /// Meter update interval (ms)
    public static let meterUpdateIntervalMs: Int64 = 1000

    /// Speed threshold with distance/time cost combined system (km/h)
    public static let speedThresholdKph: Double = 15.0
}
