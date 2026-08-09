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
        NavigationStack {
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
                                Text(items[idx])
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
            .navigationTitle(title)
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
                    .bold()
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
