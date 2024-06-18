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
    
    @State private var selectedDates: Set<DateComponents> = []
    @State private var startDate = Date().advanced(by: SECONDS_IN_DAY)
    @State private var endDate = Date().advanced(by: 2*SECONDS_IN_DAY)
    
    @State private var tripType: TripType = .plane
    @State private var accomodation: TripAccomodation = .hotel
    
    @State private var roundTrip: Bool = true
    @State private var origin: TripLocation = TripLocation.sampleOrigin
    @State private var destination: TripLocation = TripLocation.sampleDestination
    
    @State var navigationPath: [Int] = []
    
    @State private var defaultPackingLists: [PackingList] = []
    
    let trip: Trip?
    
    private var editorTitle: String {
        trip == nil ? "Add Trip" : "Edit Trip"
    }
    
    private var roundTripIcon: String {
        roundTrip ? "arrow.up.arrow.down" : "arrow.down"
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                Form {
                    Section {
                            TextField("Name", text: $name)
                            
                            VStack {
                                Picker("Transportation Method", selection: $tripType) {
                                    ForEach(TripType.allCases, id: \.name) { type in
                                        type.startIcon
                                            .renderingMode(.template)
                                            .foregroundStyle(.accent)
                                            .tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                HStack {
                                    Spacer()
                                    Text("\(tripType.name) Trip").font(.caption)
                                    Spacer()
                                }
                                    }
                    } header: {
                        Text("Basic Details")
                    }
                    
                    Section {
                        HStack {
                            Spacer()
                            VStack {
                                HStack {
                                    tripType.startIcon
                                        .frame(maxHeight: 16)
                                        .foregroundStyle(.accent)
                                    Text("Begins")
                                }
                                DatePicker("Trip Begins", selection: $startDate, displayedComponents: [.date])
                                    .onChange(of: startDate) {
                                        if endDate < startDate {
                                            endDate = startDate
                                        }
                                    }
                            }
                            Spacer()
                            HStack {
                                VStack {
                                    HStack {
                                        tripType.endIcon
                                            .frame(maxHeight: 16)
                                            .foregroundStyle(.accent)
                                        Text("Ends")
                                    }
                                    DatePicker(
                                        "Trip Ends",
                                        selection: $endDate,
                                        in: startDate...,
                                        displayedComponents: [.date]
                                    )
                                }
                            }
                            Spacer()
                        }
                        .labelsHidden()
                    } header: {
                        Text("Dates")
                    }
                    
                    Section {
                        Picker("Trip Type", selection: $roundTrip) {
                            Label("One-Way", systemImage: "arrow.right")
                                .tag(false)
                                .labelStyle(.iconOnly)
                            Label("Round Trip", systemImage: "arrow.right.arrow.left")
                                .tag(true)
                                .labelStyle(.iconOnly)
                        }
                        
                        LocationSelectionBoxView(location: $origin, title: "Find Origin")
                        
                        HStack {
                            Spacer()
                            Image(systemName: roundTripIcon)
                            Spacer()
                        }
                        
                        LocationSelectionBoxView(location: $destination, title: "Find Destination")
                    } header: {
                        Text("Locations")
                    }
                    .listRowSeparator(.hidden)
                    
                    Section {
                        Picker("Accomodation Type", selection: $accomodation) {
                            ForEach(TripAccomodation.allCases, id: \.name) { accomodationType in
                                Text(accomodationType.name).tag(accomodationType)
                            }
                        }
                    } header: {
                        Text("Accomodations")
                    }
                    .listRowSeparator(.hidden)
                    
                    if trip == nil {
                        Section {
                            NavigationLink {
                                PackingListSelectionView(packingLists: $defaultPackingLists)
                            } label: {
                                Label("Select Packing Lists", systemImage: "suitcase")
                            }
                            
                            PackingListPillView(packingLists: defaultPackingLists)
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
            .navigationBarTitleDisplayMode(.inline)
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
                    
                    startDate = trip.startDate
                    endDate = trip.endDate
                    
                    tripType = trip.type
                    accomodation = trip.accomodation
                    
                    origin = trip.origin!
                    destination = trip.destination!
                }
            }
        }
    }
    
    private var formIsValid: Bool {
        return name != "" && startDate <= endDate
    }
    
    private func save() {
        if let trip {
            trip.name = name
            
            trip.startDate = startDate
            trip.endDate = endDate
            
            trip.type = tripType
            trip.accomodation = accomodation
            
            trip.origin = origin
            trip.destination = destination
        } else {
            let newTrip = Trip(name: name, startDate: startDate, endDate: endDate, type: tripType, origin: origin, destination: destination, accomodation: accomodation)
            
            for pList in defaultPackingLists {
                let defaultList = PackingList.copyForTrip(pList)
                defaultList.tripID = newTrip.id
                newTrip.addList(defaultList)
            }
            
            modelContext.insert(newTrip)
        }
    }
    
    private func deleteTrip() {
        modelContext.delete(trip!)
        dismiss()
    }
}
