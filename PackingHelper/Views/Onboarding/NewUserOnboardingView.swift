//
//  NewUserOnboardingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct NewUserOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query private var users: [User]
    @State private var foundExistingData = false
    
    var body: some View {
        Group {
            if foundExistingData {
                FoundExistingDataView()
            } else {
                NewUserOnboardingView()
            }
        }
        .onChange(of: users) {
            withAnimation {
                foundExistingData = !users.isEmpty
            }
        }
    }
}

#Preview {
    NewUserOnboardingView()
}
