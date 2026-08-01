//
//  MeterView.swift
//  TaxiMeter
//

import SwiftUI

public struct MeterView: View {
    @State private var viewModel: MeterViewModel

    public init(viewModel: MeterViewModel = MeterViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Text("Meter Screen")
                .font(AppTypography.headlineMedium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MeterView()
}
