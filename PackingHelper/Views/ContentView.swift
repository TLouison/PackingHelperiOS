//
//  ContentView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    NavigationLink("Paraguay Trip", value: "Paraguay")
                }
                .navigationDestination(for: String.self) { val in
                    TripDetailView(tripName: val)
                }
            }
        }
        .navigationTitle("Upcoming Trips")
    }
}

#Preview {
    ContentView()
}
