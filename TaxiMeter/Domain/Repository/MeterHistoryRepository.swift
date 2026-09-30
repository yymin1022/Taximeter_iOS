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

    // Delete history by ID
    func deleteHistory(id: Int64) async

    // Delete all histories
    func deleteAllHistories() async
}
