//
//  BannerAdView.swift
//  TaxiMeter
//

import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

public struct BannerAdView: View {
    public let adUnitId: String

    @State private var isLoading: Bool = true
    @State private var isFailed: Bool = false
    @State private var fallbackAd: FallbackAd = FallbackAdDefs.getRandomAd()

    public init(adUnitId: String = AdUnits.bannerAdUnitId) {
        self.adUnitId = adUnitId
    }

    public var body: some View {
        ZStack {
            #if canImport(GoogleMobileAds)
            BannerViewRepresentable(
                adUnitId: adUnitId,
                isLoading: $isLoading,
                isFailed: $isFailed
            )
            .opacity(!isLoading && !isFailed ? 1 : 0)
            #endif

            if isLoading || isFailed {
                FallbackAdContent(fallbackAd: fallbackAd)
            }
        }
        .frame(height: 50)
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
private struct BannerViewRepresentable: UIViewRepresentable {
    let adUnitId: String
    @Binding var isLoading: Bool
    @Binding var isFailed: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, isFailed: $isFailed)
    }

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitId
        bannerView.delegate = context.coordinator
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController {
            bannerView.rootViewController = rootVC
        }
        bannerView.load(GADRequest())
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    class Coordinator: NSObject, GADBannerViewDelegate {
        @Binding var isLoading: Bool
        @Binding var isFailed: Bool

        init(isLoading: Binding<Bool>, isFailed: Binding<Bool>) {
            self._isLoading = isLoading
            self._isFailed = isFailed
        }

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            isLoading = false
            isFailed = false
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            isLoading = false
            isFailed = true
        }
    }
}
#endif
