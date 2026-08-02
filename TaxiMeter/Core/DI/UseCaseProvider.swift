//
//  UseCaseProvider.swift
//  TaxiMeter
//

import Foundation

/// Provider for UseCases
public final class UseCaseProvider {
    public static let shared = UseCaseProvider()

    public let updateCostInfoUseCase: UpdateCostInfoUseCase

    private init() {
        self.updateCostInfoUseCase = UpdateCostInfoUseCase()
    }
}
