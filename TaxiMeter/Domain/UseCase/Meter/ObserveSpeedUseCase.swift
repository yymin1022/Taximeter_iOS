//
//  ObserveSpeedUseCase.swift
//  TaxiMeter
//

import Foundation

/// Observe Speed UseCase
/// - Emits SpeedData on each location update
/// - Calculates speed and distance using Haversine formula
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
                var prevLocation: LocationData? = nil

                for await currentLocation in locationStream {
                    let speedData = self.calculateSpeedData(prev: prevLocation, current: currentLocation)
                    prevLocation = currentLocation
                    continuation.yield(speedData)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    /// Calculate SpeedData from previous and current LocationData
    /// - Return GPS error state if accuracy is below threshold (accuracyMeters > 20)
    /// - Return zero speed if no previous location
    private func calculateSpeedData(prev: LocationData?, current: LocationData) -> SpeedData {
        if current.accuracyMeters > MeterDefs.gpsAccuracyThreshold {
            let elapsedDelta: Double
            if let prev = prev {
                elapsedDelta = Double(current.timestampMillis - prev.timestampMillis) / 1000.0
            } else {
                elapsedDelta = 0.0
            }

            return SpeedData(
                distanceDeltaMeters: 0.0,
                elapsedDeltaSeconds: elapsedDelta,
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
        let speedKph = (distanceDeltaMeters / elapsedDeltaSeconds) * Self.mpsToKph

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
