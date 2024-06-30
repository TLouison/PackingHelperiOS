//
//  TripDetailSectionView.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/29/24.
//

import SwiftUI

struct TripDetailSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        TripDetailCustomSectionView {
            HStack {
                Text(title)
                    .font(.title)
                Spacer()
            }
        } content: {
            content
        }
    }
}

struct TripDetailCustomSectionView<Header: View, Content: View>: View {
    @ViewBuilder let header: Header
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            header
            
            Divider()
            
            content
                .padding(.top)
        }
        .roundedBox()
        .shaded()
    }
}
