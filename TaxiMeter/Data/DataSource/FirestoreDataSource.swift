//
//  FirestoreDataSource.swift
//  TaxiMeter
//

import Foundation
import FirebaseFirestore

/// Firestore Data Source
/// - Get data from Firestore Document
/// - Return generic Decodable type object
public final class FirestoreDataSource {
    private let firestore: Firestore

    public init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    /// Get Document Data from Firestore
    /// - Parameters:
    ///   - collection: Firestore Collection Name
    ///   - document: Firestore Document Name
    ///   - type: Decodable type to decode
    /// - Returns: Decoded object of type T or nil if failed/missing
    public func getDocument<T: Decodable>(
        collection: String,
        document: String,
        as type: T.Type
    ) async -> T? {
        do {
            let snapshot = try await firestore.collection(collection).document(document).getDocument()
            guard snapshot.exists else { return nil }
            return try snapshot.data(as: type)
        } catch {
            return nil
        }
    }
}
