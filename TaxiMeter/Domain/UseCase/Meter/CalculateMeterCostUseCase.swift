//
//  CalculateMeterCostUseCase.swift
//  TaxiMeter
//

import Foundation

/// Calculate Meter Cost UseCase
/// - Emits MeterState on each speed/location update
/// - Stateless pipeline combining speed stream and dynamic isCityRate stream
public struct CalculateMeterCostUseCase: Sendable {
    private let observeSpeedUseCase: ObserveSpeedUseCase

    public init(observeSpeedUseCase: ObserveSpeedUseCase) {
        self.observeSpeedUseCase = observeSpeedUseCase
    }

    /// Start meter calculation with dynamic isCityRate stream
    public func execute(
        costInfo: CostInfo,
        isCityRateStream: AsyncStream<Bool>
    ) -> AsyncStream<MeterState> {
        let speedStream = observeSpeedUseCase.execute()

        return AsyncStream { continuation in
            let task = Task {
                var currentIsCityRate = false
                var calculator = MeterCostCalculator.newWithCostInfo(costInfo)
                continuation.yield(calculator.toMeterState())

                let cityRateTask = Task {
                    for await isCityRate in isCityRateStream {
                        currentIsCityRate = isCityRate
                    }
                }

                for await speedData in speedStream {
                    calculator = calculator.update(speedData: speedData, isCityRate: currentIsCityRate)
                    continuation.yield(calculator.toMeterState())
                }

                cityRateTask.cancel()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    /// Overload for static isCityRate
    public func execute(costInfo: CostInfo, isCityRate: Bool) -> AsyncStream<MeterState> {
        let stream = AsyncStream<Bool> { continuation in
            continuation.yield(isCityRate)
        }
        return execute(costInfo: costInfo, isCityRateStream: stream)
    }
}
