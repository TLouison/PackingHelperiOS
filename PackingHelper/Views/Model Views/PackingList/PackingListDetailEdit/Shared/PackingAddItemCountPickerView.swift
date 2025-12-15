//
//  PackingAddItemCountPickerView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/20/24.
//

import SwiftUI

struct PackingAddItemCountPickerView: View {
    @Binding var itemCount: Int
    
    var body: some View {
        Picker("Count", selection: $itemCount) {
            ForEach(1..<100) { val in
                Text("\(val)").tag(val)
            }
        }
        .pickerStyle(.wheel)
        .buttonStyle(.borderless)
        .frame(maxWidth: 60, maxHeight: 60)
        .padding(.trailing, 10)
    }
}
