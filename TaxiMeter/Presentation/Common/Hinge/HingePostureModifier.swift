//
//  HingePostureModifier.swift
//  TaxiMeter
//

import SwiftUI

private struct HingePostureEnvironmentKey: EnvironmentKey {
    static let defaultValue: HingePosture = .unavailable
}

extension EnvironmentValues {
    /// 현재 디바이스의 힌지 각도 및 폴딩 상태
    public var hingePosture: HingePosture {
        get { self[HingePostureEnvironmentKey.self] }
        set { self[HingePostureEnvironmentKey.self] = newValue }
    }
}

/// 힌지 상태 변경 이벤트를 감지하는 ViewModifier
public struct OnHingePostureChangeModifier: ViewModifier {
    let action: (HingePosture) -> Void

    public func body(content: Content) -> some View {
        content.background(
            HingeInteractionBridgeView(onHingeChange: action)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
        )
    }
}

/// 힌지 상태를 관찰하여 하위 뷰에 Environment로 주입하는 ViewModifier
public struct ObserveHingePostureModifier: ViewModifier {
    @State private var currentPosture: HingePosture = .unavailable

    public func body(content: Content) -> some View {
        content
            .environment(\.hingePosture, currentPosture)
            .background(
                HingeInteractionBridgeView { newPosture in
                    if currentPosture != newPosture {
                        currentPosture = newPosture
                    }
                }
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
            )
    }
}

extension View {
    /// 힌지 상태가 변경될 때 호출되는 동작을 등록합니다.
    public func onHingePostureChange(perform action: @escaping (HingePosture) -> Void) -> some View {
        modifier(OnHingePostureChangeModifier(action: action))
    }

    /// 뷰 계층 전체에 @Environment(\.hingePosture)를 주입할 수 있도록 힌지 상태를 관찰합니다.
    public func observeHingePosture() -> some View {
        modifier(ObserveHingePostureModifier())
    }
}
