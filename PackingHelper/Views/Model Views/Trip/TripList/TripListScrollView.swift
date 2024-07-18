//
//  TripListScrollView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/17/23.
//

import SwiftUI

struct TripListScrollView: View {
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    
    @Binding var path: NavigationPath
    
    var trips: [Trip]
    
    var showCTA: Bool = false
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(trips) { trip in
                    TripListRowView(path: $path, trip: trip)
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1.0 : 0.8)
                                .scaleEffect(y: phase.isIdentity ? 1.0 : 0.9)
                        }
                }
                
                if !purchaseManager.hasUnlockedPlus && showCTA {
                    PackingHelperPlusCTA(headerText: "Add unlimited trips with", version: .tall)
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1.0 : 0.8)
                                .scaleEffect(y: phase.isIdentity ? 1.0 : 0.9)
                        }
                }
            }
            .scrollTargetLayout()
            
            
            
        }
        .contentMargins(.horizontal, 24, for: .scrollContent)
        .scrollTargetBehavior(.paging)
    }
}

//#Preview {
//    TripListScrollView()
//}
