//
//  MissingUsersView.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/13/24.
//

import SwiftUI

struct MissingUsersView: View {
    @State private var showAddPackerSheet = false
    
    var body: some View {
        ContentUnavailableView {
            Label("No Packers Found", systemImage: "person.fill")
        } description: {
            Text("Add a packer to get started!")
        } actions: {
            Button("Add Packer") {
                showAddPackerSheet.toggle()
            }
        }
        .sheet(isPresented: $showAddPackerSheet) {
            UserEditView(user: nil, isPresentedModally: true)
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    MissingUsersView()
}
