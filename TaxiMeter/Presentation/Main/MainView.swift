//
//  MainView.swift
//  TaxiMeter
//

import SwiftUI

public struct MainView: View {
    @State private var viewModel: MainViewModel
    @Namespace private var tabAnimation

    public init(viewModel: MainViewModel = MainViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Persistent Subscreen Views Hierarchy (Preserves State across Tab Switches)
            ZStack {
                SettingView()
                    .opacity(viewModel.selectedTab == .setting ? 1 : 0)
                    .allowsHitTesting(viewModel.selectedTab == .setting)

                HomeView()
                    .opacity(viewModel.selectedTab == .home ? 1 : 0)
                    .allowsHitTesting(viewModel.selectedTab == .home)

                StoreView()
                    .opacity(viewModel.selectedTab == .store ? 1 : 0)
                    .allowsHitTesting(viewModel.selectedTab == .store)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating TabBar matching Screenshots 1:1 (Multi-platform SwiftUI Semantic Styling)
            floatingTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // Floating TabBar matching Screenshots 1:1
    private var floatingTabBar: some View {
        HStack(spacing: 4) {
            ForEach(TabInfo.allCases) { tab in
                let isSelected = viewModel.selectedTab == tab

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.systemImageName)
                            .font(.system(size: 22, weight: .medium))
                            .symbolEffect(.bounce, value: isSelected)

                        Text(tab.title)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(isSelected ? .blue : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(Color.primary.opacity(0.12))
                                .matchedGeometryEffect(id: "activeTabScreenshotPill", in: tabAnimation)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
        )
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 28)
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
