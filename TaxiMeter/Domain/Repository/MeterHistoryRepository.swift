//
//  MeterHistoryRepository.swift
//  TaxiMeter
//

import Foundation

/// Meter History Repository Interface
public protocol MeterHistoryRepository: Sendable {
    // Insert new history
    func insertHistory(_ history: MeterHistory) async

    // Get all histories ordered by timestamp descending
    func getAllHistories() -> AsyncStream<[MeterHistory]>
}
