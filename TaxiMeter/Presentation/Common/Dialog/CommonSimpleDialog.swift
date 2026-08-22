//
//  CommonSimpleDialog.swift
//  TaxiMeter
//

import SwiftUI

/// Reusable Simple Dialog with Apple Native Styling
public struct CommonSimpleDialog: View {
    public let title: String
    public let desc: String
    public let confirmText: String
    public let dismissText: String
    public let onConfirm: () -> Void
    public let onDismiss: () -> Void

    public init(
        title: String,
        desc: String,
        confirmText: String = "OK",
        dismissText: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.desc = desc
        self.confirmText = confirmText
        self.dismissText = dismissText
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text(desc)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
                .padding(.bottom, 18)

                Divider()

                HStack(spacing: 0) {
                    Button(action: onDismiss) {
                        Text(dismissText)
                            .font(.body)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    Divider()

                    Button(action: onConfirm) {
                        Text(confirmText)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(height: 44)
            }
            .frame(width: 270)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        }
    }
}
