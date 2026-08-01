//
//  AppLogger.swift
//  TaxiMeter
//

import Foundation

/// App Logger Interface
/// - Logging, Exception/Error recording is supported
/// - Logging Analytics event is supported
public protocol AppLogger {
    /// Log a message to debug console and crash reporter
    func log(_ message: String)
    
    /// Record an error/exception to crash reporter
    func recordError(_ error: Error, message: String?)
    
    /// Log an analytics event with optional parameters
    func logEvent(_ name: String, params: [String: Any]?)
}

public extension AppLogger {
    func recordError(_ error: Error) {
        recordError(error, message: nil)
    }
    
    func logEvent(_ name: String) {
        logEvent(name, params: nil)
    }
}
