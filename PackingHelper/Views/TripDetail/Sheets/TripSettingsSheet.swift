//
//  TripSettingsView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

import SwiftUI

struct TripSettingsSheet: View {
    var trip: Trip
    
    var body: some View {
        VStack {
            Text("Settings go here")
        }
    }
}

#Preview {
    TripDetailSheet(trip: Trip.sampleTrip)
}

