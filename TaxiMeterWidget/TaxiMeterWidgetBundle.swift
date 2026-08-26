//
//  TaxiMeterWidgetBundle.swift
//  TaxiMeterWidget
//
//  Created by 유용민 on 8/27/26.
//

import WidgetKit
import SwiftUI

@main
struct TaxiMeterWidgetBundle: WidgetBundle {
    var body: some Widget {
        TaxiMeterWidget()
        TaxiMeterWidgetLiveActivity()
    }
}
