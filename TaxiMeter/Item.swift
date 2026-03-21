//
//  Item.swift
//  TaxiMeter
//
//  Created by 유용민 on 3/21/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
