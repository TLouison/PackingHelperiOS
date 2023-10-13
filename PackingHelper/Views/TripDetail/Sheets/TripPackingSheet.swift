//
//  TripPackingSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

import SwiftUI

struct TripPackingSheet: View {
    var trip: Trip
    
    var body: some View {
        VStack {
            Text("Packing info goes here")
        }
    }
}

#Preview {
    TripDetailSheet(trip: Trip.sampleTrip)
}
