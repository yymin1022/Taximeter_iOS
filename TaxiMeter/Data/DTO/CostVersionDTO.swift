//
//  CostVersionDTO.swift
//  TaxiMeter
//

import Foundation

/// Cost Version DTO
/// - Firebase Firestore -> DTO
public struct CostVersionDTO: Decodable, Sendable {
    public let version: String?

    enum CodingKeys: String, CodingKey {
        case version = "data"
    }

    public init(version: String? = nil) {
        self.version = version
    }
}
