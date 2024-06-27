//
//  UserColorPickerV.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/26/24.
//

import SwiftUI

struct UserColorPicker: View {
    @Binding var selectedColor: Color
    
    @ViewBuilder private func colorButtonBase(color: Color) -> some View {
        Button {
            withAnimation(.snappy) {
                print("Setting color to \(color)")
                self.selectedColor = color
            }
        } label: {
            color
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .rounded()
        .shaded()
    }
    
    @ViewBuilder private func colorButton(color: Color) -> some View {
        if color == selectedColor {
            colorButtonBase(color: color)
                .overlay {
                    RoundedRectangle(cornerRadius: defaultCornerRadius)
                        .stroke(Color.secondary.opacity(.infinity), lineWidth: 4)
                }
        } else {
            colorButtonBase(color: color)
        }
    }
    var body: some View {
            Grid {
                GridRow {
                    colorButton(color: .red)
                    colorButton(color: .orange)
                    colorButton(color: .yellow)
                    colorButton(color: .green)
                }
                GridRow {
                    colorButton(color: .teal)
                    colorButton(color: .blue)
                    colorButton(color: .indigo)
                    colorButton(color: .purple)
                }
            }
    }
}

@available(iOS 18, *)
#Preview {
    @Previewable @State var selectedColor: Color = Color.accentColor
    UserColorPicker(selectedColor: $selectedColor)
}
