//
//  HomeView.swift
//  TaxiMeter
//

import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var appRouter: AppRouter

    public init(viewModel: HomeViewModel = HomeViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // Main Touch Area -> Navigate to Meter Screen
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    appRouter.navigate(to: .meter)
                }

            VStack(spacing: 24) {
                Spacer()

                // App Logo (Icon + Text)
                appLogo

                // Description Text
                descriptionText

                Spacer()
            }
            .padding()

            // Toast Message Overlay
            if let toastMessage = viewModel.uiState.toastMessage {
                toastView(message: toastMessage)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .task {
            viewModel.updateCostInfo()
        }
    }

    // App Logo Component
    private var appLogo: some View {
        VStack(spacing: 16) {
            Image("ic_local_taxi")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundColor(.primary)

            HStack(spacing: 0) {
                Text("Taxi")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.primary)

                Text("Meter")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(.primary)
            }
        }
    }

    // Description Text Component
    private var descriptionText: some View {
        VStack(spacing: 8) {
            if let caption = viewModel.uiState.homeCaption {
                Text(caption)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(LocalizedStringKey("Touch to start"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text(LocalizedStringKey("Touch to start"))
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
    }

    // Toast Banner Component
    private func toastView(message: String) -> some View {
        VStack {
            Spacer()

            Text(LocalizedStringKey(message))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.85))
                )
                .padding(.bottom, 90)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    viewModel.clearToast()
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
}
