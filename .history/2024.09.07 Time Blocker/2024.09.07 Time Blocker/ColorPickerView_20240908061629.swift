//
//  ColorPickerView.swift
//  2024.09.07 Time Blocker
//
//  Created by Scott Kaufman on 9/8/24.
//

import SwiftUI
import PencilKit

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Binding var penSize: CGFloat
    @Binding var canvasView: PKCanvasView
    @Binding var isErasing: Bool
    let colors: [Color] = [.black, .red, .blue, .green, .yellow, .purple]
    let sizes: [CGFloat] = [1, 2, 4, 6, 8]
    
    var body: some View {
        HStack(spacing: 10) {
            // Undo button
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                )
                .onTapGesture {
                    canvasView.undoManager?.undo()
                }
            
            // Erase button
            Circle()
                .fill(isErasing ? Color.blue : Color.gray.opacity(0.2))
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "eraser")
                        .foregroundColor(isErasing ? .white : .blue)
                        .font(.system(size: 14))
                )
                .onTapGesture {
                    isErasing.toggle()
                }
            
            // Existing color picker
            HStack(spacing: 5) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.gray, lineWidth: selectedColor == color ? 2 : 0))
                        .onTapGesture {
                            selectedColor = color
                            isErasing = false
                        }
                }
                Divider().frame(height: 20)
                ForEach(sizes, id: \.self) { size in
                    Circle()
                        .fill(selectedColor)
                        .frame(width: size * 2, height: size * 2)
                        .overlay(Circle().stroke(Color.gray, lineWidth: penSize == size ? 2 : 0))
                        .onTapGesture {
                            penSize = size
                        }
                }
            }
        }
        .frame(height: 44) // Match the header height
    }
}
