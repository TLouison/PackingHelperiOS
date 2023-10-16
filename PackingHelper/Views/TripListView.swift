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
    @Query var trips: [Trip]
    
    @State private var path: [Trip] = []
    
    @State private var isShowingAddTripSheet: Bool = false
    @State private var isShowingCompletedTrips: Bool = false
    @State private var isCompletedTripDropdownOpen: Bool = false
    
    @State var visibleTripsSymbol: Symbol = .upcoming
    
    var upcomingTrips: [Trip] {
        return trips.filter { $0.complete == false }
    }
    
    var completedTrips: [Trip] {
        return trips.filter { $0.complete == true }
    }
    
    @ViewBuilder func TripListRow(_ trips: [Trip]) -> some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(trips) { trip in
                    TripListRowView(path: $path, trip: trip, height: 400)
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1.0 : 0.8)
                                .scaleEffect(y: phase.isIdentity ? 1.0 : 0.9)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 24, for: .scrollContent)
        .scrollTargetBehavior(.paging)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if isShowingCompletedTrips {
                    VStack(alignment: .leading) {
                        Text("Completed Trips")
                            .font(.largeTitle)
                            .padding(.horizontal)
                        
                        TripListRow(completedTrips)
                    }
                    .transition(.pushAndPull(.leading))
                } else {
                    VStack(alignment: .leading) {
                        Text("Upcoming Trips")
                            .font(.largeTitle)
                            .padding(.horizontal)
                        
                        TripListRow(upcomingTrips)
                    }
                    .transition(.pushAndPull(.trailing))
                }
            }
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .sheet(isPresented: $isShowingAddTripSheet) {
                TripEditView(trip: nil)
            }
            .overlay {
                if trips.isEmpty {
                    ContentUnavailableView {
                        Label("No Trips", systemImage: "airplane")
                    } description: {
                        Text("Add a trip to get started with your packing!")
                            .frame(maxWidth: .infinity)
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
    
    enum Symbol: Hashable, CaseIterable {
           case completed, upcoming

           var name: String {
               switch self {
               case .completed: return "airplane.arrival"
               case .upcoming: return "airplane.departure"
               }
           }
       }
}

#Preview {
    TripListView()
}
