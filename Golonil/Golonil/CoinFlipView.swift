import SwiftUI

struct CoinFlipView: View {
    var team1Name: String
    var team2Name: String
    var team1Color: Color
    var team2Color: Color

    @Environment(\.dismiss) var dismiss
    @State private var flippedTeam: String? = nil
    @State private var isFlipping = false
    @State private var rotationDegrees = 0.0
    @State private var showCardSelection = false
    
    // Add these state variables for team cards
    @State private var team1Cards: [String] = []
    @State private var team2Cards: [String] = []
    
    // Helper computed properties to determine which team has which color
    private var redTeamName: String {
        return team1Color == Color(hex: "#FF2F2F") ? team1Name : team2Name
    }
    
    private var blueTeamName: String {
        return team1Color == Color(hex: "#004AFF") ? team1Name : team2Name
    }

    var body: some View {
        ZStack {
            Image("BackgroundPattern")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header with pause button only
                HStack {
                    Button(action: {
                        // Pause action
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()

                // 📝 Instruction or Result
                if let team = flippedTeam {
                    Text("Team \(team)")
                        .font(.custom("Kefa", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(team == team1Name ? team1Color : team2Color)
                        .multilineTextAlignment(.center)

                    Text("will start the Game.")
                        .font(.custom("Kefa", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                } else {
                    VStack(spacing: 10) {
                        Text("Flip the Coin")
                            .font(.custom("Kefa", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text("Tap on the Coin to see which team\nis starting the game.")
                            .font(.custom("Kefa", size: 20))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    }
                }

                Spacer()

                // 🪙 Coin Image with Flip Animation
                Image(flippedTeam == nil ? "coin" : (flippedTeam == redTeamName ? "coin-red" : "coin-blue"))
                    .resizable()
                    .frame(width: 180, height: 180)
                    .rotation3DEffect(
                        .degrees(rotationDegrees),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .onTapGesture {
                        flipCoin()
                    }

                Spacer()

                // Continue Button (after flip)
                if flippedTeam != nil {
                    Button(action: {
                            showCardSelection = true
                        }) {
                            Image("continueButton") // Name of your Figma-exported image with "Continue" text
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 80) // Adjust based on your image size/design
                        }
                    .padding(.bottom, 30)
                }

                Spacer()
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showCardSelection) {
            CardSelectionView(
                team1Name: team1Name,
                team2Name: team2Name,
                team1Color: team1Color,
                team2Color: team2Color,
                startingTeam: flippedTeam ?? team1Name,
                team1Cards: $team1Cards,
                team2Cards: $team2Cards
            )
        }
    }

    func flipCoin() {
        guard !isFlipping else { return }

        isFlipping = true
        flippedTeam = nil
        rotationDegrees = 0

        withAnimation(.easeInOut(duration: 1)) {
            rotationDegrees += 720
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let teams = [team1Name, team2Name]
            flippedTeam = teams.randomElement()
            isFlipping = false
        }
    }
}
