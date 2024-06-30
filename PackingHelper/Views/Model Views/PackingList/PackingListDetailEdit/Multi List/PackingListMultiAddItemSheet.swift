//
//  PackingListMultiAddItemSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/28/24.
//

import SwiftUI

struct PackingListMultiAddItemSheet: View {
    @Binding var listToAddItemTo: PackingList?
    var availableLists: [PackingList]
    
    var body: some View {
        PackingAddItemForGroupView(selectedPackingList: $listToAddItemTo, availableLists: availableLists)
    }
}
//
//#Preview {
//    PackingListMultiAddItemSheet()
//}
