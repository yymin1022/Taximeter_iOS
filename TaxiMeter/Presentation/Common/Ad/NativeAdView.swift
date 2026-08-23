//
//  NativeAdView.swift
//  TaxiMeter
//

import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

public struct NativeAdView: View {
    public let adUnitId: String

    @State private var isLoading: Bool = true
    @State private var isFailed: Bool = false
    @State private var fallbackAd: FallbackAd = FallbackAdDefs.getRandomAd()

    public init(adUnitId: String = AdUnits.nativeAdUnitId) {
        self.adUnitId = adUnitId
    }

    public var body: some View {
        ZStack {
            #if canImport(GoogleMobileAds)
            NativeAdViewRepresentable(
                adUnitId: adUnitId,
                isLoading: $isLoading,
                isFailed: $isFailed
            )
            .opacity(!isLoading && !isFailed ? 1 : 0)
            #endif

            if isLoading || isFailed {
                FallbackAdContent(fallbackAd: fallbackAd)
                    .padding(.vertical, 16)
            }
        }
        .frame(height: 90)
        .task(id: isLoading || isFailed) {
            guard isLoading || isFailed else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: FallbackAdDefs.fallbackAdRotationIntervalMs * 1_000_000)
                guard !Task.isCancelled else { break }
                fallbackAd = FallbackAdDefs.getRandomAd(except: fallbackAd)
            }
        }
    }
}

#if canImport(GoogleMobileAds)
private struct NativeAdViewRepresentable: UIViewRepresentable {
    let adUnitId: String
    @Binding var isLoading: Bool
    @Binding var isFailed: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, isFailed: $isFailed)
    }

    func makeUIView(context: Context) -> GADNativeAdView {
        let nativeAdView = GADNativeAdView()
        context.coordinator.setup(adView: nativeAdView, adUnitId: adUnitId)
        return nativeAdView
    }

    func updateUIView(_ uiView: GADNativeAdView, context: Context) {}

    class Coordinator: NSObject, GADNativeAdLoaderDelegate {
        @Binding var isLoading: Bool
        @Binding var isFailed: Bool
        var adLoader: GADAdLoader?
        weak var adView: GADNativeAdView?

        init(isLoading: Binding<Bool>, isFailed: Binding<Bool>) {
            self._isLoading = isLoading
            self._isFailed = isFailed
        }

        func setup(adView: GADNativeAdView, adUnitId: String) {
            self.adView = adView
            guard let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?
                .rootViewController else { return }

            adLoader = GADAdLoader(
                adUnitID: adUnitId,
                rootViewController: rootVC,
                adTypes: [.native],
                options: nil
            )
            adLoader?.delegate = self
            adLoader?.load(GADRequest())
        }

        func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
            guard let adView = adView else { return }
            adView.nativeAd = nativeAd
            isLoading = false
            isFailed = false
        }

        func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
            isLoading = false
            isFailed = true
        }
    }
}
#endif
