import SwiftUI

struct ContentView: View {
    @State private var showTeamSetup = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 50) {
                    Image("golonil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 140)
                        .offset(y: -20)
                    
                    Button(action: {
                        showTeamSetup = true
                    }) {
                        Image("new-button-newgame")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 70)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                    }) {
                        Image("new-button-tutorials")                             .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 70)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                    }) {
                        Image("new-button-options")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 70)
                    }
                    .buttonStyle(PlainButtonStyle())
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
