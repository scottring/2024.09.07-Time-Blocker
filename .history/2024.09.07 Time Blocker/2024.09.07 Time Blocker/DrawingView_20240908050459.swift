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
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = createInkingTool()
        canvasView.drawingPolicy = .pencilOnly
        canvasView.backgroundColor = .clear
        
        canvasView.isOpaque = false
        canvasView.allowsFingerDrawing = false
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = createInkingTool()
    }
    
    private func createInkingTool() -> PKInkingTool {
        let color = selectedColor == .black ? UIColor.black : UIColor(selectedColor)
        return PKInkingTool(.pen, color: color, width: penSize)
    }
}
