//
//  HingePosture.swift
//  TaxiMeter
//

import CoreGraphics
import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// 힌지 상태 열거형 (iOS 15+ 호환)
public enum HingeStatus: Int, Sendable, Equatable, CaseIterable {
    case unknown = 0
    case closed = 1
    case partiallyOpen = 2
    case fullyOpen = 3
    case unavailable = -1
}

/// 디바이스의 힌지 각도 및 폴딩 자세 모델
public struct HingePosture: Equatable, Sendable {
    /// 힌지 상태 (닫힘, 반열림, 완전열림, 불명, 미지원)
    public let status: HingeStatus

    /// 힌지 각도 (라디안)
    public let angleInRadians: CGFloat

    /// 힌지 각도 (도수 단위)
    public let angleInDegrees: CGFloat

    public init(
        status: HingeStatus,
        angleInRadians: CGFloat,
        angleInDegrees: CGFloat
    ) {
        self.status = status
        self.angleInRadians = angleInRadians
        self.angleInDegrees = angleInDegrees
    }

    /// 힌지를 지원하지 않거나 감지할 수 없는 일반 기기용 기본값
    public static let unavailable = HingePosture(
        status: .unavailable,
        angleInRadians: 0,
        angleInDegrees: 0
    )

    /// 양면 듀얼 디스플레이가 활성화된 펼침 상태 여부
    public var isDualScreenActive: Bool {
        status == .fullyOpen
    }

    /// 거치대/스탠드/랩톱 모드로 반쯤 접힌 상태 여부
    public var isPartiallyOpen: Bool {
        status == .partiallyOpen
    }

    /// 닫혀 있거나 단일 화면으로 동작하는 상태 여부
    public var isFlatOrClosed: Bool {
        status == .closed || status == .unavailable
    }
}

#if canImport(UIKit)
extension HingePosture {
    /// iOS 27.1 UIHinge 객체로부터 HingePosture를 생성합니다.
    @available(iOS 27.1, tvOS 27.1, visionOS 27.1, *)
    public init(uiHinge: UIHinge?) {
        guard let uiHinge else {
            self = .unavailable
            return
        }

        let mappedStatus: HingeStatus
        switch uiHinge.status {
        case .closed:
            mappedStatus = .closed
        case .partiallyOpen:
            mappedStatus = .partiallyOpen
        case .fullyOpen:
            mappedStatus = .fullyOpen
        case .unknown:
            mappedStatus = .unknown
        @unknown default:
            mappedStatus = .unknown
        }

        let radians = uiHinge.angle
        let degrees = radians * 180.0 / .pi
        self.init(
            status: mappedStatus,
            angleInRadians: radians,
            angleInDegrees: degrees
        )
    }
}
#endif
