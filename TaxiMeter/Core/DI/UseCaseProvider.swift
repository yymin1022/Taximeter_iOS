//
//  UseCaseProvider.swift
//  TaxiMeter
//

import Foundation

/// Provider for UseCases
public final class UseCaseProvider: @unchecked Sendable {
    public static let shared = UseCaseProvider()

    public let updateCostInfoUseCase: UpdateCostInfoUseCase
    public let observeSpeedUseCase: ObserveSpeedUseCase
    public let calculateMeterCostUseCase: CalculateMeterCostUseCase

    private init() {
        self.updateCostInfoUseCase = UpdateCostInfoUseCase()

        let locationRepository = RepositoryProvider.shared.locationRepository
        let observeSpeedUseCase = ObserveSpeedUseCase(locationRepository: locationRepository)
        self.observeSpeedUseCase = observeSpeedUseCase
        self.calculateMeterCostUseCase = CalculateMeterCostUseCase(observeSpeedUseCase: observeSpeedUseCase)
    }
}
