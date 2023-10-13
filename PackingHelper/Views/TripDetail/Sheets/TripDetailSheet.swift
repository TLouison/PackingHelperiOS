//
//  TripDetailSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI

struct TripDetailSheet: View {
    var trip: Trip
    
    var body: some View {
        VStack {
            Text("Details go here")
        }
    }
}

#Preview {
    TripDetailSheet(trip: Trip.sampleTrip)
}
