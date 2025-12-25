import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    
    // Settings
    @State private var isDarkMode = false
    @State private var gridStyle: GridStyle = .none
    @State private var showMenu = false

    var body: some View {
        ZStack {
            // Layer 1: The Paper (Grid)
            GridBackground(style: gridStyle, isDark: isDarkMode)
                .ignoresSafeArea()
            
            // Layer 2: The Drawing
            DrawingCanvas(canvas: $canvasView, isDark: isDarkMode)
            
            // Layer 3: The Menu (Top Right)
            VStack {
                HStack {
                    Spacer() // Pushes everything to the right
                    
                    // Menu Button
                    VStack(alignment: .trailing, spacing: 10) {
                        Button(action: { showMenu.toggle() }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        if showMenu {
                            VStack(alignment: .trailing, spacing: 15) {
                                // 1. Dark Mode Toggle
                                Button(action: { isDarkMode.toggle() }) {
                                    HStack {
                                        Text(isDarkMode ? "Light Mode" : "Dark Mode")
                                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                    }
                                }
                                
                                Divider()
                                
                                // 2. Grid Options
                                Text("Paper Style").font(.caption).foregroundColor(.gray)
                                HStack {
                                    Button(action: { gridStyle = .none }) { Image(systemName: "square") }
                                    Button(action: { gridStyle = .lines }) { Image(systemName: "list.dash") }
                                    Button(action: { gridStyle = .grid }) { Image(systemName: "grid") }
                                    Button(action: { gridStyle = .dots }) { Image(systemName: "circle.grid.2x2") }
                                }
                                .font(.title3)
                                
                                Divider()
                                
                                // 3. Hover Settings (Link to System Settings)
                                Button(action: {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Text("Pencil Settings")
                                        Image(systemName: "applepencil")
                                    }
                                }
                                .font(.caption)
                            }
                            .padding()
                            .background(Material.thinMaterial)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                    }
                    .padding(.top, 50) // Move down from dynamic island/bezel
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onAppear {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
    }
}

#Preview {
    ContentView()
}
