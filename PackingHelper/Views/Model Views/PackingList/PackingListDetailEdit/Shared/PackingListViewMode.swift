//
//  PackingListViewMode.swift
//  PackingHelper
//
//  Created by Claude on 1/11/26.
//

import SwiftUI
import SwiftData

enum PackingListViewMode: String {
    case unified
    case sectioned
}

enum PackingListContext {
    case trip(Trip)
    case singleList(PackingList)

    var trip: Trip? {
        if case .trip(let trip) = self {
            return trip
        }
        return nil
    }

    var singleList: PackingList? {
        if case .singleList(let list) = self {
            return list
        }
        return nil
    }

    var isTrip: Bool {
        if case .trip = self {
            return true
        }
        return false
    }

    var isSingleList: Bool {
        if case .singleList = self {
            return true
        }
        return false
    }
}
