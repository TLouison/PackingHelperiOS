//
//  NewUserGetNameView.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/23/24.
//

import SwiftUI

struct NewUserGetNameView: View {
    @Binding var name: String
    
    var body: some View {
        VStack {
            Spacer()
            
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
                        .strokeBorder(defaultLinearGradient)
                )
                .padding()
            
            Spacer()
        }
    }
}

#Preview {
    NewUserGetNameView(name: .constant("Todd"))
}
