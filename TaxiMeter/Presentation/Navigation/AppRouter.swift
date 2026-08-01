//
//  AppRouter.swift
//  TaxiMeter
//

import SwiftUI
import Observation

/// App Navigation Router
/// - Manages NavigationPath and route transitions
@Observable
public final class AppRouter {
    public var path: NavigationPath = NavigationPath()

    public init() {}

    public func navigate(to route: TaxiMeterNavRoute) {
        if route == .main {
            popToRoot()
        } else {
            path.append(route)
        }
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }
}
