//
//  TripListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import SwiftUI
import SwiftData
import MapKit

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var path: [Trip] = []
    
    @State private var isShowingAddTripSheet: Bool = false
    @State private var isShowingCompletedTrips: Bool = false
    @State private var isCompletedTripDropdownOpen: Bool = false
    
    @State private var visibleTripsSymbol: Symbol = .upcoming
    
    private static var now: Date { Date.now }
    @Query(FetchDescriptor(
        predicate: #Predicate<Trip>{ $0.endDate > now },
        sortBy: [SortDescriptor(\.name, order: .forward)]
    ),
           animation: .snappy
    ) var upcomingTrips: [Trip]
    
    @Query(FetchDescriptor(
        predicate: #Predicate<Trip>{ $0.endDate <= now },
        sortBy: [SortDescriptor(\.name, order: .forward)]
    ),
           animation: .snappy
    ) var completedTrips: [Trip]
    
    enum Symbol: Hashable, CaseIterable {
        case completed, upcoming
        
        var name: String {
            switch self {
            case .completed: return "airplane.arrival"
            case .upcoming: return "airplane.departure"
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if !completedTrips.isEmpty && isShowingCompletedTrips {
                    VStack(alignment: .leading) {
                        Text("Completed Trips")
                            .font(.largeTitle)
                            .padding(.horizontal)
                        
                        TripListScrollView(path: $path, trips: completedTrips)
                    }
                    .transition(.pushAndPull(.leading))
                } else if !upcomingTrips.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Upcoming Trips")
                            .font(.largeTitle)
                            .padding(.horizontal)
                        
                        TripListScrollView(path: $path, trips: upcomingTrips)
                    }
                    .transition(.pushAndPull(.trailing))
                } else {
                    ContentUnavailableView {
                        Label("No Upcoming Trips", systemImage: Trip.startIcon)
                    } description: {
                        Text("You've completed all of your trips! Add a new one to start packing.")
                        //                                .frame(maxWidth: .infinity)
                    } actions: {
                        Button("Create Trip", systemImage: "folder.badge.plus") {
                            isShowingAddTripSheet.toggle()
                        }
                    }
                }
            }
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .sheet(isPresented: $isShowingAddTripSheet) {
                TripEditView(trip: nil)
            }
            .overlay {
                if completedTrips.isEmpty && upcomingTrips.isEmpty{
                    ContentUnavailableView {
                        Label("No Trips", systemImage: "airplane")
                    } description: {
                        Text("Add a trip to get started with your packing!")
                    } actions: {
                        Button("Create Trip", systemImage: "folder.badge.plus") {
                            isShowingAddTripSheet.toggle()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            toggleVisibleTrips()
                        }
                    } label: {
                        if !completedTrips.isEmpty {
                            Image(systemName: visibleTripsSymbol.name)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(visibleTripsSymbol == .completed ? Color.green.gradient : Color.blue.gradient)
                                .contentTransition(
                                    .symbolEffect(.replace.downUp.byLayer)
                                )
                                .symbolEffect(.bounce, value: visibleTripsSymbol == .completed ? upcomingTrips.count : completedTrips.count)
                        }
                    }
                    
                    Button {
                        isShowingAddTripSheet.toggle()
                    } label: {
                        Label("Add Trip", systemImage: "plus.circle")
                            .labelStyle(.iconOnly)
                            .symbolEffect(.bounce.down, value: isShowingAddTripSheet)
                    }
                }
            }
            .toolbarBackground(.hidden)
        }
    }
    
    func toggleVisibleTrips() {
        isShowingCompletedTrips.toggle()
        // Toggle symbol to other symbol
        visibleTripsSymbol = switch visibleTripsSymbol {
        case .completed: .upcoming
        case .upcoming: .completed
        }
    }
}
