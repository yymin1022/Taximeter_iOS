//
//  MeterStatus.swift
//  TaxiMeter
//

import Foundation

/// Meter Status Enum
public enum MeterStatus: String, Codable, Sendable {
    /// Meter is not running
    case notRunning
    /// Meter is running
    case running
    /// Meter is running, but GPS signal is unavailable or accuracy is low
    case gpsError
}
