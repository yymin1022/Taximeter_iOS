//
//  MainViewModel.swift
//  TaxiMeter
//

import Combine
import SwiftUI

/// Main ViewModel
/// - Manages UI State for Main View
public final class MainViewModel: ObservableObject {
    @Published public var selectedTab: TabInfo = .home

    public init() {}
}
