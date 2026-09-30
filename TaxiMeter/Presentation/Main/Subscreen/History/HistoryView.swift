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
            if viewModel.uiState.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            } else if viewModel.uiState.histories.isEmpty {
                emptyView
            } else {
                historyList
            }

            // Clear All Confirm Dialog Overlay
            if viewModel.uiState.showClearAllConfirm {
                CommonSimpleDialog(
                    title: NSLocalizedString("Clear all driving history", comment: ""),
                    desc: NSLocalizedString("Are you sure you want to delete all driving history? This action cannot be undone.", comment: ""),
                    confirmText: NSLocalizedString("Delete", comment: ""),
                    dismissText: NSLocalizedString("Cancel", comment: ""),
                    onConfirm: {
                        viewModel.deleteAllHistories()
                    },
                    onDismiss: {
                        viewModel.hideClearAllConfirm()
                    }
                )
            }
        }
    }

    // Empty View when no histories recorded
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.4))

            Text(LocalizedStringKey("No driving history yet."))
                .font(.body)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // History Content List
    private var historyList: some View {
        List {
            // Summary Card
            summaryCard
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)

            // History Items
            ForEach(viewModel.uiState.histories) { history in
                historyItemCard(history)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteHistory(id: history.id)
                        } label: {
                            Label(LocalizedStringKey("Delete"), systemImage: "trash")
                        }
                    }
            }

            // Clear All Button at bottom
            clearAllButton
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 24, trailing: 16))
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 84)
        }
    }

    // Summary Card displaying total statistics
    private var summaryCard: some View {
        let formattedTotalCost: String = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: viewModel.uiState.totalCost)) ?? "\(viewModel.uiState.totalCost)"
        }()
        let formattedDistance = String(format: "%.1f km", viewModel.uiState.totalDistanceMeters / 1000.0)

        return HStack(spacing: 0) {
            summaryItem(
                label: "Trips",
                value: "\(viewModel.uiState.totalCount)"
            )
            Spacer()
            summaryItem(
                label: "Total Cost",
                value: String(format: NSLocalizedString("meter_cost", value: "%@원", comment: ""), formattedTotalCost)
            )
            Spacer()
            summaryItem(
                label: "Total Distance",
                value: formattedDistance
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func summaryItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(LocalizedStringKey(label))
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }

    // Card representing single driving record
    private func historyItemCard(_ history: MeterHistory) -> some View {
        let dateText: String = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm"
            return formatter.string(from: Date(timeIntervalSince1970: Double(history.timestamp) / 1000.0))
        }()

        let formattedCost: String = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: history.cost)) ?? "\(history.cost)"
        }()

        let distanceKm = String(format: "%.1f km", history.distanceMeters / 1000.0)
        let totalSeconds = Int(history.elapsedSeconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let durationFormat = NSLocalizedString("history_item_duration", comment: "")
        let durationText = String(format: durationFormat, minutes, seconds)
        let detailText = "\(distanceKm) · \(durationText)"

        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateText)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(detailText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: NSLocalizedString("meter_cost", value: "%@원", comment: ""), formattedCost))
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    // Clear all button at bottom of history list
    private var clearAllButton: some View {
        HStack {
            Spacer()
            Button(action: viewModel.showClearAllConfirm) {
                Text(LocalizedStringKey("Clear all history"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
            }
            Spacer()
        }
    }
}

#Preview {
    HistoryView()
}
