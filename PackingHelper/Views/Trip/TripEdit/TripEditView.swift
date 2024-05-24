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
    
    @State private var tripType: TripType = .plane
    
    @State private var origin: TripLocation = TripLocation.sampleOrigin
    @State private var destination: TripLocation = TripLocation.sampleDestination
    
    @Query(
        filter: #Predicate<PackingList>{ $0.template == true },
        sort: \.created, order: .reverse,
        animation: .snappy
    ) private var defaultPackingListOptions: [PackingList]
    @State private var defaultPackingList: PackingList? = nil
    
    let trip: Trip?
    
    private var editorTitle: String {
        trip == nil ? "Add Trip" : "Edit Trip"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        VStack {
                            TextField("Name", text: $name)
                            
                            Picker("Type", selection: $tripType) {
                                ForEach(TripType.allCases, id: \.name) { type in
                                    Text(type.name).tag(type)
                                }
                            }
                        }
                    } header: {
                        Text("Basic Details")
                    }
                    
                    Section {
                        VStack {
                            HStack {
                                tripType.startLabel(text: "")
                                VStack {
                                    Text("Begins")
                                    DatePicker("Trip Begins", selection: $beginDate, displayedComponents: [.date])
                                        .onChange(of: beginDate) {
                                            if endDate < beginDate {
                                                endDate = beginDate
                                            }
                                        }
                                }
                            }
                            Spacer()
                            HStack {
                                tripType.endLabel(text: "")
                                VStack {
                                    Text("Ends")
                                    DatePicker(
                                        "Trip Ends",
                                        selection: $endDate,
                                        in: beginDate...,
                                        displayedComponents: [.date]
                                    )
                                }
                            }
                        }
                        .imageScale(.large)
                        .labelsHidden()
                    } header: {
                        Text("Trip Dates")
                    }
                    
                    Section {
                        LocationSelectionBoxView(location: $origin, title: "Find Origin")
                    } header: {
                        Text("Trip Origin")
                    }
                    
                    Section {
                        LocationSelectionBoxView(location: $destination, title: "Find Destination")
                    } header: {
                        Text("Trip Destination")
                    }
                    
                    if trip == nil {
                        Section {
                            Picker("Default Packing List", selection: $defaultPackingList) {
                                Text("No Default").tag(nil as PackingList?)
                                ForEach(defaultPackingListOptions) { packingList in
                                    Text(packingList.name)
                                        .tag(packingList as PackingList?)
                                }
                            }
                        } header: {
                            Text("Default Packing List")
                        } footer: {
                            Text("Adding a default packing list will automatically add the items from that packing list to this trip as a starting point. You can create these lists on the main screen.")
                        }
                    }
                }

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
                    
                    tripType = trip.type
                    
                    origin = trip.origin!
                    destination = trip.destination!
                }
            }
        }
    }
    
    private var formIsValid: Bool {
        return name != "" && beginDate <= endDate
    }
    
    private func save() {
        if let trip {
            trip.name = name
            
            trip.beginDate = beginDate
            trip.endDate = endDate
            
            trip.type = tripType
            
            trip.origin = origin
            trip.destination = destination
        } else {
            let newTrip = Trip(name: name, beginDate: beginDate, endDate: endDate, type: tripType, origin: origin, destination: destination)
            
            if let defaultPackingList {
                let defaultList = PackingList.copyForTrip(defaultPackingList)
                defaultList.tripID = newTrip.id
                newTrip.lists.append(defaultList)
            }
            
            modelContext.insert(newTrip)
        }
    }
    
    private func deleteTrip() {
        modelContext.delete(trip!)
        dismiss()
    }
}
