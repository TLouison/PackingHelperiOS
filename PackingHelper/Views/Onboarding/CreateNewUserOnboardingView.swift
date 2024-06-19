//
//  CreateNewUserOnboardingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/18/24.
//

import SwiftUI

struct CreateNewUserOnboardingView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    
    var body: some View {
        VStack {
            Text("Welcome to Packing Helper!").font(.title).fontWeight(.bold)
                .padding(.bottom, 10)
            Text("To get started, enter your name below!").font(.headline)
                .padding(.bottom, 20)
            
            TextField("Name", text: $name)
                .padding()
                .background(.thinMaterial)
                .rounded()
                .shaded()
                .overlay(
                    RoundedRectangle(cornerRadius: defaultCornerRadius)
                        .strokeBorder(LinearGradient(colors: [.accentColor, .purple], startPoint: .leading, endPoint: .trailing))
                )
                .padding()
            
            Button("Get Started") {
                saveNewUser()
                dismiss()
            }
            .padding()
            .background(.thickMaterial)
            .rounded()
            .shaded()
            .disabled(name == "")
        }
    }
    
    func saveNewUser() {
        let newUser = User(name: name)
        modelContext.insert(newUser)
    }
}

#Preview {
    CreateNewUserOnboardingView()
}
