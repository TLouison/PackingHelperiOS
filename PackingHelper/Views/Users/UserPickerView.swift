//
//  UserPickerView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI

struct UserPickerView: View {
    @Binding var selectedUser: User?
    
    var tripForFiltering: Trip? = nil
    
    var showLabel: Bool = true
    var showIcon: Bool = true
    var allowAll: Bool = true
    
    
    
    var body: some View {
        HStack {
            if showLabel {
                Label("Showing Lists For", systemImage: "person.circle")
                Spacer()
            }
            UserPickerBaseView(selectedUser: $selectedUser, showIcon: showIcon, allowAll: allowAll)
            .background(.thickMaterial)
            .rounded()
        }
    }
}

//#Preview {
//    UserPickerView()
//}
