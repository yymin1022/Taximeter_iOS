//
//  TaxiMeterApp.swift
//  TaxiMeter
//

import SwiftUI

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct TaxiMeterApp: App {
    let logger: AppLogger

    init() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil && Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
        #endif

        #if canImport(GoogleMobileAds)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        #endif
        
        self.logger = AppLoggerImpl()
        self.logger.log("TaxiMeter App initialized")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .meterTheme()
        }
    }
}
