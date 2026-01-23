//
//  CalendarUtilities.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/22/23.
//

import Foundation

let SECONDS_IN_MINUTE: Double = 60
let MINUTES_IN_HOUR: Double = 60
let HOURS_IN_DAY: Double = 24
let SECONDS_IN_DAY: Double = SECONDS_IN_MINUTE * MINUTES_IN_HOUR * HOURS_IN_DAY

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day ?? 0
    }
}
