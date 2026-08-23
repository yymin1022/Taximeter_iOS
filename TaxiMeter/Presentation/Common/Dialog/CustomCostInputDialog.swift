//
//  CustomCostInputDialog.swift
//  TaxiMeter
//

import SwiftUI

public struct CustomCostInputDialog: View {
    public let title: String
    @State private var costBase: String = "4800"
    @State private var distBase: String = "1600"
    @State private var costRunPer: String = "131"
    @State private var costTimePer: String = "30"
    @State private var extraRateCity: String = "20"
    @State private var extraRateNight1: String = "20"
    @State private var extraRateNight2: String = "40"

    public let onConfirm: (CostInfo) -> Void
    public let onDismiss: () -> Void

    public init(
        title: String,
        onConfirm: @escaping (CostInfo) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Base Cost")) {
                    inputRow("Base Cost (KRW)", text: $costBase)
                    inputRow("Base Cost Distance (m)", text: $distBase)
                }

                Section(header: Text("Cost per Run / Time")) {
                    inputRow("Cost per Run (m)", text: $costRunPer)
                    inputRow("Cost per Time (s)", text: $costTimePer)
                }

                Section(header: Text("Extra Rate (%)")) {
                    inputRow("Out city", text: $extraRateCity)
                    inputRow("Night step 1", text: $extraRateNight1)
                    inputRow("Night step 2", text: $extraRateNight2)
                }
            }
            .navigationTitle(LocalizedStringKey(title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Complete") {
                        let costInfo = CostInfo(
                            region: RegionSetting.custom.rawValue,
                            costBase: Int(costBase) ?? 4800,
                            distBase: Int(distBase) ?? 1600,
                            costRunPer: Int(costRunPer) ?? 131,
                            costTimePer: Int(costTimePer) ?? 30,
                            extraRateCity: Int(extraRateCity) ?? 20,
                            extraRateNight1: Int(extraRateNight1) ?? 20,
                            extraRateNight2: Int(extraRateNight2) ?? 40,
                            nightStartHour1: 22,
                            nightStartHour2: 23,
                            nightEndHour1: 4,
                            nightEndHour2: 2
                        )
                        onConfirm(costInfo)
                    }
                    .font(.body.weight(.semibold))
                }
            }
        }
        .navigationViewStyle(.stack)
        .ifAvailablePresentationDetentsLarge()
    }

    private func inputRow(_ label: String, text: Binding<String>) -> some View {
        HStack {
            Text(LocalizedStringKey(label))
                .foregroundColor(.primary)
            Spacer(minLength: 16)
            TextField(label, text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.secondary)
        }
    }
}

private extension View {
    @ViewBuilder
    func ifAvailablePresentationDetentsLarge() -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.large])
                .presentationDragIndicator(.visible)
        } else {
            self
        }
    }
}
