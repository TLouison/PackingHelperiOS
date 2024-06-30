//
//  FoundExistingDataView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/18/24.
//

import SwiftUI

struct FoundExistingDataView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Found Existing Data").font(.title)
                .padding(.bottom, 5)
            Text("Welcome back!").font(.title2).fontWeight(.bold)
                .padding(.bottom, 20)
            Text("Looks like we found existing data in your iCloud account. It has been loaded back into PackingHelper for your convenience.").font(.headline).multilineTextAlignment(.center)
                .padding(.bottom, 20)
            Button {
                dismiss()
            } label: {
                Label("Start Packing", systemImage: "suitcase.rolling")
            }
            .padding()
            .background(.thickMaterial)
            .rounded()
            .shaded()
        }
        .padding(.horizontal)
    }
}

#Preview {
    FoundExistingDataView()
}
