//
//  UpdateCostInfoResult.swift
//  TaxiMeter
//

import Foundation

/// Result of UpdateCostInfoUseCase execution
public enum UpdateCostInfoResult: Equatable, Sendable {
    case upToDate
    case success
    case failure
    case canceled
}
