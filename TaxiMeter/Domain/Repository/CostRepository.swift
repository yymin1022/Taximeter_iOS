//
//  CostRepository.swift
//  TaxiMeter
//

import Foundation

/// Cost Repository Interface
/// - Get cost info for each region
/// - Update to latest cost info
public protocol CostRepository: Sendable {
    // Get Local / Remote cost version
    func getLocalVersion() -> String
    func getRemoteVersion() async -> String?

    // Update local cost info to latest version
    func updateToLatest() async -> Bool

    // Get cost info for specific region
    func getCostInfo(regionKey: String) -> CostInfo?
}
