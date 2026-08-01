//
//  AppLoggerImpl.swift
//  TaxiMeter
//

import Foundation
import os

#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

/// App Logger Implementation using os.Logger and Firebase (Crashlytics & Analytics)
public final class AppLoggerImpl: AppLogger {
    private let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yong.taximeter", category: "TaxiMeter")
    
    public init() {}
    
    public func log(_ message: String) {
        logger.debug("\(message, privacy: .public)")
        
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log(message)
        #endif
    }
    
    public func recordError(_ error: Error, message: String? = nil) {
        if let message = message {
            logger.error("\(message, privacy: .public): \(error.localizedDescription, privacy: .public)")
            #if canImport(FirebaseCrashlytics)
            Crashlytics.crashlytics().log(message)
            #endif
        } else {
            logger.error("\(error.localizedDescription, privacy: .public)")
        }
        
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().record(error: error)
        #endif
    }
    
    public func logEvent(_ name: String, params: [String: Any]? = nil) {
        logger.info("Event: \(name, privacy: .public), Params: \(String(describing: params), privacy: .public)")
        
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(name, parameters: params)
        #endif
    }
}
