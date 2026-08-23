//
//  AppRouter.swift
//  TaxiMeter
//

import Combine
import SwiftUI

/// App Navigation Router
/// - Manages routes stack and transitions for TaxiMeterNavRoute
public final class AppRouter: ObservableObject {
    @Published public var routes: [TaxiMeterNavRoute] = []

    public init() {}

    public func navigate(to route: TaxiMeterNavRoute) {
        if route == .main {
            popToRoot()
        } else {
            routes.append(route)
        }
    }

    public func pop() {
        guard !routes.isEmpty else { return }
        routes.removeLast()
    }

    public func popToRoot() {
        routes.removeAll()
    }
}
