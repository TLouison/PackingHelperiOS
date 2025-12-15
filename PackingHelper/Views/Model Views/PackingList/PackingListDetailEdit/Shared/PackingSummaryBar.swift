//
//  PackingSummaryBar.swift
//  PackingHelper
//
//  Created by Todd Louison on 9/17/25.
//

import SwiftUI

struct PackingSummaryBar: View {
    let packingList: PackingList
    
    var totalItems: Int {
        packingList.items?.count ?? 0
    }
    
    var packedItems: Int {
        packingList.items?.filter { $0.isPacked }.count ?? 0
    }
    
    var progress: Double {
        totalItems > 0 ? Double(packedItems) / Double(totalItems) : 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
            
            // Summary info
            HStack {
                Label("\(packedItems)/\(totalItems) packed", systemImage: "checkmark.square.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if progress == 1.0 {
                    Label("Ready to go!", systemImage: "sparkles")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
    }
}
