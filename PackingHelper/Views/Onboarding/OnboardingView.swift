import SwiftUI
import SwiftData

@MainActor
final class OnboardingViewModel: ObservableObject {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Published var currentPage = 0
    @Published var selectedColor: Color = .blue
    @Published var userName = ""
    @Published var defaultLocation: TripLocation?
    @Published var isMovingForward = true
    let colorOptions: [Color] = [.blue, .red, .green, .purple, .orange, .pink]
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveUser() {
        let hexColor = selectedColor.toHex() ?? "#007AFF"
        let user = User(name: userName, colorHex: hexColor)
        user.defaultLocation = defaultLocation
        modelContext.insert(user)
        try? modelContext.save()
        hasCompletedOnboarding = true
    }

    func nextPage() {
        if currentPage < 5 {
            isMovingForward = true
            currentPage += 1
        }
    }

    func previousPage() {
        if currentPage > 0 {
            isMovingForward = false
            currentPage -= 1
        }
    }
}

struct OnboardingContainerView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @Namespace private var animation
    @State private var dragOffset: CGFloat = 0

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(modelContext: modelContext))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar with back button and page indicator
            HStack {
                // Back button (only show after first page)
                if viewModel.currentPage > 0 {
                    Button(action: {
                        withAnimation {
                            viewModel.previousPage()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.caption)
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundStyle(viewModel.selectedColor)
                    }
                } else {
                    // Spacer to keep dots centered when no back button
                    Spacer()
                        .frame(width: 60)
                }

                Spacer()

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(index == viewModel.currentPage ? viewModel.selectedColor : Color.gray.opacity(0.3))
                            .frame(width: index == viewModel.currentPage ? 10 : 8, height: index == viewModel.currentPage ? 10 : 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentPage)
                    }
                }

                Spacer()

                // Balance spacer on the right
                Spacer()
                    .frame(width: 60)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))

            ZStack {
                switch viewModel.currentPage {
                case 0:
                    NameInputView(viewModel: viewModel, namespace: animation)
                        .transition(.asymmetric(
                            insertion: viewModel.isMovingForward ? .identity : .move(edge: .leading).combined(with: .opacity),
                            removal: viewModel.isMovingForward ? .move(edge: .leading).combined(with: .opacity) : .move(edge: .trailing).combined(with: .opacity)
                        ))
                case 1:
                    ColorSelectionView(viewModel: viewModel, namespace: animation)
                        .transition(.asymmetric(
                            insertion: viewModel.isMovingForward ? .move(edge: .trailing).combined(with: .opacity) : .move(edge: .leading).combined(with: .opacity),
                            removal: viewModel.isMovingForward ? .move(edge: .leading).combined(with: .opacity) : .move(edge: .trailing).combined(with: .opacity)
                        ))
                case 2:
                    DefaultOriginSelectionView(viewModel: viewModel, namespace: animation)
                        .transition(.asymmetric(
                            insertion: viewModel.isMovingForward ? .move(edge: .trailing).combined(with: .opacity) : .move(edge: .leading).combined(with: .opacity),
                            removal: viewModel.isMovingForward ? .move(edge: .leading).combined(with: .opacity) : .move(edge: .trailing).combined(with: .opacity)
                        ))
                case 3:
                    TripExplanationView(viewModel: viewModel, namespace: animation)
                        .transition(.asymmetric(
                            insertion: viewModel.isMovingForward ? .move(edge: .trailing).combined(with: .opacity) : .move(edge: .leading).combined(with: .opacity),
                            removal: viewModel.isMovingForward ? .move(edge: .leading).combined(with: .opacity) : .move(edge: .trailing).combined(with: .opacity)
                        ))
                case 4:
                    TemplateExplanationView(viewModel: viewModel, namespace: animation)
                        .transition(.asymmetric(
                            insertion: viewModel.isMovingForward ? .move(edge: .trailing).combined(with: .opacity) : .move(edge: .leading).combined(with: .opacity),
                            removal: viewModel.isMovingForward ? .move(edge: .leading).combined(with: .opacity) : .move(edge: .trailing).combined(with: .opacity)
                        ))
                case 5:
                    FinishView(viewModel: viewModel, namespace: animation)
                        .transition(.asymmetric(
                            insertion: viewModel.isMovingForward ? .move(edge: .trailing).combined(with: .opacity) : .move(edge: .leading).combined(with: .opacity),
                            removal: .identity
                        ))
                default:
                    EmptyView()
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.currentPage)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Only allow dragging to the right (going back)
                    if gesture.translation.width > 0 && viewModel.currentPage > 0 {
                        dragOffset = gesture.translation.width
                    }
                }
                .onEnded { gesture in
                    // If dragged more than 100 points to the right, go back
                    if gesture.translation.width > 100 && viewModel.currentPage > 0 {
                        withAnimation {
                            viewModel.previousPage()
                        }
                    }
                    dragOffset = 0
                }
        )
    }
}

