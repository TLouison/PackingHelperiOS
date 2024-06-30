//
//  PackingListApplyDefaultView.swift
//  PackingHelper
//
//  Created by Todd Louison on 11/14/23.
//

import SwiftData
import SwiftUI

struct PackingListApplyDefaultView: View {
    @Environment(\.dismiss) private var dismiss

    var trip: Trip

    @State private var defaultPackingLists: [PackingList] = []
    @State private var selectedUser: User?

    var formIsValid: Bool {
        return !defaultPackingLists.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Apply default packing lists to \(trip.name)")
                    .font(.headline)
                
                Group {
                    if let selectedUser {
                        HStack {
                            Text("Lists will be applied to packer")
                            selectedUser.pillIcon
                        }
                    } else {
                        Text("Lists will be applied to the packer who created it.")
                    }
                }.font(.subheadline)
            }
            VStack {
                Form {
                    Section("Default Lists") {
                        UserPickerBaseView(selectedUser: $selectedUser, allowAll: false)
                            .onChange(of: selectedUser) {
                                // Only let them apply one user at a time. Remove all if they change users
                                defaultPackingLists.removeAll()
                            }

                        NavigationLink {
                            PackingListSelectionView(
                                trip: trip,
                                selectedPackingLists: $defaultPackingLists,
                                user: selectedUser)
                        } label: {
                            Label(
                                "Select Packing Lists", systemImage: "suitcase")
                        }
                    }

                    Section("Lists To Be Applied") {
                        PackingListPillView(packingLists: defaultPackingLists)
                    }
                    
                    Section("Already Applied") {
                        PackingListPillView(packingLists: PackingList.filtered(user: selectedUser, trip.alreadyUsedTemplates))
                    }
                }
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
        .presentationDetents([.medium, .large])
    }

    func save() {
        if !defaultPackingLists.isEmpty {
            for list in defaultPackingLists {
                let defaultList = PackingList.copyForTrip(list, for: selectedUser)
                defaultList.tripID = trip.id
                trip.addList(defaultList)
            }
        }
    }
}
