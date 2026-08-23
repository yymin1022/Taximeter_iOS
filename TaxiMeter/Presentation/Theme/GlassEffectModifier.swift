//
//  GlassEffectModifier.swift
//  TaxiMeter
//

import SwiftUI

public struct GlassEffectShapeModifier<S: Shape>: ViewModifier {
    public let shape: S

    public init(shape: S) {
        self.shape = shape
    }

    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect()
                .clipShape(shape)
        } else {
            content.background(.ultraThinMaterial, in: shape)
        }
    }
}

public struct GlassEffectModifier: ViewModifier {
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect()
        } else {
            content.background(.ultraThinMaterial)
        }
    }
}

extension View {
    public func applyGlassEffect<S: Shape>(in shape: S) -> some View {
        modifier(GlassEffectShapeModifier(shape: shape))
    }

    public func applyGlassEffect() -> some View {
        modifier(GlassEffectModifier())
    }
}
