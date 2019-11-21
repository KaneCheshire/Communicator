//
//  CompDataSource.swift
//  WatchExample Extension
//
//  Created by Kane Cheshire on 19/11/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import WatchKit

final class CompDataSource: NSObject, CLKComplicationDataSource {
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        handler(nil)
    }
    
}
