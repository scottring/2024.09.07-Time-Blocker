//
//  ContentView.swift
//  2024.09.07 Time Blocker
//
//  Created by Scott Kaufman on 9/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedColor: UIColor = .black
    @State private var penSize: CGFloat = 2.0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            ColorPickerView(selectedColor: $selectedColor, penSize: $penSize)
            DrawingView(selectedColor: $selectedColor, penSize: $penSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        }
        .onAppear {
            handleAppearanceChange()
        }
        .onChange(of: colorScheme) { _ in
            handleAppearanceChange()
        }
    }
    
    private func handleAppearanceChange() {
        if colorScheme == .dark {
            print("Dark mode is enabled")
        } else {
            print("Light mode is enabled")
        }
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: UIColor
    @Binding var penSize: CGFloat
    let colors: [UIColor] = [.black, .red, .blue, .green, .yellow, .purple]
    let sizes: [CGFloat] = [1, 2, 4, 6, 8]
    
    var body: some View {
        HStack {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(Color(color))
                    .frame(width: 20, height: 20)
                    .overlay(Circle().stroke(Color.gray, lineWidth: isColorSelected(color) ? 2 : 0))
                    .onTapGesture {
                        selectedColor = color
                        print("Color selected: \(color)")
                    }
            }
            Divider().frame(height: 20)
            ForEach(sizes, id: \.self) { size in
                Circle()
                    .fill(Color(selectedColor))
                    .frame(width: size * 2, height: size * 2)
                    .overlay(Circle().stroke(Color.gray, lineWidth: penSize == size ? 2 : 0))
                    .onTapGesture {
                        penSize = size
                        print("Pen size selected: \(size)")
                    }
            }
        }
    }
    
    private func isColorSelected(_ color: UIColor) -> Bool {
        return selectedColor == color
    }
}

#Preview {
    ContentView()
}

