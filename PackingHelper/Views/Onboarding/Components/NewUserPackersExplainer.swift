//
//  NewUserPackersExplainer.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/23/24.
//

import SwiftUI

struct NewUserPackersExplainer: View {
    @Binding var userName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Label("Packers", systemImage: userIcon)
                .font(.largeTitle)
                .padding(.bottom)
            
            VStack(alignment: .leading) {
                plusSubscriptionName()
                    .font(.headline)
                Text("With Packing Helper Plus, you can add multiple users to allow multiple users to pack together for the same trip. Each user will have their own items, and can even create default packing lists, just for them, so you all can keep track of exactly what you need!")
            }
            
            List {
                Section("Current Users") {
                    HStack {
                        Color(User.sampleUser.userColor)
                            .clipShape(.circle)
                            .frame(width: 24, height: 24)
                            .shaded()
                        Text(userName)
                    }
                }
            }
            .frame(maxHeight: 100)
            
            Spacer()
            
            PackingHelperPlusCTA(headerText: "Add multiple packers with")
        }
    }
}
