import SwiftUI

struct ContentView: View {
    @State private var showTeamSetup = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: -70) {
                    Text("Goalonil")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 40)
                    

                    Button("New Game") {
                        showTeamSetup = true
                    }
                    .buttonStyle(ImageButtonStyle(imageName: "button-fancy"))
                    
                    Button("Tutorials") {
                        // TODO: Add navigation to tutorial screen
                    }
                    .buttonStyle(ImageButtonStyle(imageName: "button-basic"))

                    Button("Options") {
                        // TODO: Add navigation to options screen
                    }
                    .buttonStyle(ImageButtonStyle(imageName: "button-basic"))
                }
            }
            .fullScreenCover(isPresented: $showTeamSetup) {
                TeamSetupView()
            }
            .tiledBackground()
        }
    }
}

#Preview {
    ContentView()
}
