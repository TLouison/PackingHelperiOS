//
//  SortOrder.swift
//  PackingHelper
//
//  Created by Todd Louison on 1/30/25.
//

import SwiftUI

protocol SortOrderOption: CaseIterable, RawRepresentable, Hashable, Identifiable where RawValue == String {
    var name: String { get }
    var id: String { get }
    var `default`: String { get }
}

enum BaseSortOrder: String {
    case byDate = "byDate"
    case byUser = "byUser"
    case byNameAsc = "byNameAsc"
    case byNameDesc = "byNameDesc"
    
    var name: String {
        switch self {
        case .byDate: "By Created Date"
        case .byNameAsc: "By Name (A-Z)"
        case .byNameDesc: "By Name (Z-A)"
        case .byUser: "By User (A-Z)"
        }
    }
}

struct SortOrderPicker<Order: SortOrderOption>: View {
    @Binding var selection: Order
    
    var body: some View {
        Picker("Sort By", selection: $selection) {
            ForEach(Array(Order.allCases)) { order in
                Text(order.name)
                    .tag(order)
            }
        }
    }
}

