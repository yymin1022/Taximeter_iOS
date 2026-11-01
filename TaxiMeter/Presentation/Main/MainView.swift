//
//  MainView.swift
//  TaxiMeter
//

import SwiftUI
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

public struct MainView: View {
    @StateObject private var viewModel: MainViewModel

    public init(viewModel: MainViewModel = MainViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(TabInfo.allCases) { tab in
                screen(for: tab)
                    .tabItem {
                        Label(LocalizedStringKey(tab.title), systemImage: tab.systemImageName)
                    }
                    .tag(tab)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            requestTrackingAuthorizationIfNeeded()
        }
    }

    private func requestTrackingAuthorizationIfNeeded() {
        #if canImport(AppTrackingTransparency)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization { _ in }
            }
        }
        #endif
    }

    @ViewBuilder
    private func screen(for tab: TabInfo) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .history:
            HistoryView()
        case .store:
            StoreView()
        case .setting:
            SettingView()
        }
    }
}

#Preview("Light Mode") {
    MainView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    MainView()
        .preferredColorScheme(.dark)
}
