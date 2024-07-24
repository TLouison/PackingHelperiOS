//
//  NewUserOnboardingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct NewUserOnboardingView: View {
    private enum CurrentView {
        case name, trips, lists, users, done
    }
    
    private enum MovementDirection {
        case forward, backward
    }
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentView: CurrentView = .name
    @State private var movementDirection: MovementDirection = .forward
    @State private var name: String = ""
    
    var prevButtonText: String {
        switch currentView {
        case .name:
            ""
        case .trips:
            "Welcome"
        case .lists:
            "Trips"
        case .users:
            "Lists"
        case .done:
            "Error Occurred"
        }
    }
    
    var nextButtonText: String {
        switch currentView {
        case .name:
            "Create User"
        case .trips:
            "Lists"
        case .lists:
            "Packers"
        case .users:
            "Get Started!"
        case .done:
            "Error Occurred"
        }
    }
    
    @ViewBuilder
    var visibleView: some View {
        switch currentView {
        case .name:
            NewUserGetNameView(name: $name)
        case .trips:
            NewUserTripsExplainer()
        case .lists:
            NewUserPackingListExplainer()
        case .users:
            NewUserPackersExplainer(userName: $name)
        case .done:
            EmptyView()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            visibleView
                .padding()
                .transition(.pushAndPull(movementDirection == .forward ? .trailing : .leading))
                .frame(maxHeight: .infinity)
            
            Spacer()
            
            HStack {
                if prevScreen() != .done {
                    Button(prevButtonText) {
                        withAnimation {
                            movementDirection = .backward
                            currentView = prevScreen()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thickMaterial)
                    .rounded()
                    .shaded()
                    .disabled(prevScreen() == .done)
                }
                
                Button(nextButtonText) {
                    if currentView == .users {
                        saveNewUser()
                        hasLaunchedBefore = true
                        dismiss()
                    }
                    
                    withAnimation {
                        movementDirection = .forward
                        currentView = nextScreen()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thickMaterial)
                .rounded()
                .shaded()
                .disabled(name == "" && nextScreen() == .done)
            }
            .padding()
        }
    }
    
    private func nextScreen() -> CurrentView {
        switch currentView {
            case .name:
                return CurrentView.trips
            case .trips:
                return CurrentView.lists
            case .lists:
                return CurrentView.users
            case .users:
                return CurrentView.done
            case .done:
                print("Should never reach here!")
                return CurrentView.done
            }
    }
    
    private func prevScreen() -> CurrentView {
        switch currentView {
            case .name:
                return CurrentView.done
            case .trips:
                return CurrentView.name
            case .lists:
                return CurrentView.trips
            case .users:
                return CurrentView.lists
            case .done:
                print("Should never reach here!")
                return CurrentView.done
            }
    }
    
    func saveNewUser() {
        let newUser = User(name: name)
        modelContext.insert(newUser)
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    NewUserOnboardingView()
}
