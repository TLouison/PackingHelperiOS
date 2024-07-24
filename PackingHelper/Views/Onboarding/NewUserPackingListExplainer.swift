//
//  NewUserPackingListExplainer.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/23/24.
//

import SwiftUI

struct NewUserPackingListExplainer: View {
    var body: some View {
        VStack(alignment: .leading) {
            Label("Default Packing Lists", systemImage: suitcaseIcon)
                .font(.largeTitle)
                .padding(.bottom, 16)
            
            Text("Create packing lists that you can apply to any trip to easily and quickly add everything you want to take. Create them however you see fit: by category, by occasion, by destination, or whatever else you can think of!")
                .padding(.bottom, 8)
            
            Spacer()
            
            VStack {
                Text("You can also choose different types of lists:")
                    .font(.headline)
                
                Grid(alignment: .leading) {
                    Rectangle()
                        .fill(.secondary)
                        .frame(height: 1)
                    
                    GridRow {
                        Label("Packing", systemImage: ListType.packing.icon)
                            .bold()
                        Text("Standard lists")
                    }
                    
                    Rectangle()
                        .fill(.secondary)
                        .frame(height: 1)
                    
                    GridRow {
                        Label("Task", systemImage: ListType.task.icon)
                            .bold()
                        Text("To-do Lists")
                    }
                    
                    Rectangle()
                        .fill(.secondary)
                        .frame(height: 1)
                    
                    GridRow {
                        Label("Day-of", systemImage: ListType.dayOf.icon)
                            .bold()
                        Text("For last-minute items")
                    }
                }
            }
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    NewUserPackingListExplainer()
}
