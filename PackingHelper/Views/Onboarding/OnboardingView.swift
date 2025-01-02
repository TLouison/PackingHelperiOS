import SwiftUI
import SwiftData

@MainActor
final class OnboardingViewModel: ObservableObject {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Published var currentPage = 0
    @Published var selectedColor: Color = .blue
    @Published var userName = ""
    let colorOptions: [Color] = [.blue, .red, .green, .purple, .orange, .pink]
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveUser() {
        let hexColor = selectedColor.toHex() ?? "#007AFF"
        let user = User(name: userName, colorHex: hexColor)
        modelContext.insert(user)
        try? modelContext.save()
        hasCompletedOnboarding = true
    }
    
    func nextPage() {
        if currentPage < 4 {
            currentPage += 1
        }
    }
}

struct OnboardingContainerView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @Namespace private var animation
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ZStack {
            switch viewModel.currentPage {
            case 0:
                NameInputView(viewModel: viewModel, namespace: animation)
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case 1:
                ColorSelectionView(viewModel: viewModel, namespace: animation)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case 2:
                TripExplanationView(viewModel: viewModel, namespace: animation)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case 3:
                TemplateExplanationView(viewModel: viewModel, namespace: animation)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case 4:
                FinishView(viewModel: viewModel, namespace: animation)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .identity
                    ))
            default:
                EmptyView()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.currentPage)
    }
}

struct NameInputView: View {
    @StateObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.largeTitle)
                .bold()
            
            Text("Let's get to know each other")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            TextField("Your name", text: $viewModel.userName)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(defaultLinearGradient, lineWidth: 2)
                )
                .padding(.horizontal)
            
            Button(action: viewModel.nextPage) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.userName.isEmpty ? .gray : .blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(viewModel.userName.isEmpty)
            .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

struct ColorSelectionView: View {
    @StateObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 60))
                .foregroundStyle(viewModel.selectedColor)
                .padding(.bottom, 8)
            
            Text("Choose Your Color")
                .font(.title)
                .bold()
            
            Text("Pick your favorite color to personalize your experience")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            UserColorPicker(selectedColor: $viewModel.selectedColor)
            
            Button("Continue", action: viewModel.nextPage)
                .buttonStyle(.borderedProminent)
                .tint(viewModel.selectedColor)
                .padding(.top)
        }
        .padding()
    }
}

struct TripExplanationView: View {
    @StateObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "airplane.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding(.bottom, 8)
            
            Text("Plan Your Trips")
                .font(.title)
                .bold()
            
            Text("Create and organize your trips easily. Add destinations, dates, and keep track of all your travel plans in one place.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Continue", action: viewModel.nextPage)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
}

struct TemplateExplanationView: View {
    @StateObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding(.bottom, 8)
            
            Text("Packing Templates")
                .font(.title)
                .bold()
            
            Text("Use and customize packing templates for different types of trips. Never forget essential items again!")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Continue", action: viewModel.nextPage)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
}

struct FinishView: View {
    @StateObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
                .padding(.bottom, 8)
            
            Text("You're All Set!")
                .font(.title)
                .bold()
            
            Text("Start planning your next adventure")
                .multilineTextAlignment(.center)
            
            Button("Get Started", action: viewModel.saveUser)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
}

#Preview {
    OnboardingContainerView(modelContext: ModelContext(try! ModelContainer(for: User.self)))
}
