import SwiftUI

struct CoinFlipView: View {
    var team1Name: String
    var team2Name: String
    var team1Color: Color
    var team2Color: Color

    @State private var flippedTeam: String? = nil
    @State private var isFlipping = false
    @State private var rotationDegrees = 0.0

    var body: some View {
        ZStack {
            Image("BackgroundPattern")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 20) {
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
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(team == team1Name ? team1Color : team2Color)
                        .multilineTextAlignment(.center)

                    Text("will start the Game.")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                } else {
                    VStack(spacing: 10) {
                        Text("Flip the Coin")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)

                        Text("Tap on the Coin to see which team\nis starting the game.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    }
                }

                Spacer()

                // 🪙 Coin Image with Flip Animation
                Image(flippedTeam == nil ? "coin-red" : (flippedTeam == team1Name ? "coin-red" : "coin-blue"))
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

                // ⏭ Next Button (after flip)
                if flippedTeam != nil {
                    Button(action: {
                        // Handle continue
                    }) {
                        Image("next-button") // Your custom-styled image
                            .resizable()
                            .frame(width: 120, height: 40)
                    }
                }

                Spacer()
            }
            .padding()
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
