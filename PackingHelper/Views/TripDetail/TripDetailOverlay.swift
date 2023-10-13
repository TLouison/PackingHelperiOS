//
//  TripDetailOverlay.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI

struct TripDetailOverlay: View {
    @Environment(\.dismiss) var dismiss
    var trip: Trip
    
    @Binding var isShowingTripDetailSheet: Bool
    @Binding var isShowingPackingDetailSheet: Bool
    @Binding var isShowingTripSettingsSheet: Bool
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back to Menu", systemImage: "chevron.backward")
                            .labelStyle(.iconOnly)
                            .frame(width: 20, height: 20)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Spacer()
                    
                    Button {
                        isShowingTripSettingsSheet.toggle()
                    } label: {
                        Label("Trip Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                            .frame(width: 20, height: 20)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                VStack {
                    Text(trip.name).font(.title)
                    
                    HStack {
                        Image(systemName: "airplane.departure")
                        Text("Departing on December 11, 2023").font(.headline).bold()
                        
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            Spacer()
            
            VStack {
                Text("Details")
                    .font(.headline)
                
                HStack {
                    Button("Trip") {
                        isShowingTripDetailSheet.toggle()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.background.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Button("Packing") {
                        isShowingPackingDetailSheet.toggle()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.background.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }
}
