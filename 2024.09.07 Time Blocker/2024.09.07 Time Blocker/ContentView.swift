//
//  ContentView.swift
//  2024.09.07 Time Blocker
//
//  Created by Scott Kaufman on 9/7/24.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var scale: CGFloat = 1.0
    @State private var selectedColor: Color = .black
    @State private var penSize: CGFloat = 2.0
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    HeaderView(selectedColor: $selectedColor, penSize: $penSize, canvasView: $canvasView)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        GridView()
                            .scaleEffect(scale)
                            .gesture(MagnificationGesture()
                                .onChanged { value in
                                    scale = min(max(value, 1), 3)
                                }
                            )
                    }
                }
                .background(Color.white)
                
                DrawingView(canvasView: $canvasView, selectedColor: $selectedColor, penSize: $penSize)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
            }
        }
        .edgesIgnoringSafeArea(.all)
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
    let colors: [Color] = [.black, .red, .blue, .green, .yellow, .purple]
    let sizes: [CGFloat] = [1, 2, 4, 6, 8]
    
    var body: some View {
        HStack {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().stroke(Color.gray, lineWidth: selectedColor == color ? 2 : 0))
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
}

struct GridView: View {
    let columns = 8
    let rows = 18 // 5 AM to 10 PM is 18 hours
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let regularColumnWidth = totalWidth / 8.5
            let timeColumnWidth = regularColumnWidth * 1.5
            
            VStack(spacing: 0) {
                // Day headers
                HStack(spacing: 0) {
                    TimeColumnHeader(width: timeColumnWidth)
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .frame(width: regularColumnWidth)
                            .border(Color.gray.opacity(0.3))
                    }
                }
                
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
