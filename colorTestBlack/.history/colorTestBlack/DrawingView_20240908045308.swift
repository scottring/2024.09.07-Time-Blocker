import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
    @Binding var selectedColor: UIColor
    @Binding var penSize: CGFloat
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.tool = createInkingTool()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let toolPicker = PKToolPicker()
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
        
        print("makeUIView - Initial tool: \(canvasView.tool)")
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = createInkingTool()
        print("updateUIView - Updated tool: \(uiView.tool)")
    }
    
    private func createInkingTool() -> PKInkingTool {
        let color = selectedColor
        print("createInkingTool - Selected color: \(color)")
        return PKInkingTool(.pen, color: color, width: penSize)
    }
}