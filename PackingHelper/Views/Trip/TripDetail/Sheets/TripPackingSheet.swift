//
//  TripPackingSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

import Combine
import SwiftUI
import SwiftData

struct TripPackingSheet: View {
    let packingList: PackingList
    
    var body: some View {
        TripPackingView(packingList: packingList)
            .padding(.vertical)
    }
}

//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Trip.self, TripDestination.self, PackingList.self, configurations: config)
//    
//    let trip = Trip.sampleTrip
//    trip.packingList.items.append(Item(name: "Shirts", count: 7))
//    trip.packingList.items.append(Item(name:"Pants", count: 2))
//    
//    return TripPackingSheet(packingList: .constant(trip.packingList))
//        .modelContainer(container)
//}
