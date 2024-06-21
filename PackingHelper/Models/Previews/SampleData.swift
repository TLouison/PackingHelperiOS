//
//  SampleData.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/19/24.
//

import SwiftUI
import SwiftData

@available(iOS 18.0, *)
struct SampleData: PreviewModifier {
    static func makeSharedContext() async throws -> Context {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, TripLocation.self, PackingList.self, Item.self, User.self, configurations: config)
        
        makeSamples(in: container)
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

@available(iOS 18.0, *)
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}

@MainActor private func makeSamples(in container: ModelContainer) {
    // User Creation
    let userTodd = User(name: "Todd")
    let userEmma = User(name: "Emma")
    
    // Trip and Location Creation
    let springBreakLocations = [
        TripLocation(trip: nil, name: "New York City", latitude: 40.7128, longitude: -74.0060),
        TripLocation(trip: nil, name: "Miami", latitude: 25.7617, longitude: 80.1918)
    ]
    let springBreakTrip = Trip(name: "Spring Break", startDate: Date.distantPast, endDate: Date.distantPast.advanced(by: SECONDS_IN_DAY), type: .plane, origin: springBreakLocations[0], destination: springBreakLocations[1], accomodation: .rental)
    springBreakLocations[0].trip = springBreakTrip
    springBreakLocations[1].trip = springBreakTrip
    
    let familyVisitLocations = [
        TripLocation(trip: nil, name: "New York City", latitude: 40.7128, longitude: -74.0060),
        TripLocation(trip: nil, name: "Jersey City", latitude: 40.7178, longitude: -74.0431)
    ]
    let familyVisitTrip = Trip(name: "Family Visit", startDate: Date.distantPast, endDate: Date.distantFuture, type: .car, origin: familyVisitLocations[0], destination: familyVisitLocations[1], accomodation: .rental)
    familyVisitLocations[0].trip = familyVisitTrip
    familyVisitLocations[1].trip = familyVisitTrip
    
    let workTripLocations = [
        TripLocation(trip: nil, name: "New York City", latitude: 40.7128, longitude: -74.0060),
        TripLocation(trip: nil, name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
    ]
    let workTrip = Trip(name: "Family Visit", startDate: Date.distantFuture.advanced(by: -SECONDS_IN_DAY), endDate: Date.distantFuture, type: .car, origin: workTripLocations[0], destination: workTripLocations[1], accomodation: .hotel)
    workTripLocations[0].trip = workTrip
    workTripLocations[1].trip = workTrip
    
    // Packing List Creation
    let springBreakPackingList = PackingList(type: .packing, template: false, name: "Beachwear")
    springBreakPackingList.addItem(Item(name: "Board Shorts", category: "Clothing", count: 2, isPacked: false))
    springBreakPackingList.addItem(Item(name: "Bikini", category: "Clothing", count: 3, isPacked: true))
    springBreakPackingList.addItem(Item(name: "Sunscreen", category: "Clothing", count: 1, isPacked: true))
    springBreakPackingList.addItem(Item(name: "Sunglasses", category: "Accessories", count: 2, isPacked: false))
    springBreakPackingList.user = userEmma
    springBreakPackingList.trip = springBreakTrip
    
    let familyVisitPackingList = PackingList(type: .packing, template: false, name: "Essentials")
    familyVisitPackingList.addItem(Item(name: "Shirts", category: "Clothing", count: 5, isPacked: false))
    familyVisitPackingList.addItem(Item(name: "Shorts", category: "Clothing", count: 3, isPacked: true))
    familyVisitPackingList.addItem(Item(name: "Shoes", category: "Clothing", count: 1, isPacked: true))
    familyVisitPackingList.addItem(Item(name: "Gifts", category: "Accessories", count: 2, isPacked: false))
    familyVisitPackingList.user = userTodd
    familyVisitPackingList.trip = familyVisitTrip
    
    let workTripPackingList = PackingList(type: .packing, template: false, name: "Business Attire")
    workTripPackingList.addItem(Item(name: "Suit Jacket", category: "Clothing", count: 1, isPacked: false))
    workTripPackingList.addItem(Item(name: "Dress Shirt", category: "Clothing", count: 3, isPacked: true))
    workTripPackingList.addItem(Item(name: "Dress", category: "Clothing", count: 1, isPacked: true))
    workTripPackingList.addItem(Item(name: "Shoes", category: "Accessories", count: 2, isPacked: false))
    workTripPackingList.user = userEmma
    workTripPackingList.trip = workTrip
    
    let workTripToDoList = PackingList(type: .task, template: false, name: "International Travel Checklist")
    workTripToDoList.addItem(Item(name: "Find Passport", category: "Task", count: 1, isPacked: false))
    workTripToDoList.addItem(Item(name: "File for travel visa", category: "Task", count: 1, isPacked: true))
    workTripToDoList.user = userEmma
    workTripToDoList.trip = workTrip
    
    let workTripDayOfList = PackingList(type: .dayOf, template: false, name: "Morning Of")
    workTripDayOfList.addItem(Item(name: "Take Out Trash", category: "Task", count: 1, isPacked: false))
    workTripDayOfList.addItem(Item(name: "Kiss Todd", category: "Task", count: 1, isPacked: true))
    workTripDayOfList.user = userEmma
    workTripDayOfList.trip = workTrip
    
    // Default Packing Lists
    let defaultPackingList = PackingList(type: .packing, template: true, name: "Essential Clothing")
    defaultPackingList.addItem(Item(name: "Shirts", category: "Clothing", count: 1, isPacked: false))
    defaultPackingList.addItem(Item(name: "Pants", category: "Clothing", count: 3, isPacked: true))
    defaultPackingList.addItem(Item(name: "Underwear", category: "Clothing", count: 1, isPacked: true))
    defaultPackingList.addItem(Item(name: "Socks", category: "Accessories", count: 2, isPacked: false))
    defaultPackingList.user = userTodd
    
    let defaultElectronicsPackingList = PackingList(type: .packing, template: true, name: "Essential Clothing")
    defaultElectronicsPackingList.addItem(Item(name: "Phone", category: "Clothing", count: 1, isPacked: false))
    defaultElectronicsPackingList.addItem(Item(name: "Phone Charger", category: "Clothing", count: 3, isPacked: true))
    defaultElectronicsPackingList.addItem(Item(name: "Laptop", category: "Clothing", count: 1, isPacked: true))
    defaultElectronicsPackingList.addItem(Item(name: "Laptop Charger", category: "Accessories", count: 2, isPacked: false))
    defaultPackingList.user = userTodd
    
    container.mainContext.insert(defaultPackingList)
    container.mainContext.insert(defaultElectronicsPackingList)
    
    container.mainContext.insert(springBreakTrip)
    container.mainContext.insert(familyVisitTrip)
    container.mainContext.insert(workTripPackingList)
}
