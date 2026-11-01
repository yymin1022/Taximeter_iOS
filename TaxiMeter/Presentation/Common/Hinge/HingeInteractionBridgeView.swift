//
//  HingeInteractionBridgeView.swift
//  TaxiMeter
//

import SwiftUI
import UIKit

/// SwiftUI 뷰 계층에서 UIKit의 UIHingeInteraction을 관찰하는 브릿지 뷰
public struct HingeInteractionBridgeView: UIViewRepresentable {
    private let onHingeChange: (HingePosture) -> Void

    public init(onHingeChange: @escaping (HingePosture) -> Void) {
        self.onHingeChange = onHingeChange
    }

    public func makeUIView(context: Context) -> HingeObserverContainerView {
        let view = HingeObserverContainerView()
        view.onHingeChange = onHingeChange
        return view
    }

    public func updateUIView(_ uiView: HingeObserverContainerView, context: Context) {
        uiView.onHingeChange = onHingeChange
    }
}

/// UIHingeInteraction 이벤트를 수신하여 콜백으로 전달하는 컨테이너 뷰
public final class HingeObserverContainerView: UIView {
    var onHingeChange: ((HingePosture) -> Void)?
    private var hingeInteraction: Any?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        attachHingeInteractionIfNeeded()
    }

    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    private func attachHingeInteractionIfNeeded() {
        guard window != nil else { return }

        if #available(iOS 27.1, tvOS 27.1, visionOS 27.1, *) {
            guard hingeInteraction == nil else { return }
            let interaction = UIHingeInteraction { [weak self] _, update in
                guard let self else { return }
                let posture = HingePosture(uiHinge: update.hinge)
                DispatchQueue.main.async {
                    self.onHingeChange?(posture)
                }
            }
            addInteraction(interaction)
            self.hingeInteraction = interaction
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.onHingeChange?(.unavailable)
            }
        }
    }
}
