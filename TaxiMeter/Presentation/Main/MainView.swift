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
    @Namespace private var tabAnimation

    public init(viewModel: MainViewModel = MainViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Persistent Subscreen Views Hierarchy (Preserves State across Tab Switches)
            persistentTabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating TabBar matching Screenshots 1:1 (Multi-platform SwiftUI Semantic Styling)
            floatingTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
    private var persistentTabContent: some View {
        ZStack {
            ForEach(TabInfo.allCases) { tab in
                screen(for: tab)
                    .opacity(viewModel.selectedTab == tab ? 1 : 0)
                    .allowsHitTesting(viewModel.selectedTab == tab)
            }
        }
    }
    
    @ViewBuilder
    private func screen(for tab: TabInfo) -> some View {
        switch tab {
        case .setting:
            SettingView()
        case .home:
            HomeView()
        case .store:
            StoreView()
        }
    }

    // Floating TabBar matching Screenshots 1:1
    private var floatingTabBar: some View {
        HStack(spacing: TabBarMetrics.itemSpacing) {
            ForEach(TabInfo.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, TabBarMetrics.barHorizontalPadding)
        .padding(.vertical, TabBarMetrics.barVerticalPadding)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(
                    color: Color.black.opacity(TabBarMetrics.shadowOpacity),
                    radius: TabBarMetrics.shadowRadius,
                    x: 0,
                    y: TabBarMetrics.shadowYOffset
                )
        )
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(TabBarMetrics.strokeOpacity), lineWidth: TabBarMetrics.strokeWidth)
        )
        .padding(.horizontal, TabBarMetrics.outerHorizontalPadding)
    }

    @ViewBuilder
    private func tabButton(for tab: TabInfo) -> some View {
        let isSelected = viewModel.selectedTab == tab

        Button {
            withAnimation(.spring(response: TabBarMetrics.springResponse, dampingFraction: TabBarMetrics.springDamping)) {
                viewModel.selectedTab = tab
            }
        } label: {
            VStack(spacing: TabBarMetrics.labelSpacing) {
                if #available(iOS 17.0, *) {
                    Image(systemName: tab.systemImageName)
                        .font(.system(size: TabBarMetrics.iconSize, weight: .medium))
                        .symbolEffect(.bounce, value: isSelected)
                } else {
                    Image(systemName: tab.systemImageName)
                        .font(.system(size: TabBarMetrics.iconSize, weight: .medium))
                }

                Text(LocalizedStringKey(tab.title))
                    .font(.system(size: TabBarMetrics.labelFontSize, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TabBarMetrics.itemVerticalPadding)
            .padding(.horizontal, TabBarMetrics.itemHorizontalPadding)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.primary.opacity(TabBarMetrics.selectedFillOpacity))
                        .matchedGeometryEffect(id: TabBarMetrics.selectionPillID, in: tabAnimation)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: - Metrics

    private enum TabBarMetrics {
        static let iconSize: CGFloat = 22
        static let labelFontSize: CGFloat = 11
        static let labelSpacing: CGFloat = 3

        static let itemSpacing: CGFloat = 4
        static let itemVerticalPadding: CGFloat = 10
        static let itemHorizontalPadding: CGFloat = 16

        static let barHorizontalPadding: CGFloat = 10
        static let barVerticalPadding: CGFloat = 6
        static let outerHorizontalPadding: CGFloat = 28

        static let shadowOpacity: Double = 0.12
        static let shadowRadius: CGFloat = 16
        static let shadowYOffset: CGFloat = 8

        static let strokeOpacity: Double = 0.08
        static let strokeWidth: CGFloat = 1

        static let selectedFillOpacity: Double = 0.12

        static let springResponse: Double = 0.35
        static let springDamping: Double = 0.72

        static let selectionPillID = "selectedTabPill"
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
