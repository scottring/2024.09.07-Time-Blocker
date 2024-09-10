//
//          ContentView.swift
//  2024.09.07 Time Blocker
//
//  Created by Scott Kaufman on 9/7/24.
//

import SwiftUI
import PencilKit
import UIKit

struct ContentView: View {
    @State private var selectedColor: Color = .black
    @State private var penSize: CGFloat = 2.0
    @State private var canvasView = PKCanvasView()
    @State private var currentWeek = "Untitled Week"
    @State private var savedSheets: [String: PKDrawing] = [:]
    @State private var isNamingSheet = false
    @State private var newSheetName = ""
    @State private var showingSavedSheets = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 20) // 20 pixels of padding above the header
                    
                    HStack {
                        // Left side
                        HStack(spacing: 10) {
                            Menu {
                                ForEach(Array(savedSheets.keys).sorted(), id: \.self) { name in
                                    Button(action: { loadSheet(name: name) }) {
                                        Text(name).font(.system(size: 14))
                                    }
                                }
                                if !savedSheets.isEmpty {
                                    Divider()
                                    Button(role: .destructive, action: { deleteCurrentSheet() }) {
                                        Text("Delete Current Sheet").font(.system(size: 14))
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(currentWeek)
                                    Image(systemName: "chevron.down")
                                }
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            }
                            
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                                .onTapGesture {
                                    isNamingSheet = true
                                }
                            
                            Image(systemName: "plus")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    newSheet()
                                }
                        }
                        
                        Spacer()
                        
                        // Center
                        ColorPickerView(selectedColor: $selectedColor, penSize: $penSize)
                        
                        Spacer()
                        
                        // Right side
                        Button(action: {
                            canvasView.drawing = PKDrawing()
                        }) {
                            Image(systemName: "trash")
                        }
                        
                        Button(action: printCurrentSheet) {
                            Image(systemName: "printer")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                        }
                    }
                    .padding()
                    .frame(height: 44) // Set a fixed height for the header
                    
                    VStack(spacing: 0) {
                        DayLabelsView(width: geometry.size.width)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            ZStack {
                                GridView(excludeDayLabels: true)
                                    .frame(width: geometry.size.width)
                                
                                DrawingView(canvasView: $canvasView, selectedColor: $selectedColor, penSize: $penSize)
                                    .frame(width: geometry.size.width, height: geometry.size.height * 2)
                            }
                        }
                    }
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .alert("Name Your Sheet", isPresented: $isNamingSheet) {
                TextField("Sheet Name", text: $newSheetName)
                    .font(.system(size: 14))
                Button("Save", action: saveCurrentSheet)
                    .font(.system(size: 14))
                Button("Cancel", role: .cancel) {}
                    .font(.system(size: 14))
            } message: {
                Text("Enter a name for this week's sheet")
                    .font(.system(size: 14))
            }
        }
    }
    
    private func newSheet() {
        currentWeek = "Untitled Week"
        canvasView.drawing = PKDrawing()
    }
    
    private func saveCurrentSheet() {
        if !newSheetName.isEmpty {
            savedSheets[newSheetName] = canvasView.drawing
            currentWeek = newSheetName
            newSheetName = ""
        }
    }
    
    private func loadSheet(name: String) {
        if let drawing = savedSheets[name] {
            canvasView.drawing = drawing
            currentWeek = name
        }
    }
    
    private func deleteCurrentSheet() {
        savedSheets.removeValue(forKey: currentWeek)
        newSheet()
    }
    
    private func printCurrentSheet() {
        let printView = SimplePrintView(drawing: canvasView.drawing)
        let hostingController = UIHostingController(rootView: printView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 792, height: 612)
        
        // Ensure the view is rendered
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: hostingController.view.bounds.size)
        let image = renderer.image { ctx in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
        
        // Debug: Save the image
        if let data = image.pngData(), let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("debug_print_image.png")
            try? data.write(to: fileURL)
            print("Debug image saved to: \(fileURL.path)")
        }
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Time Blocker - \(currentWeek)"
        printInfo.outputType = .general
        printInfo.orientation = .landscape
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = image
        
        DispatchQueue.main.async {
            printController.present(animated: true) { _, completed, error in
                if let error = error {
                    print("Printing error: \(error.localizedDescription)")
                } else if completed {
                    print("Printing completed")
                } else {
                    print("Printing cancelled")
                }
            }
        }
    }
}

struct DayLabelsView: View {
    let width: CGFloat
    let daysOfWeek = ["Time", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(width: day == "Time" ? width / 8.5 * 1.5 : width / 8.5)
                    .border(Color.gray.opacity(0.3))
            }
        }
    }
}

struct HeaderView: View {
    @Binding var selectedColor: Color
    @Binding var penSize: CGFloat
    @Binding var canvasView: PKCanvasView
    
    var body: some View {
        HStack {
            Image("logo") // Replace with your logo
            Spacer()
            ColorPickerView(selectedColor: $selectedColor, penSize: $penSize)
            Spacer()
            Button(action: {
                canvasView.drawing = PKDrawing()
            }) {
                Image(systemName: "trash")
            }
            Button(action: {
                // Implement print functionality
            }) {
                Image(systemName: "printer")
            }
        }
        .frame(height: 50)
        .padding(.horizontal)
        .padding(.vertical, 20)
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Binding var penSize: CGFloat
    let colors: [Color] = [Color(UIColor.black), .red, .blue, .green, .yellow, .purple]
    let sizes: [CGFloat] = [1, 2, 4, 6, 8]
    
    var body: some View {
        HStack {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().stroke(Color.gray, lineWidth: isColorSelected(color) ? 2 : 0))
                    .onTapGesture {
                        selectedColor = color
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
    
    private func isColorSelected(_ color: Color) -> Bool {
        if color == Color(UIColor.black) && selectedColor == Color(UIColor.black) {
            return true
        }
        return selectedColor == color
    }
}

struct GridView: View {
    let excludeDayLabels: Bool
    let hours = 18 // 5 AM to 10 PM
    let days = ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if !excludeDayLabels {
                    HStack(spacing: 0) {
                        ForEach(days, id: \.self) { day in
                            Text(day)
                                .frame(width: geometry.size.width / 8, height: 20)
                                .font(.system(size: 10))
                                .border(Color.gray.opacity(0.3), width: 0.5)
                        }
                    }
                }
                
                ForEach(0..<hours, id: \.self) { hour in
                    HStack(spacing: 0) {
                        Text(formatHour(hour: hour + 5))
                            .frame(width: geometry.size.width / 8, height: (geometry.size.height - 20) / CGFloat(hours))
                            .font(.system(size: 8))
                        ForEach(1..<8) { _ in
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: geometry.size.width / 8, height: (geometry.size.height - 20) / CGFloat(hours))
                                .border(Color.gray.opacity(0.3), width: 0.5)
                        }
                    }
                }
            }
        }
    }
    
    func formatHour(hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let adjustedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return String(format: "%d %@", adjustedHour, period)
    }
}

struct SimplePrintView: View {
    let drawing: PKDrawing
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Text("Time Blocker")
                        .font(.largeTitle)
                        .padding()
                    
                    ZStack {
                        GridView(excludeDayLabels: false)
                            .foregroundColor(.gray.opacity(0.3))
                        
                        DrawingImageView(drawing: drawing)
                    }
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.8)
                    .border(Color.black, width: 2)
                }
            }
        }
        .frame(width: 792, height: 612) // 11x8.5 inches at 72 DPI
    }
}

#Preview {
    ContentView()
}
