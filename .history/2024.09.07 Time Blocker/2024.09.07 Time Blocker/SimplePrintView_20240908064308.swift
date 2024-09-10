//
//  SimplePrintView.swift
//  2024.09.07 Time Blocker
//
//  Created by Scott Kaufman on 9/8/24.
//

import SwiftUI
import PencilKit

struct SimplePrintView: View {
    let drawing: PKDrawing
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Time Blocker")
                    .font(.largeTitle)
                    .padding()
                
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: 700, height: 500)
                    .overlay(
                        DrawingImageView(drawing: drawing)
                    )
            }
        }
        .frame(width: 792, height: 612)
    }
}
