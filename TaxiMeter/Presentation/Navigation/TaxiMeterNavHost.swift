//
//  TaxiMeterNavHost.swift
//  TaxiMeter
//

import SwiftUI

/// TaxiMeter Nav Host
/// - Manages NavigationStack and destination routing for TaxiMeterNavRoute
public struct TaxiMeterNavHost: View {
    @StateObject private var router: AppRouter = AppRouter()

    public init() {}

    public var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(path: $router.routes) {
                MainView()
                    .navigationDestination(for: TaxiMeterNavRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .environmentObject(router)
        } else {
            NavigationView {
                ZStack {
                    MainView()

                    NavigationLink(
                        isActive: Binding(
                            get: { router.routes.last == .meter },
                            set: { isActive in
                                if !isActive && router.routes.last == .meter {
                                    router.pop()
                                }
                            }
                        ),
                        destination: { destinationView(for: .meter) },
                        label: { EmptyView() }
                    )
                    .hidden()
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
            .environmentObject(router)
        }
    }

    @ViewBuilder
    private func destinationView(for route: TaxiMeterNavRoute) -> some View {
        switch route {
        case .main:
            MainView()
        case .meter:
            MeterView()
        }
    }
}

#Preview {
    TaxiMeterNavHost()
}
