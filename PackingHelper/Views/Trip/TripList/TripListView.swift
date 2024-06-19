//
//  TripListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import SwiftUI
import SwiftData
import MapKit

@Observable class TripsViewModel {
    var path: NavigationPath = .init()
}

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TripsViewModel()
    
    @State private var isShowingAddTripSheet: Bool = false
    @State private var isShowingCompletedTrips: Bool = false
    @State private var isCompletedTripDropdownOpen: Bool = false
    
    @State private var visibleTripsSymbol: Symbol = .upcoming
    
    private static var now: Date { Date.now }
    @Query(FetchDescriptor(
        predicate: #Predicate<Trip>{ $0.endDate > now },
        sortBy: [SortDescriptor(\.startDate, order: .forward)]
    ),
           animation: .snappy
    ) var upcomingTrips: [Trip]
    
    @Query(FetchDescriptor(
        predicate: #Predicate<Trip>{ $0.endDate <= now },
        sortBy: [SortDescriptor(\.startDate, order: .forward)]
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
    
    var viewTitle: String {
        if isShowingCompletedTrips && !completedTrips.isEmpty {
            return "Completed Trips"
        } else if !upcomingTrips.isEmpty {
            return "Upcoming Trips"
        } else {
            return ""
        }
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack {
                if !completedTrips.isEmpty && isShowingCompletedTrips {
                    TripListScrollView(path: $viewModel.path, trips: completedTrips)
                        .transition(.pushAndPull(.leading))
                } else if !upcomingTrips.isEmpty {
                    TripListScrollView(path: $viewModel.path, trips: upcomingTrips)
                        .transition(.pushAndPull(.trailing))
                } else if upcomingTrips.isEmpty && !completedTrips.isEmpty {
                    ContentUnavailableView {
                        TripType.plane.startLabel(text: "No Upcoming Trips")
                    } description: {
                        Text("You've completed all of your trips! Add a new one to start packing.")
                    } actions: {
                        Button("Create Trip", systemImage: "folder.badge.plus") {
                            isShowingAddTripSheet.toggle()
                        }
                    }
                } else {
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
            }
            .navigationTitle(viewTitle)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .sheet(isPresented: $isShowingAddTripSheet) {
                TripEditView(trip: nil)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    if !completedTrips.isEmpty {
                        Button {
                            withAnimation {
                                toggleVisibleTrips()
                            }
                        } label: {
                            
                            Image(systemName: visibleTripsSymbol.name)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(visibleTripsSymbol == .completed ? Color.green.gradient : Color.accentColor.gradient)
                                .contentTransition(
                                    .symbolEffect(.replace.downUp.byLayer)
                                )
                                .symbolEffect(.bounce, value: visibleTripsSymbol == .completed ? upcomingTrips.count : completedTrips.count)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            isShowingAddTripSheet.toggle()
                        }
                    } label: {
                        Label("Add Trip", systemImage: "plus.circle")
                            .labelStyle(.iconOnly)
                            .symbolEffect(.bounce.down, value: isShowingAddTripSheet)
                    }
                }
            }
            .toolbarBackground(.hidden)
        }
        .environment(viewModel)
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
