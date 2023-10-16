//
//  TripPackingSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

import SwiftUI

struct TripPackingSheet: View {
    @Binding var packingList: PackingList
    
    var body: some View {
        VStack {
            Grid {
                GridRow {
                    VStack(spacing: 16) {
                        Text("Total")
                            .font(.title2)
                        Text(String(packingList.items.count))
                            .font(.title)
                            .bold()
                    }
                    .frame(width: 120, height: 120)
                    .background(.green.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(spacing: 16) {
                        Text("Packed")
                            .font(.title2)
                        Text(String(packingList.items.count - 5))
                            .font(.title)
                            .bold()
                    }
                    .frame(width: 120, height: 120)
                    .background(.yellow.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .foregroundStyle(.white)
            }
            List {
                ForEach(packingList.items, id: \.self) { item in
                    Text(item)
                }
            }
            Spacer()
            Button("Add Item") {
                packingList.items.append("Good Vibes \(packingList.items.count)")
            }
        }
        .padding(.top, 40)
    }
}

#Preview {
    TripDetailSheet(trip: Trip.sampleTrip)
}
