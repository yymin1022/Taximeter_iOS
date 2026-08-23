//
//  RadioSelectDialog.swift
//  TaxiMeter
//

import SwiftUI

public struct RadioSelectDialog: View {
    public let title: String
    public let items: [String]
    @State private var selectedIndex: Int
    public let onConfirm: (Int) -> Void
    public let onDismiss: () -> Void

    public init(
        title: String,
        items: [String],
        selectedIndex: Int,
        onConfirm: @escaping (Int) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.items = items
        self._selectedIndex = State(initialValue: selectedIndex)
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(0..<items.count, id: \.self) { idx in
                        Button {
                            selectedIndex = idx
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                onConfirm(idx)
                            }
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(items[idx]))
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedIndex == idx {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.semibold))
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
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
                        onConfirm(selectedIndex)
                    }
                    .font(.body.weight(.semibold))
                }
            }
        }
        .navigationViewStyle(.stack)
        .ifAvailablePresentationDetentsMediumLarge()
    }
}

private extension View {
    @ViewBuilder
    func ifAvailablePresentationDetentsMediumLarge() -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            self
        }
    }
}
