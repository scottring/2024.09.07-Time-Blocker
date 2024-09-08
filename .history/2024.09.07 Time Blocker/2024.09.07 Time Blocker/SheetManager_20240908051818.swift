import Foundation
import PencilKit

class SheetManager: ObservableObject {
    @Published var sheets: [Sheet] = []
    @Published var currentSheet: Sheet?
    
    private let saveKey = "SavedSheets"
    
    init() {
        loadSheets()
    }
    
    func addSheet(name: String, drawing: PKDrawing) {
        let newSheet = Sheet(name: name, drawing: drawing)
        sheets.append(newSheet)
        currentSheet = newSheet
        saveSheets()
    }
    
    func deleteSheet(at offsets: IndexSet) {
        sheets.remove(atOffsets: offsets)
        saveSheets()
    }
    
    func updateCurrentSheet(drawing: PKDrawing) {
        guard let index = sheets.firstIndex(where: { $0.id == currentSheet?.id }) else { return }
        sheets[index].drawing = try! JSONEncoder().encode(drawing)
        saveSheets()
    }
    
    private func saveSheets() {
        if let encoded = try? JSONEncoder().encode(sheets) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadSheets() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Sheet].self, from: data) {
            sheets = decoded
            currentSheet = sheets.first
        }
    }
}