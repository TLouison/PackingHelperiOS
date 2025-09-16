import SwiftUI
import SwiftData

struct TripEditView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Trip model (can be nil for new trip creation)
    var trip: Trip?
    @Binding var isDeleted: Bool
    
    // State properties for editing
    @State private var tripName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(86400 * 5) // 5 days later
    @State private var tripType: TripType = .plane
    @State private var tripAccomodation: TripAccomodation = .hotel
    
    // Location state
    @State private var originLocation: TripLocation?
    @State private var destinationLocation: TripLocation?
    @State private var showingOriginSearch = false
    @State private var showingDestinationSearch = false
    
    // UI State
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showDeleteAlert = false
    
    // MARK: - Initialization
    init(trip: Trip?, isDeleted: Binding<Bool>) {
        self.trip = trip
        self._isDeleted = isDeleted
        
        // Initialize state properties from trip if it exists
        if let trip = trip {
            _tripName = State(initialValue: trip.name)
            _startDate = State(initialValue: trip.startDate)
            _endDate = State(initialValue: trip.endDate)
            _tripType = State(initialValue: trip.type)
            _tripAccomodation = State(initialValue: trip.accomodation)
            _originLocation = State(initialValue: trip.origin)
            _destinationLocation = State(initialValue: trip.destination)
        }
    }
    
    // MARK: - Body
    var body: some View {
        // Scrollable content
        ScrollView {
            VStack(spacing: 20) {
                // Header with image
                headerView
                
                // Trip info card
                tripInfoSection
                
                // Location section
                locationSection
                
                // Accommodation section
                accommodationSection
                
                // Save and Delete buttons
                buttonSection
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showImagePicker) {
            // Image picker would go here
            Text("Image Picker Placeholder")
        }
        .sheet(isPresented: $showingOriginSearch) {
            LocationSearchView(location: $originLocation)
        }
        .sheet(isPresented: $showingDestinationSearch) {
            LocationSearchView(location: $destinationLocation)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveTrip()
                }
                .disabled(originLocation == nil || destinationLocation == nil || tripName.isEmpty)
            }
        }
        .alert("Delete Trip", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTrip()
            }
        } message: {
            Text("Are you sure you want to delete this trip? This action cannot be undone.")
        }
    }
    
    // MARK: - Header View
    var headerView: some View {
        // Overlay with trip name
        VStack(alignment: .leading) {
            TextField("Trip Name", text: $tripName)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 4)
            
            if let destination = destinationLocation {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(destination.name)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Trip Info Section
    var tripInfoSection: some View {
        VStack(spacing: 15) {
            Text("Trip Details")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
            
            // Trip type selector
            tripTypeSelector
            
            // Date selection cards
            dateSelectionCards
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
    
    // MARK: - Trip Type Selector
    var tripTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TripType.allCases, id: \.self) { type in
                    Button(action: {
                        tripType = type
                    }) {
                        HStack {
                            type.startIcon
                            Text(type.name)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(tripType == type ? Color.accentColor : Color(.tertiarySystemFill))
                        .foregroundColor(tripType == type ? .white : .primary)
                        .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    // MARK: - Date Selection Cards
    var dateSelectionCards: some View {
        HStack(spacing: 15) {
            // Start date card
            VStack(alignment: .leading) {
                Text("Start Date")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding()
            .background(Color(.tertiarySystemFill))
            .cornerRadius(15)
            .frame(maxWidth: .infinity)
            
            // End date card
            VStack(alignment: .leading) {
                Text("End Date")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                DatePicker("", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding()
            .background(Color(.tertiarySystemFill))
            .cornerRadius(15)
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Location Section
    var locationSection: some View {
        VStack(spacing: 15) {
            Text("Locations")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
            
            // Origin location card
            Button(action: {
                showingOriginSearch = true
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Origin")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let origin = originLocation {
                            tripType.startLabel(text: origin.name)
                                .foregroundColor(.primary)
                        } else {
                            Text("Select Origin")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.tertiarySystemFill))
                .cornerRadius(15)
            }
            
            // Destination location card
            Button(action: {
                showingDestinationSearch = true
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Destination")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let destination = destinationLocation {
                            tripType.endLabel(text: destination.name)
                                .foregroundColor(.primary)
                        } else {
                            Text("Select Destination")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.tertiarySystemFill))
                .cornerRadius(15)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
    
    // MARK: - Accommodation Section
    var accommodationSection: some View {
        VStack(spacing: 15) {
            Text("Accommodation")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
            
            // Accommodation type selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(TripAccomodation.allCases, id: \.self) { accom in
                        Button(action: {
                            tripAccomodation = accom
                        }) {
                            HStack {
                                Image(systemName: accommodationIcon(for: accom))
                                Text(accom.name)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(tripAccomodation == accom ? Color.accentColor : Color(.tertiarySystemFill))
                            .foregroundColor(tripAccomodation == accom ? .white : .primary)
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
    
    // MARK: - Button Section
    var buttonSection: some View {
        VStack(spacing: 15) {
            // Save button
            Button(action: {
                saveTrip()
            }) {
                Text(trip == nil ? "Create Trip" : "Save Changes")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(originLocation == nil || destinationLocation == nil || tripName.isEmpty ?
                               Color(.systemGray) : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .disabled(originLocation == nil || destinationLocation == nil || tripName.isEmpty)
            
            // Delete button (only show for existing trips)
            if trip != nil {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Delete Trip")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemRed).opacity(0.2))
                        .foregroundColor(Color(.systemRed))
                        .cornerRadius(15)
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Helper Methods
    func accommodationIcon(for accom: TripAccomodation) -> String {
        switch accom {
        case .hotel:
            return "building.2"
        case .rental:
            return "house"
        case .family:
            return "person.3"
        case .friend:
            return "person.2"
        }
    }
    
    // MARK: - Data Operations
    func saveTrip() {
        guard let origin = originLocation, let destination = destinationLocation else {
            return
        }
        
        if let existingTrip = trip {
            // Update existing trip
            existingTrip.name = tripName
            existingTrip.startDate = startDate
            existingTrip.endDate = endDate
            existingTrip.type = tripType
            existingTrip.origin = origin
            existingTrip.destination = destination
            existingTrip.accomodation = tripAccomodation
        } else {
            // Create new trip
            let newTrip = Trip(
                name: tripName,
                startDate: startDate,
                endDate: endDate,
                type: tripType,
                origin: origin,
                destination: destination,
                accomodation: tripAccomodation
            )
            modelContext.insert(newTrip)
        }
        
        // Save changes and dismiss
        try? modelContext.save()
        dismiss()
    }
    
    func deleteTrip() {
        if let tripToDelete = trip {
            modelContext.delete(tripToDelete)
            isDeleted = true
            dismiss()
        }
    }
}
