//
//  TemplateListInfoView.swift
//  PackingHelper
//
//  A read-only info sheet for template (default) packing lists, displaying
//  metadata such as creation date, item count, usage across trips, and more.
//

import SwiftUI
import SwiftData

struct TemplateListInfoView: View {
    let list: PackingList

    @Environment(\.dismiss) private var dismiss
    @State private var tripsExpanded: Bool = false

    private static let dateFormatter: Date.FormatStyle = .dateTime.month(.abbreviated).day().year()

    private var allItems: [Item] { list.items ?? [] }
    private var packingItemCount: Int { allItems.filter { $0.type == .packing && !$0.isDayOf }.count }
    private var taskItemCount: Int { allItems.filter { $0.type == .task }.count }
    private var dayOfItemCount: Int { allItems.filter { $0.isDayOf }.count }

    @ViewBuilder
    private func infoRow(_ title: String, _ detail: some View) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            detail
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("List Details") {
                    infoRow("Total Items", Text("\(list.totalItems)"))

                    if packingItemCount > 0 {
                        infoRow("Packing Items", Text("\(packingItemCount)"))
                    }
                    if taskItemCount > 0 {
                        infoRow("Tasks", Text("\(taskItemCount)"))
                    }
                    if dayOfItemCount > 0 {
                        infoRow("Day-of Items", Text("\(dayOfItemCount)"))
                    }

                    infoRow(
                        "Created",
                        Text(list.created.formatted(Self.dateFormatter))
                    )

                    infoRow(
                        "Last Updated",
                        Text(
                            list.lastUpdatedDate.map { $0.formatted(Self.dateFormatter) }
                                ?? "No items"
                        )
                    )
                }

                Section("Usage") {
                    DisclosureGroup(
                        isExpanded: $tripsExpanded,
                        content: {
                            let trips = list.appliedTrips
                            if trips.isEmpty {
                                Text("No trips yet")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            } else {
                                ForEach(trips.sorted(by: { $0.startDate < $1.startDate }), id: \.persistentModelID) { trip in
                                    HStack {
                                        Text(trip.name)
                                        
                                        Spacer()
                                        
                                        if trip.status == .complete {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .font(.subheadline)
                                }
                            }
                        },
                        label: {
                            infoRow(
                                "Applied to",
                                Text("\(list.appliedTrips.count) trip\(list.appliedTrips.count == 1 ? "" : "s")")
                            )
                        }
                    )

                    infoRow(
                        "Last Applied To",
                        Text(list.lastAppliedTrip?.name ?? "None")
                    )
                }
            }
            .navigationTitle("\(list.name) Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
    }
}
