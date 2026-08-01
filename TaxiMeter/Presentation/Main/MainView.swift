//
//  MainView.swift
//  TaxiMeter
//

import SwiftUI

public struct MainView: View {
    @State private var viewModel: MainViewModel

    public init(viewModel: MainViewModel = MainViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Text("Main Screen")
                .font(AppTypography.headlineMedium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainView()
}
