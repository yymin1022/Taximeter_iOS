//
//  AppLoggerImpl.swift
//  TaxiMeter
//

import Foundation
import os

#if canImport(FirebaseCore)
import FirebaseCore
#endif

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
    
    private var isFirebaseConfigured: Bool {
        #if canImport(FirebaseCore)
        return FirebaseApp.app() != nil
        #else
        return false
        #endif
    }
    
    public func log(_ message: String) {
        logger.debug("\(message)")
        
        #if canImport(FirebaseCrashlytics)
        if isFirebaseConfigured {
            Crashlytics.crashlytics().log(message)
        }
        #endif
    }
    
    public func recordError(_ error: Error, message: String? = nil) {
        if let message = message {
            logger.error("\(message): \(error.localizedDescription)")
            #if canImport(FirebaseCrashlytics)
            if isFirebaseConfigured {
                Crashlytics.crashlytics().log(message)
            }
            #endif
        } else {
            logger.error("\(error.localizedDescription)")
        }
        
        #if canImport(FirebaseCrashlytics)
        if isFirebaseConfigured {
            Crashlytics.crashlytics().record(error: error)
        }
        #endif
    }
    
    public func logEvent(_ name: String, params: [String: Any]? = nil) {
        logger.info("Event: \(name), Params: \(String(describing: params))")
        
        #if canImport(FirebaseAnalytics)
        if isFirebaseConfigured {
            Analytics.logEvent(name, parameters: params)
        }
        #endif
    }
}
