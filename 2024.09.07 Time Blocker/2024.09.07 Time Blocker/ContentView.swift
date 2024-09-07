//
//  ContentView.swift
//  2024.09.07 Time Blocker
//
//  Created by Scott Kaufman on 9/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var scale: CGFloat = 1.0
    @State private var selectedColor: Color = .black

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(selectedColor: $selectedColor)
            
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
        .edgesIgnoringSafeArea(.all)
    }
}

struct HeaderView: View {
    @Binding var selectedColor: Color
    
    var body: some View {
        HStack {
            Image("logo") // Replace with your logo
            Spacer()
            ColorPickerView(selectedColor: $selectedColor)
            Spacer()
            Button(action: {
                // Implement print functionality
            }) {
                Image(systemName: "printer")
            }
        }
        .frame(height: 50)
        .padding(.horizontal)
        .padding(.vertical, 20) // Add 20 pixels of padding to top and bottom
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple]
    
    var body: some View {
        HStack {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        selectedColor = color
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
            .frame(width: width)
            .border(Color.gray.opacity(0.3))
    }
}

struct TimeCell: View {
    let hour: Int
    let width: CGFloat
    
    var body: some View {
        VStack {
            Text("Day/Time")
                .font(.system(size: 8))
                .foregroundColor(.gray.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(formatTime(hour: hour))
                .font(.system(size: 14))
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
