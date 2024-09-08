//
//          ContentView.swift
//  2024.09.07 Time Blocker
//
//  Created by Scott Kaufman on 9/7/24.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var selectedColor: Color = .black
    @State private var penSize: CGFloat = 2.0
    @State private var canvasView = PKCanvasView()
    @State private var currentWeek = "Week of 2024-09-08"
    @State private var savedSheets: [String: PKDrawing] = [:]
    @State private var isAddingNewSheet = false
    @State private var showSaveButton = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Picker("Select Week", selection: $sheetName) {
                        ForEach(Array(savedSheets.keys).sorted(), id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.system(size: 14))
                    .frame(width: 150)
                    .onChange(of: sheetName) { newValue in
                        loadSheet(name: newValue)
                    }
                    .overlay(
                        HStack {
                            Text(sheetName)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                    )
                    
                    Button("New Week") {
                        newSheetName = generateNewSheetName()
                        isAddingNewSheet = true
                    }
                    .font(.system(size: 14))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    
                    Spacer()
                    ColorPickerView(selectedColor: $selectedColor, penSize: $penSize)
                    Button(action: {
                        canvasView.drawing = PKDrawing()
                    }) {
                        Image(systemName: "trash")
                    }
                }
                .padding()
                
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
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .alert(isPresented: $isAddingNewSheet) {
                Alert(
                    title: Text("Add New Week").font(.system(size: 14)),
                    message: Text("Enter a name for the new week:").font(.system(size: 14)),
                    primaryButton: .default(Text("Add").font(.system(size: 14))) {
                        newSheet()
                    },
                    secondaryButton: .cancel(Text("Cancel").font(.system(size: 14)))
                )
            }
            .overlay(
                Group {
                    if isAddingNewSheet {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .overlay(
                                VStack {
                                    Text("Add New Week").font(.system(size: 14))
                                    TextField("Week Name", text: $newSheetName)
                                        .font(.system(size: 14))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                    HStack {
                                        Button("Cancel") {
                                            isAddingNewSheet = false
                                        }
                                        .font(.system(size: 14))
                                        Button("Add") {
                                            newSheet()
                                            isAddingNewSheet = false
                                        }
                                        .font(.system(size: 14))
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding()
                            )
                    }
                }
            )
        }
    }
    
    private func newSheet() {
        saveCurrentSheet() // Save the current sheet before creating a new one
        sheetName = newSheetName
        canvasView.drawing = PKDrawing() // Clear the canvas for the new week
        saveCurrentSheet() // Save the new empty sheet
    }
    
    private func generateNewSheetName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return "Week of " + dateFormatter.string(from: Date())
    }
    
    private func saveCurrentSheet() {
        savedSheets[sheetName] = canvasView.drawing
    }
    
    private func loadSheet(name: String) {
        if let drawing = savedSheets[name] {
            canvasView.drawing = drawing
            sheetName = name
        }
    }
    
    private func deleteCurrentSheet() {
        savedSheets.removeValue(forKey: sheetName)
        newSheet()
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
    let columns = 8
    let rows = 18 // 5 AM to 10 PM is 18 hours
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let excludeDayLabels: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let regularColumnWidth = totalWidth / 8.5
            let timeColumnWidth = regularColumnWidth * 1.5
            
            VStack(spacing: 0) {
                // Grid cells
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        TimeCell(hour: row + 5, width: timeColumnWidth)
                        ForEach(0..<7, id: \.self) { column in
                            GridCell(width: regularColumnWidth, day: daysOfWeek[column], time: formatTime(hour: row + 5))
                        }
                    }
                }
            }
            .frame(width: totalWidth)
        }
    }
    
    func formatTime(hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let adjustedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return String(format: "%d:00 %@", adjustedHour, period)
    }
}

struct TimeColumnHeader: View {
    let width: CGFloat
    
    var body: some View {
        Text("Time")
            .font(.system(size: 14))
            .foregroundColor(.black)
            .frame(width: width)
            .border(Color.gray.opacity(0.3))
    }
}

struct TimeCell: View {
    let hour: Int
    let width: CGFloat
    
    var body: some View {
        VStack {
            Text(formatTime(hour: hour))
                .font(.system(size: 14))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: width, height: UIScreen.main.bounds.height / 12)
        .border(Color.gray.opacity(0.3))
    }
    
    func formatTime(hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let adjustedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return String(format: "%d:00 %@", adjustedHour, period)
    }
}

struct GridCell: View {
    let width: CGFloat
    let day: String
    let time: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.white)
                .frame(width: width, height: UIScreen.main.bounds.height / 12)
                .border(Color.gray.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 0) {
                Text(day)
                    .font(.system(size: 8))
                    .foregroundColor(Color.gray.opacity(0.6))
                Text(time)
                    .font(.system(size: 8))
                    .foregroundColor(Color.gray.opacity(0.6))
            }
            .padding(4)
        }
    }
}

#Preview {
    ContentView()
}
