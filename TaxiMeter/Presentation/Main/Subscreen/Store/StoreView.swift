//
//  StoreView.swift
//  TaxiMeter
//

import SwiftUI

public struct StoreView: View {
    @State private var viewModel: StoreViewModel

    public init(viewModel: StoreViewModel = StoreViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Text("Store Screen")
                .font(AppTypography.headlineMedium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StoreView()
}
