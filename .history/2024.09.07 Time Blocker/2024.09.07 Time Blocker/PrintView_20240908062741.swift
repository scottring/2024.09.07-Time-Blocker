//
//  PrintView.swift
//  2024.09.07 Time Blocker
//
//  Created by Scott Kaufman on 9/8/24.
//

import Foundation
import SwiftUI
import PencilKit

struct PrintView: View {
    let drawing: PKDrawing
    let gridColor: Color = .gray.opacity(0.3)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GridView(excludeDayLabels: false)
                    .foregroundColor(gridColor)
                
                DrawingImageView(drawing: drawing)
            }
        }
        .frame(width: 792, height: 612) // 11x8.5 inches at 72 DPI
    }
}

struct DrawingImageView: UIViewRepresentable {
    let drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawing = drawing
        canvasView.isUserInteractionEnabled = false
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
    }
}
