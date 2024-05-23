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
    
    @State private var destination: TripLocation = TripLocation.sampleData
    @State private var mapCameraPosition: MapCameraPosition = TripLocation.sampleData.mapCameraPosition
    
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
                        TextField("Name", text: $name)
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
                                        .onChange(of: beginDate) {
                                            if endDate < beginDate {
                                                endDate = beginDate
                                            }
                                        }
                                }
                            }
                            Spacer()
                            HStack {
                                Image(systemName: Trip.endIcon)
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
                        ZStack { // Hack to remove the > from the navigation link view
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
                                
                                Map(position: $mapCameraPosition)
                                    .frame(height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
                                    .onChange(of: destination, initial: true) {
                                        mapCameraPosition = destination.mapCameraPosition
                                    }
                            }
                        }
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
                    
                    destination = trip.destination!
                    mapCameraPosition = trip.destination!.mapCameraPosition
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
            
            trip.destination = destination
        } else {
            let newTrip = Trip(name: name, beginDate: beginDate, endDate: endDate, type: tripType, destination: destination)
            
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
