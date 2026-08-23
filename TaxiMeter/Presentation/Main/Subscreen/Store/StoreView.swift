//
//  StoreView.swift
//  TaxiMeter
//

import SwiftUI

public struct StoreView: View {
    @StateObject private var viewModel: StoreViewModel

    public init(viewModel: StoreViewModel = StoreViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            if viewModel.uiState.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.uiState.productItems.enumerated()), id: \.offset) { idx, item in
                                productCard(item: item, isSelected: viewModel.uiState.selectedProductIdx == idx) {
                                    viewModel.onClickProduct(idx: idx)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }

                    purchaseButton
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 84)
                }
            }

            // Toast Overlay
            if let snackBarMsg = viewModel.uiState.snackBarMessage {
                VStack {
                    Spacer()
                    Text(LocalizedStringKey(snackBarMsg))
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.8))
                        )
                        .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            viewModel.clearSnackBar()
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadProducts()
        }
    }

    private func productCard(item: ProductItem, isSelected: Bool, onClick: @escaping () -> Void) -> some View {
        Button(action: onClick) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(LocalizedStringKey(item.title))
                            .font(.headline)
                            .foregroundColor(.primary)

                        if item.isPurchased {
                            Text(LocalizedStringKey("Purchased"))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.green))
                        }
                    }

                    Text(LocalizedStringKey(item.desc))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Text(item.formattedPrice)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var purchaseButton: some View {
        Button {
            viewModel.onClickPurchase()
        } label: {
            HStack {
                Spacer()
                if viewModel.uiState.isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(LocalizedStringKey("Purchase"))
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(viewModel.uiState.selectedProductIdx != nil ? Color.blue : Color.gray.opacity(0.4))
            )
        }
        .disabled(viewModel.uiState.selectedProductIdx == nil || viewModel.uiState.isPurchasing)
    }
}

#Preview {
    StoreView()
}
