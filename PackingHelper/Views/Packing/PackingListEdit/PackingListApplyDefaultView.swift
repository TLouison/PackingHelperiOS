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
    @State private var defaultPackingList: PackingList? = nil
    
    var formIsValid: Bool {
        return defaultPackingList != nil
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Default Packing List", selection: $defaultPackingList) {
                    Text("No Default").tag(nil as PackingList?)
                    ForEach(defaultPackingListOptions) { packingList in
                        Text(packingList.name)
                            .tag(packingList as PackingList?)
                    }
                }
                .roundedBox()
                Text("Apply default packing list to \(trip.name).")
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
        if let defaultPackingList {
            let defaultList = PackingList.copyForTrip(defaultPackingList)
            defaultList.tripID = trip.id
            trip.lists.append(defaultList)
        }
    }
}
