//
//  SFSafariView.swift
//  TaxiMeter
//

import SwiftUI
import SafariServices

public struct SFSafariView: UIViewControllerRepresentable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        return SFSafariViewController(url: url, configuration: configuration)
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
