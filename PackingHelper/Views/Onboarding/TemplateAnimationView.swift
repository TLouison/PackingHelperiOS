import SwiftUI

struct TemplateAnimationView: View {
    let selectedColor: Color

    // Per-icon state (5 icons)
    @State private var iconScales: [CGFloat] = Array(repeating: 1.0, count: 5)
    @State private var checkOpacities: [Double] = Array(repeating: 0.0, count: 5)
    @State private var checkScales: [CGFloat] = Array(repeating: 0.0, count: 5)
    @State private var iconOffsets: [CGSize] = Array(repeating: .zero, count: 5)
    @State private var iconOpacities: [Double] = Array(repeating: 1.0, count: 5)

    // Cursor
    @State private var cursorOffset: CGSize = CGSize(width: -86, height: -61)
    @State private var cursorOpacity: Double = 0

    // Apply button
    @State private var applyScale: CGFloat = 1.0
    @State private var applyFlashed: Bool = false

    // Trip suitcase
    @State private var tripScale: CGFloat = 1.0

    // Layout constants (y offsets relative to ZStack center)
    private let iconsY: CGFloat = -75
    private let applyY: CGFloat = -10
    private let suitcaseY: CGFloat = 70

    private let selectedIndices = [0, 2, 4]

    // Icon x offsets: [-100, -50, 0, 50, 100]
    private func iconX(_ i: Int) -> CGFloat { CGFloat(i - 2) * 50 }

    // Cursor position to point at a given icon (fingertip ≈ icon center)
    // hand.point.up.left.fill: fingertip is near top-left of bounds (~14pt from center)
    private func cursorOffsetForIcon(_ i: Int) -> CGSize {
        CGSize(width: iconX(i) + 14, height: iconsY + 14)
    }

    private var cursorOffsetForApply: CGSize {
        CGSize(width: 14, height: applyY + 14)
    }

    // Offset to fly icon[i] from its row position to the suitcase
    private func flyOffset(for i: Int) -> CGSize {
        CGSize(width: -iconX(i), height: suitcaseY - iconsY)
    }

    // Animate a single icon tap: scale bounce + check badge appear
    private func tapIcon(index: Int) async throws {
        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
            iconScales[index] = 0.85
        }
        try await Task.sleep(for: .seconds(0.15))
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            iconScales[index] = 1.0
            checkOpacities[index] = 1.0
            checkScales[index] = 1.0
        }
        try await Task.sleep(for: .seconds(0.2))
    }

    private func runSequence() async throws {
        // Phase 1: cursor selects templates 0, 2, 4
        cursorOffset = cursorOffsetForIcon(0)
        withAnimation(.easeIn(duration: 0.25)) { cursorOpacity = 1 }
        try await Task.sleep(for: .seconds(0.3))

        for (i, idx) in selectedIndices.enumerated() {
            if i > 0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    cursorOffset = cursorOffsetForIcon(idx)
                }
                try await Task.sleep(for: .seconds(0.35))
            }
            try await tapIcon(index: idx)
        }

        // Phase 2: cursor taps Apply button
        withAnimation(.easeInOut(duration: 0.3)) { cursorOffset = cursorOffsetForApply }
        try await Task.sleep(for: .seconds(0.35))

        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
            applyScale = 0.9
            applyFlashed = true
        }
        try await Task.sleep(for: .seconds(0.15))
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { applyScale = 1.0 }
        try await Task.sleep(for: .seconds(0.1))
        withAnimation(.easeOut(duration: 0.15)) { applyFlashed = false }
        withAnimation(.easeOut(duration: 0.2)) { cursorOpacity = 0 }
        try await Task.sleep(for: .seconds(0.25))

        // Phase 3: selected templates fly to suitcase
        withAnimation(.easeIn(duration: 0.5)) {
            for idx in selectedIndices {
                iconOffsets[idx] = flyOffset(for: idx)
                iconOpacities[idx] = 0
            }
        }
        try await Task.sleep(for: .seconds(0.35))

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { tripScale = 1.08 }
        try await Task.sleep(for: .seconds(0.2))
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { tripScale = 1.0 }
        try await Task.sleep(for: .seconds(0.2))

        // Phase 4: hold end state
        try await Task.sleep(for: .seconds(3.0))

        // Phase 5: reset — checks bounce off
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            for idx in selectedIndices {
                checkScales[idx] = 0
                checkOpacities[idx] = 0
            }
        }
        try await Task.sleep(for: .seconds(0.3))

        // Snap icons back to original position (invisible at this point)
        for idx in selectedIndices { iconOffsets[idx] = .zero }
        // Fade opacity back in with bounce
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            for idx in selectedIndices { iconOpacities[idx] = 1.0 }
        }
        try await Task.sleep(for: .seconds(0.5))
    }

    var body: some View {
        ZStack {
            // Template icons row
            HStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { index in
                    ZStack(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(selectedColor.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.system(size: 16))
                                .foregroundStyle(selectedColor)
                        }
                        .scaleEffect(iconScales[index])

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.green)
                            .offset(x: 4, y: 4)
                            .opacity(checkOpacities[index])
                            .scaleEffect(checkScales[index])
                    }
                    .offset(iconOffsets[index])
                    .opacity(iconOpacities[index])
                }
            }
            .offset(y: iconsY)

            // Apply Templates pill button (decorative)
            Text("Apply Templates")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(selectedColor)
                .clipShape(Capsule())
                .brightness(applyFlashed ? 0.2 : 0)
                .scaleEffect(applyScale)
                .offset(y: applyY)

            // Suitcase (trip destination)
            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.15))
                    .frame(width: 70, height: 70)
                Image(systemName: "suitcase.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(selectedColor)
            }
            .scaleEffect(tripScale)
            .offset(y: suitcaseY)

            // Cursor overlay
            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 28))
                .foregroundStyle(.primary)
                .opacity(cursorOpacity)
                .offset(cursorOffset)
        }
        .frame(height: 220)
        .task {
            while !Task.isCancelled {
                do { try await runSequence() } catch { break }
            }
        }
    }
}

#Preview {
    TemplateAnimationView(selectedColor: .blue)
        .padding()
}
