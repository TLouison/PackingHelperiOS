//
//  PackingListMultiListEditView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/25/24.
//

import SwiftUI
import SwiftData

struct PackingListMultiListEditView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var packingList: PackingList
    
    let user: User?
    
    @Binding var currentView: PackingListDetailViewCurrentSelection
    
    @State private var isShowingSaveAsDefaultConfirmation: Bool = false
    @State private var isShowingSaveSuccessful: Bool = false
    @State private var isDeleted: Bool = false
    
    @Binding var selectedList: PackingList?
    @Binding var isAddingNewItem: Bool
    @Binding var isShowingEditList: Bool
    
    var currentItems: [Item] {
        let items: [Item]
        if currentView == .unpacked {
            items = packingList.incompleteItems
        } else {
            items = packingList.completeItems
        }
        return items.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        CollapsibleSection {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(packingList.name)
                        .font(.title)
                    
                    if user == nil {
                        if let pUser = packingList.user {
                            pUser.pillIcon
                        }
                    }
                }
                
                Spacer()
                
                sectionButtons(packingList: packingList)
                    .padding(.trailing)
            }
        } content: {
            ForEach(currentItems, id: \.id) { item in
                PackingListDetailEditRowView(
                    packingList: packingList,
                    item: item,
                    showCount: packingList.type != .task,
                    showButton: packingList.template == false
                )
            }
        }
        .confirmationDialog(
            Text("Are you sure you want to save \(packingList.name) as a default list? This will save both packed and unpacked items from this list to a default list with the same name."),
            isPresented: $isShowingSaveAsDefaultConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm") {
                withAnimation {
                    isShowingSaveSuccessful = true
                }
            }
        }
        .alert("\(packingList.name) saved as default", isPresented: $isShowingSaveSuccessful) {
            Button("OK", role: .cancel) {}
        }
    }
    
    @ViewBuilder func sectionButtons(packingList: PackingList) -> some View {
        HStack(alignment: .center) {
            Menu {
                Button {
                    withAnimation(.snappy) {
                        selectedList = packingList
                        isShowingEditList.toggle()
                    }
                } label: {
                    Label("Edit List", systemImage: "pencil")
                }
                
                Button {
                    _ = PackingList.copyAsTemplate(packingList)
                    isShowingSaveAsDefaultConfirmation.toggle()
                } label: {
                    Label("Save As Default", systemImage: "folder.badge.plus")
                }
                
                Button(role: .destructive) {
                    modelContext.delete(packingList)
                } label: {
                    Label("Delete from Trip", systemImage: "trash")
                }
            } label: {
                Label("Options", systemImage: "slider.horizontal.3")
                    .labelStyle(.iconOnly)
                    .font(.headline)
            }
            .padding(10)
            .background(.thickMaterial)
            .rounded()
            .shaded()
            
            if currentView == .unpacked {
                Button {
                    withAnimation(.snappy) {
                        selectedList = packingList
                        isAddingNewItem.toggle()
                    }
                } label: {
                    Label("Add Item", systemImage: "plus.circle.fill")
                        .labelStyle(.iconOnly)
                        .tint(.green)
                        .font(.headline)
                }
                .padding(10)
                .background(.thickMaterial)
                .rounded()
                .shaded()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var packingLists: [PackingList]
    @Previewable @State var currentView: PackingListDetailViewCurrentSelection = .unpacked
    
    List {
        PackingListMultiListEditView(packingList: packingLists.first!, user: nil, currentView: $currentView, selectedList: .constant(nil), isAddingNewItem: .constant(false), isShowingEditList: .constant(false))
    }
}
