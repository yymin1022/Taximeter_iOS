//
//  CalculateMeterCostUseCase.swift
//  TaxiMeter
//

import Foundation

/// Calculate Meter Cost UseCase
/// - Emits MeterState on each speed/location update and surcharge change
/// - Stateless pipeline combining speed stream and dynamic isCityRate stream
public struct CalculateMeterCostUseCase: Sendable {
    private let observeSpeedUseCase: ObserveSpeedUseCase

    private enum MeterUpdateEvent {
        case speed(SpeedData)
        case surcharge(Bool)
    }

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
                var calculator = MeterCostCalculator.newWithCostInfo(costInfo)
                continuation.yield(calculator.toMeterState())

                // Stream multiplexer for Speed and Surcharge events
                let eventStream = AsyncStream<MeterUpdateEvent> { eventContinuation in
                    let speedTask = Task {
                        for await speedData in speedStream {
                            guard !Task.isCancelled else { break }
                            eventContinuation.yield(.speed(speedData))
                        }
                    }

                    let cityRateTask = Task {
                        for await isCityRate in isCityRateStream {
                            guard !Task.isCancelled else { break }
                            eventContinuation.yield(.surcharge(isCityRate))
                        }
                    }

                    eventContinuation.onTermination = { _ in
                        speedTask.cancel()
                        cityRateTask.cancel()
                    }
                }

                for await event in eventStream {
                    guard !Task.isCancelled else { break }
                    switch event {
                    case .speed(let speedData):
                        calculator = calculator.update(speedData: speedData, isCityRate: calculator.isCityRate)
                    case .surcharge(let isCityRate):
                        calculator = calculator.updateSurcharge(isCityRate: isCityRate)
                    }
                    continuation.yield(calculator.toMeterState())
                }
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
