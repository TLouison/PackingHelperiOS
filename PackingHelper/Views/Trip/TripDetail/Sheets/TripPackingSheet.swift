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
    
    @State private var packedItemCount: Int = 0
    @State private var gaugeLevel: Double = 0.0
    
    var body: some View {
        VStack {
            HStack {
                Text("Packing Lists")
                    .font(.title)
                Spacer()
                
                if !packingList.items.isEmpty {
                    HStack {
                        Image(systemName: "suitcase.rolling")
                        
                        Gauge(value: Double(gaugeLevel), in: 0...Double(packingList.items.count)) {
                            EmptyView()
                        }
                        .onChange(of: packingList.items, initial: true) {
                            packedItemCount = packingList.packedItems.count
                            gaugeLevel = Double(packedItemCount)
                        }
                        .frame(maxWidth: 60)
                    }
                }
            }
            
            Divider()
            
            HStack {
                NavigationLink {
                    PackingListEditView(packingList: packingList)
                        .padding(.vertical)
                } label: {
                    Label("Packing", systemImage: "suitcase.rolling.fill")
                }
                .frame(height: 30)
                .frame(maxWidth: .infinity)
                .roundedBox(background: .ultraThickMaterial)
                .shadow(radius: defaultShadowRadius)
                
                NavigationLink {
                    PackingListEditView(packingList: packingList, isDayOf: true)
                        .padding(.vertical)
                } label: {
                    Label("Day-Of", systemImage: "sun.horizon")
                }
                .frame(height: 30)
                .frame(maxWidth: .infinity)
                .roundedBox(background: .ultraThickMaterial)
                .shadow(radius: defaultShadowRadius)
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
