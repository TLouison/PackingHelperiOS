//
//  PackingListApplyDefaultView.swift
//  PackingHelper
//
//  Created by Todd Louison on 11/14/23.
//

import SwiftUI
import SwiftData

struct PackingListApplyDefaultView: View {
    @Environment(\.dismiss) var dismiss
    
    var trip: Trip
    
    @Query(
        filter: #Predicate<PackingList>{ $0.template == true },
        sort: \.created, order: .reverse,
        animation: .snappy
    ) private var defaultPackingListOptions: [PackingList]
    @State private var defaultPackingLists: [PackingList] = []
    
    @State private var selectedUser: User?
    
    var formIsValid: Bool {
        return !defaultPackingLists.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    NavigationLink {
                        PackingListSelectionView(packingLists: $defaultPackingLists)
                    } label: {
                        Label("Select Packing Lists", systemImage: "suitcase")
                    }
                    
                    PackingListPillView(packingLists: defaultPackingLists)
                }
                
                Text("Apply default packing lists to \(trip.name) .")
                    .font(.footnote)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }.disabled(!formIsValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        
    }
    
    func save() {
        if !defaultPackingLists.isEmpty {
            for list in defaultPackingLists {
                let defaultList = PackingList.copyForTrip(list)
                defaultList.tripID = trip.id
                trip.addList(defaultList)
            }
        }
    }
}
