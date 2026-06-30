//
//  TripPackingSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

import SwiftUI
import SwiftData

struct TripDetailPackingView: View {
    let trip: Trip

    @Binding var isAddingNewPackingList: Bool
    @Binding var isApplyingDefaultPackingList: Bool

    var body: some View {
        TripDetailCustomSectionView {
            HStack {
                Text("Packing Lists")
                    .font(.title)
                Spacer()

                headerMenu
            }
        } content: {
            if (trip.lists ?? []).isEmpty {
                ContentUnavailableView {
                    Label("No Packing Lists", systemImage: suitcaseIcon)
                } description: {
                    Text("You haven't added any packing lists to this trip!")
                } actions: {
                    CreateListMenu(
                        isAddingNewPackingList: $isAddingNewPackingList,
                        isApplyingDefaultPackingList: $isApplyingDefaultPackingList
                    )
                }
            } else {
                NavigationLink {
                    PackingListContainerView(
                        trip: trip,
                        users: trip.packers.isEmpty ? nil : trip.packers,
                        title: trip.name
                    )
                } label: {
                    HStack {
                        Image(systemName: suitcaseIcon)
                        Text("Packing")
                            .font(.headline)
                        Spacer()
                        TripDetailPackingProgressView(
                            val: Double(trip.packedItemsCount),
                            total: Double(trip.totalItemsCount),
                            image: Image(systemName: suitcaseIcon)
                        )
                        .scaleEffect(x: 0.75, y: 0.75)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
                .roundedBox(background: .ultraThick)
                .shaded()
            }
        }
    }

    var headerMenu: some View {
        Menu {
            CreateListMenu(
                isAddingNewPackingList: $isAddingNewPackingList,
                isApplyingDefaultPackingList: $isApplyingDefaultPackingList
            )
        } label: {
            Label("Menu", systemImage: "ellipse")
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    @Previewable @State var addingList = false
    @Previewable @State var applyingDefault = false
    TripDetailPackingView(trip: trips.first!, isAddingNewPackingList: $addingList, isApplyingDefaultPackingList: $applyingDefault)
}
