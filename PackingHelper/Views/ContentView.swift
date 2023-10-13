//
//  ContentView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var trips: [Trip]
    
    @State private var isShowingAddTripSheet: Bool = false
    @State private var isCompletedTripDropdownOpen: Bool = false
    
    var upcomingTrips: [Trip] {
        return trips.filter { $0.complete == false }
    }
    
    var completedTrips: [Trip] {
        return trips.filter { $0.complete == true }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if !upcomingTrips.isEmpty {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Text("Upcoming Trips").font(.title)
                        ForEach(upcomingTrips) { trip in
                            Map(initialPosition: trip.destinationMapCameraPosition, interactionModes: [])
                                .opacity(0.5)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay {
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        NavigationLink(trip.name, value: trip)
                                            .isDetailLink(true)
                                            .padding()
                                            .background(.thinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .padding()
                                    }
                                }
                                .frame(height: 80)
                                .shadow(radius: 4)
                                .padding(.vertical, 10)
                        }
                    }
                }
//
//                if !isCompletedTripDropdownOpen {
                    Spacer()
//                }
                
                if !completedTrips.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        if !isCompletedTripDropdownOpen {
                            Spacer()
                        }
                        
                        HStack {
                            Text("Completed Trips").font(.title)
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    isCompletedTripDropdownOpen.toggle()
                                }
                            } label: {
                                Label("Toggle Completed Trip Dropdown", systemImage: "chevron.forward")
                                    .labelStyle(.iconOnly)
                                    .rotationEffect(isCompletedTripDropdownOpen ? .degrees(90) : .zero)
                            }
                        }
                        if isCompletedTripDropdownOpen {
                            ForEach(completedTrips) { trip in
                                NavigationLink(trip.name, value: trip)
                            }
                        }
                    }
                    if !isCompletedTripDropdownOpen {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .overlay {
                if trips.isEmpty {
                    ContentUnavailableView {
                        Label("No Trips", systemImage: "airplane")
                    } description: {
                        Text("Add a trip to track your packing.")
                    } actions: {
                        Button("Create Trip", systemImage: "folder.badge.plus") {
                            isShowingAddTripSheet.toggle()
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddTripSheet) {
                TripEditView(trip: nil)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddTripSheet.toggle()
                    } label: {
                        Label("Add Trip", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .toolbarBackground(.hidden)
        }
    }
}

#Preview {
    ContentView()
}
