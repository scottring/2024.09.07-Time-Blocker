//
//  DrawingView.swift
//  2024.09.07 Time Blocker
//
//  Created by Scott Kaufman on 9/7/24.
//

import Foundation
import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var selectedColor: Color
    @Binding var penSize: CGFloat
    @Binding var isErasing: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = createTool()
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = createTool()
    }
    
    private func createTool() -> PKTool {
        if isErasing {
            return PKEraserTool(.vector)
        } else {
            return PKInkingTool(.pen, color: UIColor(selectedColor), width: penSize)
        }
    }
}
