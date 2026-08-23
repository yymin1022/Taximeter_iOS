//
//  ObserveSpeedUseCase.swift
//  TaxiMeter
//

import Foundation

/// Observe Speed UseCase
/// - Emits SpeedData periodically based on MeterDefs.meterUpdateIntervalMs (1000ms)
/// - Calculates speed and distance using GPS updates and Haversine formula
public struct ObserveSpeedUseCase: Sendable {
    private let locationRepository: LocationRepository

    private static let mpsToKph: Double = 3.6
    private static let earthRadiusMeters: Double = 6_371_000.0

    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }

    public func execute() -> AsyncStream<SpeedData> {
        let locationStream = locationRepository.observeUpdate()

        return AsyncStream { continuation in
            let task = Task {
                var lastSpeedData = SpeedData.zero
                var lastLocation: LocationData? = nil
                let lock = NSLock()

                // GPS updates — update last known speed data concurrently
                let gpsTask = Task {
                    for await currentLocation in locationStream {
                        guard !Task.isCancelled else { break }

                        // Ignore outdated GPS locations (older than 10 seconds ago upon start)
                        let nowMillis = Int64(Date().timeIntervalSince1970 * 1000)
                        if abs(nowMillis - currentLocation.timestampMillis) > 10_000 {
                            continue
                        }

                        let calculated = self.calculateSpeedData(prev: lastLocation, current: currentLocation)
                        lock.lock()
                        lastSpeedData = calculated
                        lastLocation = currentLocation
                        lock.unlock()
                    }
                }

                let intervalSeconds = Double(MeterDefs.meterUpdateIntervalMs) / 1000.0
                let intervalNanoseconds = UInt64(MeterDefs.meterUpdateIntervalMs) * 1_000_000

                // Timer ticks — periodically emit SpeedData using last known speed
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: intervalNanoseconds)
                    guard !Task.isCancelled else { break }

                    lock.lock()
                    let currentLast = lastSpeedData
                    lock.unlock()

                    let distanceDelta = (currentLast.speedKph / Self.mpsToKph) * intervalSeconds
                    let tickSpeedData = SpeedData(
                        distanceDeltaMeters: distanceDelta,
                        elapsedDeltaSeconds: intervalSeconds,
                        speedKph: currentLast.speedKph,
                        status: currentLast.status == .gpsError ? .gpsError : .running
                    )

                    continuation.yield(tickSpeedData)
                }

                gpsTask.cancel()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    /// Calculate SpeedData from previous and current LocationData
    /// - Return GPS error state if accuracy is below threshold (accuracyMeters > 50)
    /// - Return zero speed if no previous location
    private func calculateSpeedData(prev: LocationData?, current: LocationData) -> SpeedData {
        if current.accuracyMeters > MeterDefs.gpsAccuracyThreshold || current.accuracyMeters < 0 {
            let elapsedDelta: Double
            if let prev = prev {
                elapsedDelta = Double(current.timestampMillis - prev.timestampMillis) / 1000.0
            } else {
                elapsedDelta = 0.0
            }

            return SpeedData(
                distanceDeltaMeters: 0.0,
                elapsedDeltaSeconds: max(0.0, elapsedDelta),
                speedKph: 0.0,
                status: .gpsError
            )
        }

        guard let prev = prev else {
            return SpeedData.zero
        }

        let elapsedDeltaSeconds = Double(current.timestampMillis - prev.timestampMillis) / 1000.0
        if elapsedDeltaSeconds <= 0 {
            return SpeedData.zero
        }

        let distanceDeltaMeters = haversineDistanceMeters(from: prev, to: current)

        // Use system GPS speed if available (> 0), otherwise calculate from coordinates
        let speedKph: Double
        if current.speedMps > 0 {
            speedKph = current.speedMps * Self.mpsToKph
        } else {
            speedKph = (distanceDeltaMeters / elapsedDeltaSeconds) * Self.mpsToKph
        }

        return SpeedData(
            distanceDeltaMeters: distanceDeltaMeters,
            elapsedDeltaSeconds: elapsedDeltaSeconds,
            speedKph: max(0.0, speedKph),
            status: .running
        )
    }

    /// Calculate distance between two LocationData using Haversine formula
    private func haversineDistanceMeters(from: LocationData, to: LocationData) -> Double {
        let lat1 = from.latitude * .pi / 180.0
        let lat2 = to.latitude * .pi / 180.0
        let dLat = (to.latitude - from.latitude) * .pi / 180.0
        let dLon = (to.longitude - from.longitude) * .pi / 180.0

        let a = sin(dLat / 2.0) * sin(dLat / 2.0) +
                cos(lat1) * cos(lat2) * sin(dLon / 2.0) * sin(dLon / 2.0)

        return Self.earthRadiusMeters * 2.0 * asin(sqrt(a))
    }
}
