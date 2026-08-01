//
//  SettingView.swift
//  TaxiMeter
//

import SwiftUI

public struct SettingView: View {
    @State private var viewModel: SettingViewModel

    public init(viewModel: SettingViewModel = SettingViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Text("Setting Screen")
                .font(AppTypography.headlineMedium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingView()
}
