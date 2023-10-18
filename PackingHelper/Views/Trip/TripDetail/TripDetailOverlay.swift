//
//  TripDetailOverlay.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI

struct TripDetailOverlay: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var trip: Trip
    
    @Binding var isShowingTripDetailSheet: Bool
    @Binding var isShowingPackingDetailSheet: Bool
    @Binding var isShowingTripSettingsSheet: Bool
    
    @State private var showTitle: Bool = false
    @State private var showSubtitle: Bool = false
    
    struct RoundedBox: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    @ViewBuilder func departureInfo() -> some View {
        let now = Date.now
        let beginDateString = trip.beginDate.formatted(date: .abbreviated, time: .omitted)
        let endDateString = trip.endDate.formatted(date: .abbreviated, time: .omitted)
        
        HStack {
            if now < trip.beginDate {
                Label("Departing on \(beginDateString)", systemImage: "airplane.departure")
            } else if now == trip.beginDate {
                Label("Departing today.", systemImage: "airplane.departure")
            } else if  trip.beginDate < now && now < trip.endDate {
                Label("Returning on \(endDateString)", systemImage: "airplane")
            } else if now == trip.endDate {
                Label("Trip ended today", systemImage: "airplane.arrival")
            } else if now > trip.endDate{
                Label("Returned on \(endDateString)", systemImage: "airplane.arrival")
            }
        }
    }
    
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
                    .modifier(RoundedBox())
                    .shadow(radius: 4)
                    
                    
                    Spacer()
                    
                    Button {
                        isShowingTripSettingsSheet.toggle()
                    } label: {
                        Label("Trip Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                            .frame(width: 20, height: 20)
                    }
                    .modifier(RoundedBox())
                    .shadow(radius: 4)
                }
                
                if showTitle {
                    VStack {
                        Text(trip.name).font(.largeTitle)
                            .frame(maxWidth: .infinity)
                            .modifier(RoundedBox())
                            .shadow(radius: 4)
                            .onAppear {
                                withAnimation {
                                    showSubtitle = true
                                }
                            }
                        
                        if showSubtitle {
                            departureInfo()
                                .frame(maxWidth: .infinity)
                                .modifier(RoundedBox())
                                .shadow(radius: 4)
                                .transition(.opacity)
                        }
                    }
                    .transition(.opacity)
                }
            }
            
            Spacer()
            
            VStack {
                Text("Details")
                    .font(.headline)
                
                HStack {
                    Button {
                        isShowingTripDetailSheet.toggle()
                    } label: {
                        Label("Trip", systemImage: "list.clipboard")
                    }
                    .frame(maxWidth: .infinity)
                    .modifier(RoundedBox())
                    
                    Button {
                        isShowingPackingDetailSheet.toggle()
                    } label: {
                        Label("Packing", systemImage: "bag")
                    }
                    .frame(maxWidth: .infinity)
                    .modifier(RoundedBox())
                }
            }
            .frame(maxWidth: .infinity)
            .modifier(RoundedBox())
            .shadow(radius: 4)
        }
        .padding()
        .onAppear {
            withAnimation {
                showTitle = true
            }
        }
    }
}
