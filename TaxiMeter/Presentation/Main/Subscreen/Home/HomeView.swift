//
//  HomeView.swift
//  TaxiMeter
//

import SwiftUI

public struct HomeView: View {
    @State private var viewModel: HomeViewModel

    public init(viewModel: HomeViewModel = HomeViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Text("Home Screen")
                .font(AppTypography.headlineMedium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HomeView()
}
