//
//  TaxiMeterApp.swift
//  TaxiMeter
//

import SwiftUI
import SwiftData

#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct TaxiMeterApp: App {
    let logger: AppLogger
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil && Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
        #endif
        
        self.logger = AppLoggerImpl()
        self.logger.log("TaxiMeter App initialized")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .meterTheme()
        }
        .modelContainer(sharedModelContainer)
    }
}
