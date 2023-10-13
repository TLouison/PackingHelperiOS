//
//  TripDetailView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI
import MapKit

struct TripDetailView: View {
    var tripName: String
    
    var body: some View {
        Map()
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(tripName).font(.headline)
                            Text("Starting On December 11, 2023").font(.subheadline).bold()
                        }
                        Spacer()
                        Image(systemName: "airplane.departure")
                    }
                    Spacer()
                }
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.background)
                        .ignoresSafeArea(edges: .bottom)
                }
                .padding()
                .presentationDetents([.height(200), .medium, .large])
                .presentationDragIndicator(.automatic)
            }
    }
}

#Preview {
    TripDetailView(tripName: "Paraguay")
}
