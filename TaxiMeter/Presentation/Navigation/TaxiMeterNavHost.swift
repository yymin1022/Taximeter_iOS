//
//  TaxiMeterNavHost.swift
//  TaxiMeter
//

import SwiftUI

/// TaxiMeter Nav Host
/// - Manages NavigationStack and destination routing for TaxiMeterNavRoute
public struct TaxiMeterNavHost: View {
    @State private var router: AppRouter = AppRouter()

    public init() {}

    public var body: some View {
        NavigationStack(path: $router.path) {
            MainView()
                .navigationDestination(for: TaxiMeterNavRoute.self) { route in
                    switch route {
                    case .main:
                        MainView()
                    case .meter:
                        MeterView()
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    TaxiMeterNavHost()
}
