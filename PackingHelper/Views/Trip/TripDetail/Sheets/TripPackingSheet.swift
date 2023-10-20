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
    @State var packingList: PackingList
    
    var body: some View {
        VStack {
            VStack {
                Text("Packing Data")
                    .font(.largeTitle)
                
                Divider()
                
                HStack {
                    HStack {
                        Text("Packed")
                            .font(.callout)
                        Text("\(packingList.packedItems.count)")
                            .font(.title)
                    }
                    Divider()
                    HStack {
                        Text("\(packingList.unpackedItems.count)")
                            .font(.title)
                        Text("Remaining")
                            .font(.callout)
                    }
                }
            }
            
            NavigationLink {
                TripPackingView(packingList: $packingList)
                    .padding(.vertical)
            } label: {
                Label("View Packing List", systemImage: "bag.fill")
                    .roundedBox(background: .ultraThickMaterial)
            }
        }
        .roundedBox()
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
