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
import MapKit

struct TripEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var complete: Bool = false
    
    @State private var beginDate = Date.now
    @State private var endDate = Date.now
    
    @State private var destination: TripDestination = TripDestination.sampleData
    
    let trip: Trip?
    
    private var editorTitle: String {
        trip == nil ? "Add Trip" : "Edit Trip"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        TextField("Name", text: $name)
                        Toggle("Completed", isOn: $complete.animation())
                    } header: {
                        Text("Basic Details")
                    }
                    
                    Section {
                        HStack {
                            HStack {
                                Image(systemName: Trip.startIcon)
                                VStack {
                                    Text("Begins")
                                    DatePicker("Trip Begins", selection: $beginDate, displayedComponents: [.date])
                                }
                            }
                            Spacer()
                            HStack {
                                Image(systemName: Trip.endIcon)
                                VStack {
                                    Text("Ends")
                                    DatePicker("Trip Ends", selection: $endDate, displayedComponents: [.date])
                                }
                            }
                        }
                        .imageScale(.large)
                        .labelsHidden()
                    } header: {
                        Text("Trip Dates")
                    }
                    
                    Section {
                        ZStack {
                            NavigationLink {
                                LocationSelectionView(locationService: LocationService(), destination: $destination)
                            } label: {
                                EmptyView()
                            }
                            VStack {
                                HStack {
                                    Text(destination.name).bold()
                                    Spacer()
                                    Image(systemName: "magnifyingglass.circle")
                                        .foregroundStyle(.blue.gradient)
                                }
                                
                                Map(position: destination.mapCameraPositionBinding)
                                    .frame(height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    } header: {
                        Text("Trip Destination")
                    }
                }
//                .background(.background)
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
                    
                    if let d = trip.destination {
                        destination = d
                    }
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
            
            trip.destination = destination
        } else {
            let newTrip = Trip(name: name, complete: complete, beginDate: beginDate, endDate: endDate)
            newTrip.destination = destination
            newTrip.packingList = PackingList()
            
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
