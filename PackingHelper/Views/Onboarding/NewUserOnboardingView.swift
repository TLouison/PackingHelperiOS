//
//  NewUserOnboardingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct NewUserOnboardingView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    
    var body: some View {
        Text("Welcome to Packing Helper!").font(.title).fontWeight(.bold)
            .padding(.bottom, 20)
        Text("To get started, enter your name below!").font(.headline)
        TextField("Name", text: $name)
            .padding()
            .background(.thinMaterial)
            .padding()
            .rounded()
            .shaded()
        Button("Get Started") {
            saveNewUser()
            dismiss()
        }
        .shaded()
        .disabled(name == "")
    }
    
    func saveNewUser() {
        let newUser = User(name: name)
        modelContext.insert(newUser)
    }
}

#Preview {
    NewUserOnboardingView()
}
