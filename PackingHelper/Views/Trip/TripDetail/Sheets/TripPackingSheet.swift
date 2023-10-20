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
    
    @State private var gaugeLevel: Double = 0.0
    
    var body: some View {
        VStack {
            HStack {
                Text("Packing Info")
                    .font(.title)
                Spacer()
                
                Gauge(value: Double(gaugeLevel), in: 0...Double(packingList.items.count)) {
                    EmptyView()
                }
                .onChange(of: packingList.items, initial: true) {
                    gaugeLevel = Double(packingList.packedItems.count)
                }
                .frame(maxWidth: 60)
            }
            
            Divider()
            
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
