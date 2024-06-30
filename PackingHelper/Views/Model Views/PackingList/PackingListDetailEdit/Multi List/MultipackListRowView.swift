//
//  PackingListMultiListEditView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/25/24.
//

import SwiftUI
import SwiftData

struct MultipackListRowView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var packingList: PackingList
    let trip: Trip
    let user: User?
    let listType: ListType
    
    let currentView: PackingListDetailViewCurrentSelection
    
    @Binding var selectedListToAdd: PackingList?
    @Binding var selectedListToEdit: PackingList?
    @Binding var isDeleted: Bool
    
    @State private var isShowingSaveAsDefaultConfirmation: Bool = false
    @State private var isShowingSaveSuccessful: Bool = false
    @State private var isShowingDeleteConfirmation: Bool = false
    
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
                        
                        HStack {
                            if user == nil {
                                if let pUser = packingList.user {
                                    pUser.pillIcon
                                }
                            }
                            
                            Group {
                                if currentView == .unpacked {
                                    Text("\(currentItems.count) remaining")
                                } else {
                                    Text("\(currentItems.count)/\(packingList.totalItems) packed")
                                }
                            }.font(.caption)
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
                
                if currentView == .unpacked {
                    Button {
                        selectedListToAdd = packingList
                    } label: {
                        Label("Add Item", systemImage: "plus.circle")
                    }
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
            .confirmationDialog(
                Text("Are you sure you want to delete \(packingList.name) from this trip? This cannot be undone."),
                isPresented: $isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    delete()
                }
            }
    }
    
    @ViewBuilder func sectionButtons(packingList: PackingList) -> some View {
        HStack(alignment: .center) {
            Menu {
                Button {
                    withAnimation(.snappy) {
                        selectedListToEdit = packingList
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
                    isShowingDeleteConfirmation.toggle()
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
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    func delete() {
        withAnimation {
            let _ = PackingList.delete(packingList, from: modelContext)
        }
    }
}

//@available(iOS 18, *)
//#Preview(traits: .sampleData) {
//    @Previewable @Query var packingLists: [PackingList]
//    List {
//        PackingListMultiListEditView(packingList: packingLists.first!, trip: packingLists.first!.trip!, user: nil, listType: packingLists.first!.type, currentView: .unpacked)
//    }
//}
