//
//  AdUnits.swift
//  TaxiMeter
//
//  Created by 유용민 on 8/27/26.
//

import Foundation

public struct AdUnits {
    #if DEBUG
    public static let bannerAdUnitId = "ca-app-pub-3940256099942544/2934735716"
    public static let nativeAdUnitId = "ca-app-pub-3940256099942544/3986566890"
    #else
    public static let bannerAdUnitId = "ca-app-pub-7726147556907333/4284939873"
    public static let nativeAdUnitId = "ca-app-pub-7726147556907333/2971858203"
    #endif
}
