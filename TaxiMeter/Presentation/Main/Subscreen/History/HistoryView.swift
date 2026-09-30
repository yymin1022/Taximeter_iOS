//
//  HistoryView.swift
//  TaxiMeter
//

import SwiftUI

public struct HistoryView: View {
    @StateObject private var viewModel: HistoryViewModel

    public init(viewModel: HistoryViewModel = HistoryViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            Text("History")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    HistoryView()
}
