//
//  SettingView.swift
//  TaxiMeter
//

import SwiftUI

public struct SettingView: View {
    @State private var viewModel: SettingViewModel
    @State private var activeSafariUrl: URL?

    public init(viewModel: SettingViewModel = SettingViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        List {
            ForEach(Array(viewModel.uiState.settingGroups.enumerated()), id: \.element.id) { idx, group in
                Section(header: Text(group.title)) {
                    ForEach(group.items) { item in
                        Button {
                            item.onClick?()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.body)
                                        .foregroundColor(.primary)

                                    if let subtitle = item.subtitle {
                                        Text(subtitle)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                if idx == 1 && !viewModel.uiState.isAdRemoved {
                    Section {
                        NativeAdView()
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 84)
        }
        .onAppear {
            viewModel.loadSettingGroups()
        }
        .onChange(of: viewModel.uiState.openUrlRequest) { _, newUrl in
            if let url = newUrl {
                activeSafariUrl = url
                viewModel.clearOpenUrlRequest()
            }
        }
        .sheet(item: $activeSafariUrl) { url in
            SFSafariView(url: url)
                .ignoresSafeArea()
        }
        .sheet(isPresented: Binding(
            get: { viewModel.uiState.showDialog != .nothing },
            set: { if !$0 { viewModel.dismissDialog() } }
        )) {
            dialogSheet
        }
    }

    @ViewBuilder
    private var dialogSheet: some View {
        switch viewModel.uiState.showDialog {
        case .nothing:
            EmptyView()
        case let .radioSelectDialog(title, items, selectedIndex, onComplete):
            RadioSelectDialog(
                title: title,
                items: items,
                selectedIndex: selectedIndex,
                onConfirm: { idx in
                    onComplete(idx)
                },
                onDismiss: {
                    viewModel.dismissDialog()
                }
            )
        case let .customCostDialog(title, onComplete):
            CustomCostInputDialog(
                title: title,
                onConfirm: { costInfo in
                    onComplete(costInfo)
                },
                onDismiss: {
                    viewModel.dismissDialog()
                }
            )
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    SettingView()
}
