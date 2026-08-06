//
//  ShowDialog.swift
//  TaxiMeter
//

import Foundation

public enum ShowDialog: Equatable {
    case nothing
    case radioSelectDialog(title: String, items: [String], selectedIndex: Int, onComplete: (Int) -> Void)
    case customCostDialog(title: String, onComplete: (CostInfo) -> Void)

    public static func == (lhs: ShowDialog, rhs: ShowDialog) -> Bool {
        switch (lhs, rhs) {
        case (.nothing, .nothing):
            return true
        case let (.radioSelectDialog(title1, items1, idx1, _), .radioSelectDialog(title2, items2, idx2, _)):
            return title1 == title2 && items1 == items2 && idx1 == idx2
        case let (.customCostDialog(title1, _), .customCostDialog(title2, _)):
            return title1 == title2
        default:
            return false
        }
    }
}
