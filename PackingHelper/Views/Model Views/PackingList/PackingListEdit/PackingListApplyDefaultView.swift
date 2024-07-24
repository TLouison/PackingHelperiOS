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
                Text("Apply Default Packing Lists to \(trip.name)")
                    .font(.title3)
                
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
                                user: selectedUser,
                                lockToProvidedUser: true
                            )
                        } label: {
                            Label(
                                "Select Packing Lists", systemImage: "suitcase")
                        }
                    }

                    Section {
                        PackingListPillView(packingLists: defaultPackingLists)
                    } header: {
                        Text("Lists To Be Applied")
                    } footer: {
                        Text("Newly selected lists that will be added to \(trip.name) for \(selectedUser?.name ?? "packer").")
                    }
                    
                    Section {
                        PackingListPillView(packingLists: PackingList.filtered(user: selectedUser, trip.alreadyUsedTemplates))
                    } header: {
                        Text("Already Applied")
                    } footer: {
                        Text("These lists have already been applied to this trip for \(selectedUser?.name ?? "packer") and cannot be applied again.")
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
        .presentationDetents([.height(500), .large])
    }

    func save() {
        trip.applyDefaultLists(to: selectedUser, lists: defaultPackingLists)
    }
}