struct NameInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                // Icon with circular background
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.orange.opacity(0.2), Color.pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.bounce, value: viewModel.currentPage)
                }
                .padding(.top, 40)

                Text("Welcome!")
                    .font(.largeTitle)
                    .bold()

                Text("Let's get to know each other")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    TextField("Enter your first name", text: $viewModel.userName)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isNameFieldFocused ? AnyShapeStyle(defaultLinearGradient) : AnyShapeStyle(Color.clear), lineWidth: 2)
                        )
                        .focused($isNameFieldFocused)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }

            Spacer()

            // Button at bottom
            Button(action: {
                isNameFieldFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.nextPage()
                }
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        viewModel.userName.isEmpty ?
                        AnyShapeStyle(Color.gray) :
                        AnyShapeStyle(defaultLinearGradient)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.userName.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

struct ColorSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                // Icon with circular background that animates with color changes
                ZStack {
                    Circle()
                        .fill(viewModel.selectedColor.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.selectedColor)

                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(viewModel.selectedColor)
                        .symbolEffect(.bounce, value: viewModel.selectedColor)
                }
                .padding(.top, 40)

                Text("Choose Your Color")
                    .font(.title)
                    .bold()

                Text("Pick your favorite color to personalize your experience")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                UserColorPicker(selectedColor: $viewModel.selectedColor)
                    .padding(.top, 8)
            }

            Spacer()

            // Button at bottom
            Button(action: viewModel.nextPage) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.selectedColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

struct DefaultOriginSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID
    @State private var showingLocationSearch = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                // Icon with circular background
                ZStack {
                    Circle()
                        .fill(viewModel.selectedColor.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(viewModel.selectedColor)
                        .symbolEffect(.bounce, value: viewModel.currentPage)
                }
                .padding(.top, 40)

                Text("Set Your Home Base")
                    .font(.title)
                    .bold()

                Text("Choose your default trip origin. You can change this anytime in settings.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Location selection button
                Button(action: {
                    showingLocationSearch = true
                }) {
                    HStack {
                        Image(systemName: viewModel.defaultLocation == nil ? "plus.circle.fill" : "mappin.circle.fill")
                            .font(.title3)

                        Text(viewModel.defaultLocation?.name ?? "Select Location")
                            .fontWeight(.medium)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .foregroundStyle(viewModel.defaultLocation == nil ? viewModel.selectedColor : .primary)
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }

            Spacer()

            // Buttons at bottom
            VStack(spacing: 12) {
                Button(action: viewModel.nextPage) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.selectedColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button("Skip for now") {
                    viewModel.nextPage()
                }
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showingLocationSearch) {
            LocationSearchView(location: $viewModel.defaultLocation)
        }
    }
}

struct TripExplanationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                // Icon with circular background
                ZStack {
                    Circle()
                        .fill(viewModel.selectedColor.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                    Image(systemName: "airplane.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(viewModel.selectedColor)
                        .symbolEffect(.bounce, value: viewModel.currentPage)
                }
                .padding(.top, 40)

                Text("Plan Your Trips")
                    .font(.title)
                    .bold()

                Text("Say goodbye to last-minute packing stress. Add your trip details and we'll help you stay organized from planning to departure.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Button at bottom
            Button(action: viewModel.nextPage) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.selectedColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

struct TemplateExplanationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                // Icon with circular background
                ZStack {
                    Circle()
                        .fill(viewModel.selectedColor.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                    Image(systemName: "checklist")
                        .font(.system(size: 50))
                        .foregroundStyle(viewModel.selectedColor)
                        .symbolEffect(.bounce, value: viewModel.currentPage)
                }
                .padding(.top, 40)

                Text("Packing Templates")
                    .font(.title)
                    .bold()

                Text("Build reusable packing lists for different trip types. Whether it's a beach vacation or a business trip, you'll always know exactly what to pack. Use template lists for as much as you can!")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Button at bottom
            Button(action: viewModel.nextPage) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.selectedColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

struct FinishView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                // Success icon with circular background
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                        .symbolEffect(.bounce, value: viewModel.currentPage)
                }
                .padding(.top, 40)

                Text("You're All Set!")
                    .font(.title)
                    .bold()

                Text("Start planning your next adventure")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Profile Summary Card
                VStack(spacing: 16) {
                    // User initial circle
                    ZStack {
                        Circle()
                            .fill(viewModel.selectedColor)
                            .frame(width: 60, height: 60)

                        Text(viewModel.userName.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 4) {
                        Text(viewModel.userName)
                            .font(.title3)
                            .fontWeight(.semibold)

                        if let location = viewModel.defaultLocation {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(viewModel.selectedColor)
                                Text(location.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }

            Spacer()

            // Button at bottom
            Button(action: viewModel.saveUser) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.selectedColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    OnboardingContainerView(modelContext: ModelContext(try! ModelContainer(for: User.self)))
}
