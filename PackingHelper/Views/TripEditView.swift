//
//  TripEditView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

//
//  ItemEditView.swift
//  ShoppingSaver
//
//  Created by Todd Louison on 9/17/23.
//

import SwiftUI
import SwiftData

struct TripEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var complete: Bool = false
    
    @State private var beginDate = Date.now
    @State private var endDate = Date.now
    
    @State private var latitude = Trip.sampleTrip.destinationLatitude
    @State private var longitude = Trip.sampleTrip.destinationLongitude
    
    let trip: Trip?
    
    private var editorTitle: String {
        trip == nil ? "Add Trip" : "Edit Trip"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Basic Details") {
                        TextField("Name", text: $name)
                        Toggle("Completed", isOn: $complete.animation())
                    }
                    
                    Section("Trip Dates") {
                        DatePicker("Trip Begins", selection: $beginDate, displayedComponents: [.date])
                        DatePicker("Trip Ends", selection: $endDate, displayedComponents: [.date])
                    }
                    
                    Section("Trip Location") {
                        NavigationLink("Select Destination") {
                            LocationSelectionView(locationService: LocationService(), latitude: $latitude, longitude: $longitude)
                        }
                        HStack {
                            Text("Current Coordinates")
                            Text("\(latitude.formatted(.number)), \(longitude.formatted(.number))")
                        }
                        
                    }
                }
                .background(.background)
                if trip != nil {
                    Button(role: .destructive) {
                        deleteTrip()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
                }
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
            .onAppear {
                if let trip {
                    // Edit the incoming item.
                    name = trip.name
                    complete = trip.complete
                    
                    beginDate = trip.beginDate
                    endDate = trip.endDate
                    
                    latitude = trip.destinationLatitude
                    longitude = trip.destinationLongitude
                }
            }
        }
    }
    
    private var formIsValid: Bool {
        return name != ""
    }
    
    private func save() {
        if let trip {
            trip.name = name
            trip.complete = complete
            
            trip.beginDate = beginDate
            trip.endDate = endDate
            
            trip.destinationLatitude = latitude
            trip.destinationLongitude = longitude
        } else {
            let newTrip = Trip(name: name, complete: complete, beginDate: beginDate, endDate: endDate, latitude: latitude, longitude: longitude)
            
            modelContext.insert(newTrip)
        }
    }
    
    private func deleteTrip() {
        modelContext.delete(trip!)
        dismiss()
    }
}

//#Preview {
//    ItemEditView(item: Item(name: "Test Item", price: 19.99, list: ItemList(name: "Test List")), itemList: I)
//}
